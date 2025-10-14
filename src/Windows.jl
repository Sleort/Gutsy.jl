# Defining a "cutout window"

struct Window{N}
   inds::CartesianIndices{N}
end

Window(rs::AbstractRange...) = Window(CartesianIndices(rs))

function Window(rectangle::Rect)
    lower = origin(rectangle)
    upper = lower + widths(rectangle)
    lower = lower .+ eps() #Conservative limits
    upper = upper .- eps() #Conservative limits
    return Window(nearest_index(lower):nearest_index(upper))
end

for f ∈ (:(Base.getindex), :(Base.view))
    @eval $f(x::AbstractArray{<:Any, N}, w::Window{N}) where {N} = $f(x, intersect(w.inds, CartesianIndices(x)) )
end

"""
    getindex(i::CartesianIndex, w::Window)

Get the relative index inside the window `w`.
Returns `missing` is the index is not inside the window.

```
x isa AbstractArray
w isa Window
i isa CartesianIndex
xw = x[w]
iw = i[w]
xw[iw] == x[i]
```
"""
Base.getindex(i::CartesianIndex, w::Window) = ifelse(i ∈ w, relative_to(i, w), missing)


#Return vector of points inside window:
Base.getindex(points::AbstractVector{T}, w::Window) where {T <: CartesianIndex} = T[relative_to(i, w) for i ∈ points if i ∈ w]

relative_to(i::CartesianIndex{N}, w::Window{N}) where {N} = i - first(w.inds) + one(i)
Base.in(i::CartesianIndex, w::Window) = i ∈ w.inds


Base.size(w::Window) = size(w.inds)