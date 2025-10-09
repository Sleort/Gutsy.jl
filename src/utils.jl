"Find the nearest cartesian index of a point"
nearest_index(point) = CartesianIndex(round.(Int, Tuple(point)))

# """
#     index_window(r::Rect)

# Returns the largest integer ranges each axis of rectangle `r` covers.
# """
# function index_window(r::Rect)
#     lower = origin(r)
#     upper = lower + widths(r)
#     lower = ceil.(Int, lower .+ eps())
#     upper = floor.(Int, upper)
#     return Tuple(UnitRange.(lower, upper))
# end

# """
#     rectangle_view(x::AbstractMatrix, r::Rect)

# Return a view of `x` contained within the rectangle `r`.
# """
# function rectangle_view(x::AbstractMatrix, rect)
#     inds = index_window(rect)
#     return view(x, inds...)
# end

