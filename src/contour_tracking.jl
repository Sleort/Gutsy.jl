using GLMakie
###
#=
Contour tracing:

I try:
* Using Theo Pavlidi's algorithm 
(See https://www.imageprocessingplace.com/downloads_V3/root_downloads/tutorials/contour_tracing_Abeer_George_Ghuneim/theo.html)
* Output a sequence of indices.
* Go around contour in a _counter clockwise direction_ (in "Makie coordinates", i.e. first coordinate along first axis)
* Assume that we are always in the _interior_ of the array (avoid boundary checking)?
=#


const ΔIND = map(x -> map(CartesianIndex, x), (
    #(P1, P2, P3) facing in some direction
    ((1, -1), (1, 0), (1, 1)), #East
    ((1, 1), (0, 1), (-1, 1)), #North
    ((-1, 1), (-1, 0), (-1, -1)), #West
    ((-1, -1), (0, -1), (1, -1)), #South
))

#Rotate counterclockwise by 90° in this notation:
posrot(dir::Integer) = mod1(dir + 1, 4)
negrot(dir::Integer) = mod1(dir - 1, 4)


#Theo Pavlidi's update:
function pavlidi(x::AbstractMatrix{Bool}, (i, dir))
    #First test point:
    j = i + ΔIND[dir][1]
    x[j] && return (j, negrot(dir))

    #Two next:
    for p ∈ 2:3
        j = i + ΔIND[dir][p]
        x[j] && return (j, dir)
    end

    #No points in front belong to cluster: rotate counterclockwise by 90°
    return (i, posrot(dir))
end

#TODO: fill structure with this...
#TODO: initial boundary condition with orientation such that P1 is outside cluster





## ###################################
# Test:

#Testdata
x = zeros(Bool, 400, 400)
inds = CartesianIndices(x)
anchors = rand(inds[begin+1:end-1, begin+1:end-1], 50)
for i ∈ eachindex(anchors)[begin:end-1]
    x[anchors[i]:anchors[i+1]] .= true
end


#Testplot:
##
fig = Figure()
ax = Axis(fig[1, 1], aspect=DataAspect())
heatmap!(ax, x)
# heatmap!(ax, isboundarypoint.((x,), CartesianIndices(x)))
fig
##

#Initial point: NB: Be careful here!
i = i0 = findfirst(i -> x[i], inds)
dir = 1
p = Observable(Tuple(i))
scatter!(ax, p, color=:red, markersize=30)

#
for _ ∈ 1:3000
    (i, dir) = pavlidi(x, (i, dir))
    p[] = i
    notify(p)
    sleep(0.002)

    ##
    i == i0 && break
    ##
end
##



##############################################################
#=
COMMENTS:

* Seems to work!
* IF we can determine a clear, local thresholding rule ("local seeding" in some sense?), we can jump
straight to this boundary tracing algorithm _without_ having to construct a mask first -- MUCH MUCH faster
algorithm!
* Then, we could move to a Fourier-representation -> calculate endpoints by curvature -> divide into halves etc.

=#

