# Various utility functions

# """
#     get_frame(video_reader::VideoIO.VideoReader, time)

# Returns the first video frame of `video_reader` at or after `time`.
# """
# function get_frame(video_reader::VideoIO.VideoReader, time)
#     frame = first(seek(video_reader, time))
#     return parent(frame) # It's easier to operate with the un-permuted image in Makie...
# end


"Find the nearest cartesian index of a point"
nearest_index(point) = CartesianIndex(round.(Int, Tuple(point)))