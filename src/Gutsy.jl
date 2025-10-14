# module Gutsy

# # Write your package code here.

# end



using VideoIO
using GLMakie
using GeometryBasics
using Colors
using ImageSegmentation
using ProgressMeter
using Statistics
using DataInterpolations


include("Windows.jl")
include("utils.jl")
include("videos.jl")
include("segmentation_seeding.jl")
include("blob_masking.jl")
include("blob_processing.jl")
include("data_exploration.jl")


#######################################
## Read in a video (lazily)
short_video = "/home/a46632/Documents/HI/Prosjekter/Laksetarmer in vitro/Video recording/2025-09-24 13-19-38.avi"
original_video = "/home/a46632/Documents/HI/Prosjekter/Laksetarmer in vitro/Video recording/24.09.25 - Originalfil.avi"
video = Video(original_video)


## Explore data:
fig, timespan, ppoints, npoints, window = guts_explorer(video)
fig


## Brute force masks for a time series:
# ts = timespan[]
# masks = track_blob(video, window[], ppoints[], npoints[]; timespan=ts, skip_frames=0);


## Animation of data:
mask = Observable(masks[1])
ind = Observable(1)
heatmap(mask; axis=(; aspect=DataAspect(), yreversed=true, title=@lift string($ind, " / ", length(masks))))
for (i, m) ∈ enumerate(masks)
    mask[] = m
    ind[] = i
    sleep(0.001)
end
##


## Blob thickness as function of relative position and time:
sbt = stack(standardized_blob_thickness, masks);
pyramid = Makie.Pyramid(Float32.(sbt'))
##
fig = Figuxre()
ax = Axis(fig[1,1]; yreversed=true)
heatmap!(ax, Resampler(pyramid))
fig
##