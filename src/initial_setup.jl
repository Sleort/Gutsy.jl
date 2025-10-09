


#Make "cutout" based on "rectangle view":
view_within(rectangle::Rect{N}, x::AbstractArray{<:Any,N}) where {N} = view(x, index_window(rectangle)...)
view_within(ax::Axis, x) = @lift view_within($(ax.finallimits), $x)


#Make seeds based on "rectangle view":
nearest_index(p::Point) = CartesianIndex(round.(Int, Tuple(p)))
make_seed(p::Point, label::Int) = (nearest_index(p), label)
_seeds_within(rectangle::Rect{N}, points::AbstractVector{<:Point{N}}, label::Integer) where {N} = (make_seed(point - origin(rectangle), label) for point ∈ points if point ∈ rectangle)
_seeds_within(rectangle, positive_points, negative_points) = Iterators.flatten((_seeds_within(rectangle, positive_points, 1), _seeds_within(rectangle, negative_points, 2)))
seeds_within(args...) = collect(_seeds_within(args...))






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
    
    positive_seeds = Observable(Point2f[])
    negative_seeds = Observable(Point2f[])
    
    pos_plt = scatter!(ax, positive_seeds; color=positive_color, markersize)
    neg_plt = scatter!(ax, negative_seeds; color=negative_color, markersize)

    on(events(ax).mousebutton, priority = 2) do event
        kbstate = events(ax).keyboardstate
        if event.action == Mouse.press && Keyboard.tab ∈ kbstate
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
            #Remove _all_ seeds
            empty!(negative_seeds[])
            empty!(positive_seeds[])
            notify(negative_seeds)
            notify(positive_seeds)
            return Consume(true)
        elseif event.action == Mouse.press && (Keyboard.left_shift ∈ kbstate || Keyboard.right_shift ∈ kbstate)
            mp = mouseposition(ax)
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
        end
        return Consume(false)
    end

    #return positive_seeds, negative_seeds
    seeds = @lift seeds_within($(ax.finallimits), $positive_seeds, $negative_seeds) 
    return seeds
end