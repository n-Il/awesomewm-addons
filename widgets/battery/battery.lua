---------------------------------------------------------------------------
-- 
-- Simple Battery Widget built on Arch Linux to display battery without external tools.
--
-- Based on the timing system of the text clock widget. Check Out Julian Danjous much more thorough work at /usr/share/awesome/lib/wibox/widget/textclock.lua.
--
-- If you're here to add features after downloading this from a repo, I'd suggest checking out Pavel Makhov or github.com/Streetturtle's battery widget as his is much more comprehensive. 
--
--  n-Il 12/16/2020
--
---------------------------------------------------------------------------

local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local gtable = require("gears.table")
local awful = require("awful")
local readLocation = "/sys/class/power_supply/BAT0/capacity"
local naughty = require("naughty")
local readChargingLocation = "/sys/class/power_supply/BAT0/status"

local bat = {}

----- Force  bat to update now.
function bat:force_update()
    self._timer:emit_signal("timeout")
end

-- function
local function new() -- format
    local w = textbox()
    gtable.crush(w, bat, true)--makes the first table's elements into the elements of the second table.

    function w._private.bat_update_cb()
	local command = "cat "..readLocation
	awful.spawn.easy_async_with_shell(command, function(out)
        	batLevel = string.sub(out,0,-2)
                batLevelDec = tonumber(batLevel)
                if batLevelDec < 25 then
                    local statuscmd = "cat "..readChargingLocation
                    awful.spawn.easy_async_with_shell(statuscmd,function(out)
                        batStatus = string.sub(out,0,-2) 
                        if batStatus == "Discharging" then--!Charging is better, but Im not sure if all batteries follow this status format as non-standard chargers can make this status Unknown
                            naughty.notify({preset = naughty.config.presets.critical,title = "Low Battery Warning",timeout = 55})
                        end
                    end)
                end
                w:set_markup(('[bat:'..batLevel..']'))-- sets the markup for the widget to the output of our command. Sub to remove newline
    	end)

        w._timer:again()
        return true -- Continue the timer
    end

    w._timer = timer.weak_start_new(30, w._private.bat_update_cb)-- starts timer
    w:force_update()-- run now so we don't have to wait 30 seconds for the first update
    return w
end

function bat:__call(...)
    return new(...)
end

return setmetatable(bat, bat)
