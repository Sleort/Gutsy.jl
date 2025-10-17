function guts_explorer(video::Video)
    fig = Figure()
    ax1 = Axis(fig[1, 1], aspect=DataAspect(), yreversed=true, title="First frame")
    ax2 = Axis(fig[1, 3], aspect=DataAspect(), yreversed=true, title="Last frame")
    ax3 = Axis(fig[1, 2], aspect=DataAspect(), yreversed=true, title="Mask of first frame")
    linkaxes!(ax1, ax2, ax3)

    ##################
    # Time span 
    ##################
    totframes = framecount(video) - 1 #Effective number of frames to be used
    timeslider = IntervalSlider(fig[end+1, :]; range=1:totframes, snap=false) #Counting in frame indices... Need to remove last because of issues...
    timespan = @lift range($(timeslider.interval)...)
    tstart = @lift first($timespan)
    tstop = @lift last($timespan)
    timeslider_label = @lift string("Frames ", $tstart, " to ", $tstop)
    Label(fig[end+1, :], timeslider_label, tellwidth=false)

    ##################
    # Frame images
    ##################
    frame = @lift get_frame(video, $tstart)
    heatmap!(ax1, frame; interpolate=false)
    heatmap!(ax2, @lift get_frame(video, $tstop); interpolate=false)

    ##################
    # Blob masking
    ##################
    # Place seeds, find mask...:
    positive_points, negative_points = place_seed_points!(ax1) #Seed points for masking
    window = @lift Window($(ax1.finallimits)) #Window where the computations are done

    maskmaker = @lift MaskMaker($positive_points, $negative_points, $window)
    _mask = falses(size(frame[])) #Storage for the mask to be displayed
    mask = @lift begin
        _mask[$window] .= $maskmaker($frame)
        _mask
    end
    heatmap!(ax3, mask; interpolate=false)

    #Update _positive seeds points_ to center them on positive segment:
    # XXX Not that robust, but it seems to work...
    on(tstart) do t
        adjust_seed_points!(positive_points[], mask[])
        notify(positive_points)
    end

    ##################
    # Relative length limits:
    ##################
    yboundary = @lift [trim_limits(blob_thickness($mask))...]
    hlines!(ax3, yboundary; color=:white, linestyle=:dash)


    ##################
    # Making a thickness heatmap
    ##################
    DEFAULT_VERTICAL_RESOLUTION = 256
    DEFAULT_FRAME_STRIDE = 100
    NOTIFY_PERIOD = 1

    #Heatmap
    ax4 = Axis(fig[end+1, :];
        yreversed=true, 
        xlabel="Frame number",
        xtickformat = values -> string.(Int.(values)),
        ylabel="Relative vertical position", 
        title="Horizontal thickness as function of frame number"
        )
    
    #Controllers
    fig[end+1, :] = inputgrid = GridLayout(tellwidth=false)

    # Vertical resolution
    yresolution = Observable(DEFAULT_VERTICAL_RESOLUTION)
    Label(inputgrid[1, 1][1, 1], "Vertical resolution")
    tb_yres = Textbox(inputgrid[1, 1][1, 2], placeholder=string(DEFAULT_VERTICAL_RESOLUTION), validator=Int, tellwidth=true)

    # Frame stride
    Δframes = Observable(DEFAULT_FRAME_STRIDE)
    Label(inputgrid[1, end+1][1, 1], "Frame stride:")
    tb_Δframes = Textbox(inputgrid[1, end][1, 2], placeholder=string(DEFAULT_FRAME_STRIDE), validator=Int, tellwidth=true)
    on(tb_Δframes.stored_string) do s
        Δframes[] = max(1, parse(Int, s))
    end

    # ... leading to selected frames
    selected_frames = @lift $tstart:$Δframes:$tstop
    nframes = @lift length($selected_frames)
    Label(inputgrid[1, end+1], @lift " Thus, $($nframes) frames are seleted.")

    # Start thickness tracing
    tracebutton = Button(inputgrid[1, end+1]; label="Trace thickness")

    # Thickness plot
    thickness = @lift fill(NaN, $yresolution, $nframes)
    ylab = @lift range(0,1; length=$yresolution)
    heatmap!(ax4, selected_frames, ylab, @lift($thickness')) #XXX FIX PLOTTING OF LARGE HEATMAPS!
    on(thickness) do _
        reset_limits!(ax4)
        #Copy data from old thickness to new thickness array?
    end

    on(tracebutton.clicks) do clk
        mm = deepcopy(maskmaker[])
        iseek(video, tstart[])
        frame = read(video)

        @async @showprogress for i ∈ eachindex(selected_frames[]) #1:nframes
            mask_i = mm(frame)
            thickness[][:, i] .= gut_thickness(mask_i; n = yresolution[])
            i % NOTIFY_PERIOD == 0 && notify(thickness) #For live updating...
            # #yield() #Not necessary when using @showprogress ?
            adjust!(mm, mask_i) #Adjust masker for next frame
            Δframes[] > 1 && skipframes(video.reader, Δframes[] - 1)
            read!(video, frame) #Read next frame
        end
        notify(thickness)
    end

    # Empty heatmap:
    emptybutton = Button(inputgrid[1, end+1]; label="Clear plot")
    on(emptybutton.clicks) do clk
        fill!(thickness[],  NaN)
        notify(thickness)
    end

    return fig, selected_frames, thickness  #, timespan, maskmaker
end