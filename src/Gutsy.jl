# module Gutsy

# # Write your package code here.

# end

#=
TODO:
* Spatial-temporal "cutout" with slider and window selection
* Mark seeds on image with mouse
    - shift + left-click for positive marks
    - shift + right-click for negative marks
    - Tab + click for removing one point
    - SOMETHING for removing all seeds
* Based on seeds: generate segmentation
* Based on segmentation: generate next-frame seeds
* Iterate through the entire spatial frame.


SUB-TODO:
* Track a window of CartesianIndices instead of a cutout...


=#



using VideoIO
using GLMakie
using GeometryBasics
using Colors
using ImageSegmentation
###########################################


include("utils.jl")
include("segmentation_seeding.jl")
include("Windows.jl")


#######################################
## Read in a video (lazily)
short_video = "/home/a46632/Documents/HI/Prosjekter/Laksetarmer in vitro/Video recording/2025-09-24 13-19-38.avi"
original_video = "/home/a46632/Documents/HI/Prosjekter/Laksetarmer in vitro/Video recording/24.09.25 - Originalfil.avi"
vpath = original_video
vreader = VideoIO.openvideo(vpath)
duration = VideoIO.get_duration(vpath) - 0.5 #Avoid the end due to some rounding convetions



###########################################
## Look at some cutout of a frame:
fig = Figure()
ax1 = Axis(fig[1,1], aspect=DataAspect(), yreversed=true)
ax2 = Axis(fig[1,2], aspect=DataAspect(), yreversed=true) 

timeslider = Slider(fig[2,1:2], range=0:duration)

t = timeslider.value
img = @lift begin
    img = first(seek(vreader, $t))
    img = parent(img)
end

#Original image:
heatmap!(ax1, img; interpolate=false)

seeds = place_seeds!(ax1)
window = @lift Window($(ax1.finallimits)) #Compute window

#Segmentation:
_mask = falses(size(img[])) #Storage for the mask to be displayed
mask = @lift begin
    segments = seeded_region_growing($img[$window], $seeds[$window])
    _mask[$window] .= labels_map(segments) .== 1 #Only update the compute window
    _mask
end
heatmap!(ax2, mask; interpolate=false)
linkaxes!(ax1, ax2)

fig

## ###########################################

