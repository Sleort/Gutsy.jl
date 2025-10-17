# Various utility functions

"Find the nearest cartesian index of a point"
nearest_index(point) = CartesianIndex(round.(Int, Tuple(point)))