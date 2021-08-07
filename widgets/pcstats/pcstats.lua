---------------------------------------------------------------------------
-- 
-- Simple widget to display Storage, Memory, and Compute utilization created on Arch Linux for personal use..
--
-- Based on the timing system of the text clock widget. Check Out Julian Danjous much more thorough work at /usr/share/awesome/lib/wibox/widget/textclock.lua.
-- 
--  IMPORTANT: as always there is a possibility that a version of one of the utilized system utilities is giving a different output and as such that this widget is not functional.
--
--  n-Il 08/07/2021
--
---------------------------------------------------------------------------

local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local gtable = require("gears.table")
local awful = require("awful")

local command = "S=`df -h | awk '$NF==\"/\"{printf \"%s\", $5}'`;M=`free -m | awk 'NR==2{printf \"%02.0f%%\", $3*100/$2 }'`;C=`cat <(grep 'cpu ' /proc/stat) <(sleep 0.1 && grep 'cpu ' /proc/stat) | awk -v RS=\"\" '{printf \"%02.0f%%\", ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5)}'`;echo \"[S:$S M:$M C:$C]\""

local temp = {}

----- Force to update now.
function temp:force_update()
    self._timer:emit_signal("timeout")
end

-- function
local function new() -- format
    local w = textbox()
    gtable.crush(w, temp, true)--makes the first table's elements into the elements of the second table.

    function w._private.temp_update_cb()
	awful.spawn.easy_async_with_shell(command, function(out)
        	w:set_markup(out)-- sets the markup for the widget to the output of our command.
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
