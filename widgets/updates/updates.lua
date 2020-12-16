---------------------------------------------------------------------------
-- 
-- Going to rig a widget that will let me know if pacman has any updates for packages tonight
-- Changed to use the checkupdates command introduced by pacman-contrib, this solves the need to update databases(change system)
-- TODO: would like to make the hover dropdown show what needs updating
--  n-Il  12/16/2020
--
---------------------------------------------------------------------------

local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local gtable = require("gears.table")
local awful = require("awful")
local naughty = require("naughty")
local updatesneeded = 0
--local command = "pacman -Qu"
local command = "checkupdates"
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
                -- debug naughty.notify({title="UPDATES",text=output});
                if string.len(output) < 1 then
                    w:set_markup(('[<span foreground="#00FF00">没有</span>更新]'))-- no update, méi yǒu gēng xīn
                    updatesneeded = 0
                else
                    w:set_markup(('[<span foreground="#FF0000">有</span>更新]'))-- there is update, yǒu gēng xīn
                    if updatesneeded == 0 then
                        --notify only on the first time it detects a software updatea
                        naughty.notify({title="UPDATES NEEDED",text=output,timeout=60});
                        updatesneeded=1
                    end             
                end
    	end)

        w._timer:again()
        return true -- Continue the timer
    end

    w._timer = timer.weak_start_new(60, w._private.upd_update_cb)-- starts timer
    w:force_update()
    return w
end

function upd:__call(...)
    return new(...)
end

return setmetatable(upd, upd)
