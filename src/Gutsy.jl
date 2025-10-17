module Gutsy

using Accessors
using VideoIO
using GLMakie
using GeometryBasics
using Colors
using ImageSegmentation
using Statistics
using DataInterpolations
using ProgressMeter

include("utils.jl")
include("Videos.jl")
include("Windows.jl")
include("MaskMaker.jl")
include("segmentation_seeding.jl")
include("blob_processing.jl") #TO BE IMPROVED
include("data_exploration.jl")

export Video, iseek
export MaskMaker, guts_explorer

end

