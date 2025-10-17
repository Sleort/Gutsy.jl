#=
MaskMaker object storing seeds and window.

NB: This approach may change in the future...
=#


struct MaskMaker
    seeds::Vector{Tuple{CartesianIndex{2}, Int}} #For the segmentation algorithm
    window::Window{2} #To save computations, we only do masking/segmentation within a (hopefully relevant) window!
end

#Construct a MaskMaker, given global seed coordinates and a window
function MaskMaker(positive_seeds::T, negative_seeds::T, window::Window) where {T <: AbstractVector{CartesianIndex{2}}}
    ps = positive_seeds[window]
    ns = negative_seeds[window]
    seeds = [tuple.(ps, 1); tuple.(ns, 2)]
    return MaskMaker(seeds, window)
end


# Make mask given frame (image):
function (m::MaskMaker)(frame::AbstractMatrix)
    (; seeds, window) = m
    wframe = @view frame[window]
    segments = seeded_region_growing(wframe, seeds)
    return labels_map(segments) .== 1
end

#Read in current video and makes a mask of the frame
#NB: This increments the video reader by one, hence we also adjust the maskmaker in the process!
function (m::MaskMaker)(video::Video)
    frame = read(video)
    mask = m(frame)
    adjust!(m, mask)
    return mask
end

# Adjust maskmaker seeds given a mask (for time stepping)
# Currently: adjusting positive seeds only!
function adjust!(m::MaskMaker, mask::AbstractMatrix{Bool})
    (; seeds) = m
    for i ∈ eachindex(seeds)
        if is_positive_seed(seeds[i])
            seeds[i] = adjust(seeds[i], mask)
        end
    end
    return m
end

is_positive_seed(seed::Tuple{CartesianIndex{2},Int}) = last(seed) == 1

adjust(pos::CartesianIndex{2}, mask) = pos + segment_midpoint_difference(mask, pos; dims=1) #Shift to midpoint in y-direction
adjust((pos, label), mask) = (adjust(pos, mask), label)