# TEMPORARY PLAYGROUND. WILL BE DELETED WHEN THINGS ARE UP AND RUNNING PROPERLY!
#######################################

###################
## Loading necessary libraries
###################
using Gutsy
using VideoIO
using GLMakie
using CSV, Tables


###################
# Analyzing data
###################

## Read in a video (lazily)
video_path = "/home/a46632/Documents/HI/Prosjekter/Laksetarmer in vitro/Video recordings/28.10.25 - Originalfil.avi"
video = Video(video_path)

## Explore data interactively:
fig, selected_frames, thickness = guts_explorer(video)
fig 

## Explore data interactively, but smaller marker size (default is markersize=20):
fig, selected_frames, thickness = guts_explorer(video; markersize=10)
fig 


## The content of the other outputs are:
selected_frames[] #The selected frame numbers
thickness[] #The (horizontal) thickness of the intestine as a function of relative vertical position and time


###################
# Storing data
###################
# If you want to write the `thickness matrix` (only) to a CSV-file:
path = "mycooldata.csv"
datamatrix = thickness[]
CSV.write(path, Tables.table(datamatrix); writeheader=false)
jr
#... and read it back into Julia:
zombiedata = CSV.read(path, Tables.matrix; header=false)

#If you want to store it together with the selected_frame indices:
datatable = Tables.table(thickness[]; header=selected_frames[])
CSV.write(path, datatable)

#... and read it back into Julia:
zombiedata = CSV.read(path, Tables.matrix)
zombieframenumbers = Int.(first(CSV.File(path; header=false))) #This is a bit hacky. There probably is an easier way!
