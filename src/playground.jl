# TEMPORARY PLAYGROUND. WILL BE DELETED WHEN THINGS ARE UP AND RUNNING PROPERLY!
#######################################

using Gutsy
using VideoIO
using GLMakie

## Read in a video (lazily)
video_path = "/home/a46632/Documents/HI/Prosjekter/Laksetarmer in vitro/Video recording/24.09.25 - Originalfil.avi"
video = Video(video_path)


## Explore data:
fig, timespan, maskmaker = guts_explorer(video)
fig


## Brute force masks for a time series:
ts = timespan[]
mm = deepcopy(maskmaker[])
iseek(video, ts[1]) #Move video reader to ts[1]

masks = [begin
        mask = mm(video)
        skipframes(video.reader, 10)
        mask
    end for t ∈ 1:100];
sbt = stack(Gutsy.standardized_blob_thickness, masks);
heatmap(sbt'; axis=(; yreversed=true))
## ##############################################

mask = Observable(copy(masks[1]))
ind = Observable(1)
heatmap(mask; axis=(; aspect=DataAspect(), yreversed=true, title=@lift string($ind, " / ", length(masks))))
for (i, m) ∈ enumerate(masks)
    mask[] = m
    ind[] = i
    sleep(0.02)
end


## Writing gut thickness to file:
using CSV, Tables
thickness = Tables.table(sbt);
path = "test.csv"
CSV.write(path, thickness; writeheader=false)





#=
TODO:
* Update pipeline to MaskMaker functionality
* Cleanup!
* Go straight for the guts_thickness?
* Save to CSV array...
* Possible to parallelize?
* 
=#



# ## Blob thickness as function of relative position and time:
# sbt = stack(standardized_blob_thickness, masks);
# pyramid = Makie.Pyramid(Float32.(sbt'))
# ##
# fig = Figure()
# ax = Axis(fig[1,1]; yreversed=true)
# heatmap!(ax, Resampler(pyramid))
# fig
# ##