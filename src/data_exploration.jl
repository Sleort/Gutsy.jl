function guts_explorer(video::Video)
    fig = Figure()
    ax1 = Axis(fig[1, 1], aspect=DataAspect(), yreversed=true, title = "First frame")
    ax2 = Axis(fig[1, 3], aspect=DataAspect(), yreversed=true, title = "Last frame")
    ax3 = Axis(fig[1, 2], aspect=DataAspect(), yreversed=true, title = "Mask of first frame")
    linkaxes!(ax1, ax2, ax3)
 
    ##################
    # Time span 
    ##################
    timeslider = IntervalSlider(fig[end+1, :]; range=1:framecount(video)-1, snap=false) #Counting in frame indices... Need to remove last because of issues...
    timespan = timeslider.interval
    tstart = @lift first($timespan)
    tend = @lift last($timespan)
    timeslider_label = @lift string("Frames ", $tstart, " to ", $tend)
    Label(fig[end+1, :], timeslider_label, tellwidth=false)

    ##################
    # Frame images
    ##################
    frame = @lift get_frame(video, $tstart)
    heatmap!(ax1, frame; interpolate=false)
    heatmap!(ax2, @lift get_frame(video, $tend); interpolate=false)

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
        #adjust!(maskmaker[])
        adjust_seed_points!(positive_points[], mask[])
        notify(positive_points)
    end

    ##################
    # Relative length limits:
    ##################
    yboundary = @lift [trim_limits(blob_thickness($mask))...]
    hlines!(ax3, yboundary; color=:white, linestyle=:dash)

    #=
    TODO: Track the width heatmap as the mask width is generated?
    =#
    
    return fig, timespan, maskmaker#positive_points, negative_points, window
end