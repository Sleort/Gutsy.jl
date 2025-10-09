"""
    place_seeds!(ax::Axis)

Returns an `Observable` containing a vector of segmentation seeds, with "positive seeds" 
labeled 1 and "negative seeds" labeled 2.

The seeds are visualized as scatterplots on top of `Axis` `ax`.

shift + left mouse button: place a positive seed
shift + right mouse button: place a negative seed
tab + mouse button: remove a seed
`d` + mouse button: remove all seeds
"""
function place_seeds!(ax::Axis; positive_color=:lime, negative_color=:red, markersize=20)
    #Essentially extending the example at https://docs.makie.org/stable/explanations/events#Point-Picking
    
    positive_seeds = Observable(CartesianIndex{2}[])
    negative_seeds = Observable(CartesianIndex{2}[])
    
    pos_plt = scatter!(ax, @lift(Tuple.($positive_seeds)); color=positive_color, markersize)
    neg_plt = scatter!(ax, @lift(Tuple.($negative_seeds)); color=negative_color, markersize)

    on(events(ax).mousebutton, priority = 2) do event
        kbstate = events(ax).keyboardstate
        if event.action == Mouse.press && (Keyboard.left_shift ∈ kbstate || Keyboard.right_shift ∈ kbstate)
            mp = nearest_index(mouseposition(ax))
            if event.button == Mouse.left
                # Add positive seed
                push!(positive_seeds[], mp)
                notify(positive_seeds)
            elseif event.button == Mouse.right
                # Add negative seed
                push!(negative_seeds[], mp)
                notify(negative_seeds)
            end
            return Consume(true)
        elseif event.action == Mouse.press && Keyboard.tab ∈ kbstate
            # Remove a single seed
            plt, i = pick(ax)
            if plt == pos_plt
                deleteat!(positive_seeds[], i)
                notify(positive_seeds)
                return Consume(true)
            end
            if plt == neg_plt
                deleteat!(negative_seeds[], i)
                notify(negative_seeds)
                return Consume(true)
            end
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

    seeds = @lift labeled_points($positive_seeds, $negative_seeds)
    return seeds
end


# Attach a numerical label to each point collection
function labeled_points(point_collections::AbstractVector...)
    ps = Iterators.flatmap(x -> Iterators.map(point -> (point, x[1]), x[2]), enumerate(point_collections))
    return collect(ps)
end

