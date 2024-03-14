---------------------------------------------------------------------------
-- 
-- Simple temperature widget built on Arch Linux to display cpu package temp with lmsensors.
--
-- Based on the timing system of the text clock widget. Check Out Julian Danjous much more thorough work at /usr/share/awesome/lib/wibox/widget/textclock.lua.
-- 
--  IMPORTANT: I grab the line from sensors starting with Tdie:(9 spaces), if your sensors output doesn't use the same format, then this will need to be adjusted.
--
--  n-Il 06/14/2020
--
---------------------------------------------------------------------------

local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local gtable = require("gears.table")
local awful = require("awful")


--Learned how to positive lookbehind
--local command = "sensors | grep -Po \"(?<=Tdie:\\s{9})\\+.*?C\""
local command = "sensors | grep -Po \"(?<=CPU:\\s{10})\\+.*?C\""


local temp = {}

----- Force  temp to update now.
function temp:force_update()
    self._timer:emit_signal("timeout")
end

-- function
local function new() -- format
    local w = textbox()
    gtable.crush(w, temp, true)--makes the first table's elements into the elements of the second table.

    function w._private.temp_update_cb()
	awful.spawn.easy_async_with_shell(command, function(out)
        	w:set_markup(('['..string.sub(out,0,-2)--[[..utf8.char(176)]]..']'))-- sets the markup for the widget to the output of our command. Sub to remove newline
    	end)

        w._timer:again()
        return true -- Continue the timer
    end

    w._timer = timer.weak_start_new(5, w._private.temp_update_cb)-- starts timer
    w:force_update()-- run now 
    return w
end

function temp:__call(...)
    return new(...)
end

return setmetatable(temp, temp)
