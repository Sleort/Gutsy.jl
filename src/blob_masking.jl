function blob_mask(image::AbstractArray{<:Any,N}, positive_points::T, negative_points::T) where {N,T<:AbstractVector{CartesianIndex{N}}}
    seeds = [tuple.(positive_points, 1); tuple.(negative_points, 2)]
    segments = seeded_region_growing(image, seeds)
    mask = labels_map(segments) .== 1
    return mask
end



# Track an identified "blob" in the window for steps steps. (Initial) seed points given...
function track_blob(video::Video, window::Window, positive_points, negative_points; timespan, max_framecount=typemax(Int), skip_frames=0)
    tstart, tstop = timespan
    iseek(video, tstart)

    pp = positive_points[window]
    np = negative_points[window]

    #First mask:
    frame = read(video)
    wframe = @view frame[window] #The relevant "windowed" part of the frame
    mask = blob_mask(wframe, pp, np)
    adjust_seed_points!(pp, mask)
    masks = [mask]

    n = tstop - tstart + 1
    n = min(n, max_framecount)
    δ = 1 + skip_frames
    @showprogress for _ ∈ 2:δ:(n - δ)
        iszero(skip_frames) || skipframes(video, skip_frames)
        read!(video, frame)
        mask = blob_mask(wframe, pp, np)
        adjust_seed_points!(pp, mask)
        push!(masks, mask)
    end
    return masks
end