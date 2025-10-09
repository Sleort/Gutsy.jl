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
function Base.getindex(i::CartesianIndex{N}, w::Window{N}) where {N}
    iw = i - first(w.inds) + one(i)
    return ifelse(iw ∈ CartesianIndices(w.inds), iw, missing)
end


#Seeds within a window:
function Base.getindex(seeds::AbstractVector{T}, w::Window) where {T <: Tuple{CartesianIndex, Integer}}
    T[(x[1][w], x[2]) for x ∈ seeds if !ismissing(x[1][w])]
end



##
# x = collect(reshape(1:120, 10,12))
# w = Window(4:8, 4:7)

# xw = x[w]
# i = CartesianIndex(5,6)
# iw = i[w]
# x[i] == xw[iw]

