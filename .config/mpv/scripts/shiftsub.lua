local mp = require("mp")

local hms_re = "[+-]?%d%d?:%d%d?:%d%d?,%d+"
local hms_re_catch = "([+-]?)(%d%d?):(%d%d?):(%d%d?),(%d*)"

-- Function to convert time in hms format to seconds
local function hms2secs(input)
   -- Extract components from the input using the hms_re_catch pattern
   local sign, hours, minutes, seconds, milliseconds = input:match(hms_re_catch)
   -- If no match, return nil
   if not sign then return end
   -- Calculate total seconds and return
   return tonumber(sign .. "1") *
       (tonumber(hours) * 3600 + tonumber(minutes) * 60 + tonumber(seconds) + (tonumber(milliseconds) or 0) * 0.001)
end

-- Function to convert seconds to hms format
local function secs2hms(input)
   -- If input is not a number, return default hms format
   if not tonumber(input) then return "00:00:00,000" end
   -- Calculate milliseconds and components for hours, minutes, and seconds
   local ms = 1000 * (input - math.floor(input))
   input = math.floor(input)
   local s = input % 60
   input = (input - s) / 60
   local m = input % 60
   input = (input - m) / 60
   -- Format and return the hms string
   return string.format("%02d:%02d:%02d,%03d", input, m, s, ms)
end

-- Function to apply subtitle delay to srt file.
function shiftSubtitles()
   local secs_shift = mp.get_property_number("sub-delay")
   local secs_start = mp.get_property_number("time-pos")
   local filename = mp.get_property("current-tracks/sub/external-filename")
   if (not string.find(filename, ".srt")) then
      print("Subtitle isn't under srt format.")
      return
   end

   local file = io.open(filename, "r+")
   if not file then return end

   local content = file:read("a")

   content = content:gsub("(%d%d:%d%d:%d%d,%d%d%d)", function(hms)
      local sec = hms2secs(hms)
      if (secs_shift < 0 and sec < secs_start) or (secs_shift > 0 and sec < secs_start - secs_shift) then
         return hms -- Before start subtitles
      elseif (secs_shift < 0 and sec > secs_start - secs_shift) or secs_shift > 0 then
         return secs2hms(sec + secs_shift) -- Shifted subtitles
      else
        return secs2hms(-sec) -- Disable overwrote subtitles by giving it a negative timestamp.
      end
   end)

   file:seek("set")
   file:write(content)
   file:close()

   mp.set_property("sub-delay", 0)
   mp.commandv("sub-reload")
end

mp.add_key_binding("g", "shift_subtitles", shiftSubtitles)
