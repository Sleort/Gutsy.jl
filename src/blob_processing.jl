"""
 blob_thickness(mask)

Return the (horisontal) thickness of the "blob" in `mask` as a vector.
"""
blob_thickness(mask) = vec(sum(mask; dims=1))


"""
    trim_limits(thickness::AbstractVector; threshold=0.15, margin=0.3)

Find the "trim cuts" of a vector of thickness values.

Algorithm:
1. Let `a = threshold * maximum(thickness)`
2. Let `b = margin * maximum(thickness)`
2. Find the first point `i` for which `thickness[i] > a`
3. Find the first point `j > k` where `thickness[k] > b` for which `thickness[j+1] < a`
4. Return the trim cuts `(i,j)`
"""
function trim_limits(thickness::AbstractVector; threshold=0.2, margin=0.4)
    m = maximum(thickness)
    a = m * threshold
    b = m * margin
    i = firstindex(thickness)
    margin_passed = false
    for j ∈ eachindex(thickness)[begin:end-1]
        (i == firstindex(thickness)) && (thickness[j] > a) && (i = j)
        if margin_passed
            thickness[j+1] < a && return (i, j)
        else
            margin_passed = thickness[j] > b
        end
    end
    return (i, lastindex(thickness))
end




###########################
# Make an interpolated cutout of the input thickness vector x:
function standardized_cutout!(y::AbstractVector, x::AbstractVector, xlimits=trim_limits(x))
    tx = range(xlimits...)
    ty = range(xlimits...; length=length(y))
    x′ = @view x[tx]
    interp = LinearInterpolation(x′, tx) #XXX Other interpolation scheme better?
    interp(y, ty)
    return y
end

standardized_cutout(x, n::Integer) = standardized_cutout!(Array{Float64}(undef, n), x)


standardized_blob_thickness(mask, n=256) = standardized_cutout(blob_thickness(mask), n)
