#############################################################################
# Place initial seeds:
#############################################################################
"""
    place_seeds!(ax::Axis)

Returns an `Observable` containing a vector of segmentation seeds, with "positive seeds" 
labeled 1 and "negative seeds" labeled 2.

The seeds are visualized as scatterplots on top of `Axis` `ax`.

* shift + left mouse button: place a positive seed
* shift + right mouse button: place a negative seed
* shift-clicking a seed again removes it
* `d` + mouse button: remove all seeds
"""
function place_seed_points!(ax::Axis; positive_color=:lime, negative_color=:red, markersize=20)
    #Essentially extending the example at https://docs.makie.org/stable/explanations/events#Point-Picking

    positive_seeds = Observable(CartesianIndex{2}[]) #Where the blobs of interest are
    negative_seeds = Observable(CartesianIndex{2}[]) #... everything else

    pos_plt = scatter!(ax, @lift(Tuple.($positive_seeds)); color=positive_color, markersize)
    neg_plt = scatter!(ax, @lift(Tuple.($negative_seeds)); color=negative_color, markersize)

    on(events(ax).mousebutton, priority=2) do event
        kbstate = events(ax).keyboardstate
        if event.action == Mouse.press && (Keyboard.left_shift ∈ kbstate || Keyboard.right_shift ∈ kbstate)
            mp = nearest_index(mouseposition(ax))
            plt, i = pick(ax)
            if plt == pos_plt
                # Remove positive seed
                deleteat!(positive_seeds[], i)
                notify(positive_seeds)
            elseif plt == neg_plt
                # Remove negative seed
                deleteat!(negative_seeds[], i)
                notify(negative_seeds)
            else
                if event.button == Mouse.left
                    # Add positive seed
                    push!(positive_seeds[], mp)
                    notify(positive_seeds)
                elseif event.button == Mouse.right
                    # Add negative seed
                    push!(negative_seeds[], mp)
                    notify(negative_seeds)
                end
            end
            return Consume(true)
        elseif event.action == Mouse.press && Keyboard.d ∈ kbstate
            #Remove all seeds
            empty!(negative_seeds[])
            empty!(positive_seeds[])
            notify(negative_seeds)
            notify(positive_seeds)
            return Consume(true)
        end
        return Consume(false)
    end

    return positive_seeds, negative_seeds
end


#############################################################################
# Prepare/update seeds for the next frame:
#############################################################################
#=
    Adjust existing seeds for the seeded_region_growing of the next frame.
    We do this by moving them such that they are in the middle of their current segment 
    along some dimension.
=#

function distance_to_segment_edge(segments::AbstractArray, p₀::CartesianIndex, δ::CartesianIndex)
    Ω = CartesianIndices(segments)
    label = segments[p₀]
    p = p₀ + δ
    steps = 0
    while (p ∈ Ω) && (segments[p] == label)
        p += δ
        steps += 1
    end
    return steps
end

function segment_midpoint_difference(segments, p₀::CartesianIndex, δ::CartesianIndex)
    dp = distance_to_segment_edge(segments, p₀, δ)
    dn = distance_to_segment_edge(segments, p₀, -δ)
    Δ = (dp - dn) ÷ 2
    return Δ * δ
end

function segment_midpoint_difference(segments, p₀::CartesianIndex{N}; dims=1) where {N}
    δ = CartesianIndex(ntuple(d -> ifelse(d ∈ dims, 1, 0), N))
    return segment_midpoint_difference(segments, p₀, δ)
end


############################
# Adjust seeds for the next frame:
# This is based on the midpoint adjustment (didn't have to be this...)
############################
function adjust_seed_points!(points::AbstractVector, mask; dims=1)
    for (i,p) ∈ pairs(points)
        p += segment_midpoint_difference(mask, p; dims) #Shift to midpoint
        points[i] = p
    end
    return points
end