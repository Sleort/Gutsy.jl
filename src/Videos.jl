# Wrapping VideoIO's functionality in a bit more convenient package (since I sometimes find VideoIO.jl a bit lacking)
# (This could probably be removed/updated later on)
##########################################################

struct Video{R}
    reader::R
    framecount::Int
    fps::Int
    duration::Float64
end

function Video(path::String)
    reader = VideoIO.openvideo(path)
    framecount = VideoIO.get_number_frames(path)
    duration = VideoIO.get_duration(path)
    fps = Int(framecount / duration) #Should be an integer, otherwise something is wrong!
    return Video(reader, framecount, fps, duration)
end

#Accessors
fps(video::Video) = video.fps
duration(video::Video) = video.duration

"""
    framecount(video::Video [, t])

Count the nearest integer number of frames of the `video` until time `t`. 
If no `t` is provided, the framecount of the entire video is returned.
"""
framecount(video::Video) = video.framecount
framecount(video::Video, t) = round(Int, fps(video) * t)
#XXX SHOULD TEST: framecount(video) == framecount(video, duration(video))

VideoIO.skipframes(video::Video, n) = skipframes(video.reader, n)



#Read a frame, increment the reader by one
Base.read(video::Video) = parent(read(video.reader)) #Better to work with the original array than the permuteddims one; it fits Makie better...
Base.read!(video, frame) = read!(video.reader, frame) #Frame is also mutated!

#Seek time of frame:
function VideoIO.seek(video::Video, time) 
    seek(video.reader, time)
    return video
end
Base.position(video::Video) = position(video.reader)

#Seek index of frame:
iseek(video::Video, i::Integer) = seek(video, i / fps(video))
iposition(video::Video) = Int(fps(video) * position(video))



# Get the i'th frame of the video (XXX approximately? It's a bit hard to figure out the internal counting in the VideoIO.Reader...)
get_frame(video::Video, i::Integer) = read(iseek(video, i))