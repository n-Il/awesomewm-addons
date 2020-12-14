---------------------------------------------------------------------------
-- 
-- Going to rig a widget that will let me know if pacman has any updates for packages tonight
-- Only works with Pacman, relying on pacman to return the packages to update or nothing if all is up to date
-- TODO: would like to make the hover dropdown show what needs updating
-- TODO: this requires manual pacman repo updates to stay up to date, so perhaps we need a way to get permission to update the repos periodically, currently I'm just using a pacman -Syy in my .WMstartup
--  n-Il  12/12/2020
--
---------------------------------------------------------------------------

local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local gtable = require("gears.table")
local awful = require("awful")
local naughty = require("naughty")
local updatesneeded = 0
local command = "pacman -Qu"
local upd = {}
----- Force  upd to update now.
function upd:force_update()
    self._timer:emit_signal("timeout")
end

-- function
local function new() -- format
    local w = textbox()
    gtable.crush(w, upd, true)--makes the first table's elements into the elements of the second table.
    function w._private.upd_update_cb()
	awful.spawn.easy_async_with_shell(command, function(out)
                output = string.sub(out,0,-2)
                if string.len(output) < 1 then
                    w:set_markup(('[<span foreground="#00FF00">没有</span>更新]'))-- no update, méi yǒu gēng xīn
                    updatesneeded = 0
                else
                    w:set_markup(('[<span foreground="#FF0000">有</span>更新]'))-- there is update, yǒu gēng xīn
                    if updatesneeded == 0 then
                        --notify only on the first time it detects a software updatea
                        naughty.notify({title="UPDATES NEEDED",text=output});
                        updatesneeded=1
                    end             
                    
                end
    	end)

        w._timer:again()
        return true -- Continue the timer
    end

    w._timer = timer.weak_start_new(3600, w._private.upd_update_cb)-- starts timer
    w:force_update()-- run now so we don't have to wait 30 seconds for the first update
    return w
end

function upd:__call(...)
    return new(...)
end

return setmetatable(upd, upd)
