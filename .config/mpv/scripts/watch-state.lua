local mp = require('mp')
local xml = require('xml2lua')
local handler = require('xmlhandler.tree')
local watched = false;

-- Function to mark a file as watched by updating its NFO file
local function markFileAsWatched(filename)
   local nfoFilename = string.gsub(filename, "(%.[mp4|mkv|avi]+)$", ".nfo")
   local nfoFile = io.open(nfoFilename, "w+")
   if not nfoFile then return end

   handler.root.episodedetails.watched = "true"
   watched = true;
   nfoFile:write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n')
   nfoFile:write(xml.toXml(handler.root))
   nfoFile:close()
end

-- Function to check if the current file is watched and skip to the next if it is
local function skipWatchedFile()
   local filename = mp.get_property("path")
   local nfoFilename = string.gsub(filename, "(%.[mp4|mkv|avi]+)$", ".nfo")

   handler = handler:new()
   xml.parser(handler):parse(xml.loadFile(nfoFilename))

   if (handler.root.episodedetails.watched == "true") then
      mp.command("playlist_next")
   else
      watched = false
   end
end

-- Function to mark a file as watched when it reaches 90% of its duration
local function checkEnd()
   local duration = mp.get_property_number("duration")
   local position = mp.get_property_number("time-pos")
   if not watched and duration and position and position / duration >= 0.9 then
      markFileAsWatched(mp.get_property("path"));
   end
end

-- Add event hooks
mp.register_event("file-loaded", skipWatchedFile)
mp.add_periodic_timer(30, checkEnd)
