--[[

Simple brightness display and control widget built on Arch Linux to display brightness percentage.
n-Il 06/14/2020)

Known Issues:
If you use other brightness hotkeys or tools, this will only pick up their changes every 30 seconds, so beware
Relies on xbacklight. Alternatively; I could have used udev to give my user permission to write to backlight
this is (REALLY)inefficient, for example we set cur,per,max on every change, when we realistically could just store those values
    - on this topic, I would rebuild this with a slider to allow for quicker changes requiring less calls
]]

local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local gtable = require("gears.table")
local awful = require("awful")

local getBri = "bri=$(cat /sys/class/backlight/intel_backlight/brightness);max=$(cat /sys/class/backlight/intel_backlight/max_brightness);echo $(($bri * 100/$max))"
--Commands need to run in order to prevent a mismatch information and reality,so it's easiest to run them into the shell in order
local commands = {
get= getBri
,raise = [[
cur=$(cat /sys/class/backlight/intel_backlight/brightness);
max=$(cat /sys/class/backlight/intel_backlight/max_brightness);
per=$(($max / 100));
if test $cur = $max;
     then :;
elif test $max -lt $(($cur + $(($per * 5))));
    then $(xbacklight -set 100);
else $(xbacklight -inc 5);
fi]]..";"..getBri
,lower = [[ 
cur=$(cat /sys/class/backlight/intel_backlight/brightness);
max=$(cat /sys/class/backlight/intel_backlight/max_brightness);
per=$(($max / 100));
if test $cur -le $((5*$per));
     then :;
elif test $((5*$per)) -gt $(($cur - $(($per*5))));
    then $(xbacklight -set 5);
else $(xbacklight -dec 5);
fi]]..";"..getBri
}

local brightness = {}

-- Force  brightness to update now.
function brightness:force_update()
    self._timer:emit_signal("timeout")
end

--de-duplicate code, passing in w and command name, then runs this command and updates w(w is our textbox)
local function runCommand(w,command)
    awful.spawn.easy_async_with_shell(commands[command], function(out)
     	w:set_markup(('['..utf8.char(9788)--[[128262 for brightness symbol]]..':'..string.sub(out,0,-2)..'%]'))-- sets the markup for the widget to the output of our command. Sub to remove newline
    end) 

end


-- function
local function new() -- format
    local w = textbox()
    w:buttons(
        awful.util.table.join(
            awful.button({},4,function()
                --on up(outward) scroll, raise brightness
                runCommand(w,"raise")
            end),
            awful.button({},5,function()
                --on down(inward) scroll, lower brightness
                runCommand(w,"lower")
            end),
            awful.button({},1,function()
                --on left click, raise brightness
                runCommand(w,"raise")
            end),
            awful.button({},3,function()
                --on right click lower brightness
                runCommand(w,"lower")
            end)
        )
    )
    
    gtable.crush(w, brightness, true)--makes the first table's elements into the elements of the second table.
    
    
    function w._private.brightness_update_cb()
        runCommand(w,"get")
        w._timer:again()
        return true -- Continue the timer
    end
    

    w._timer = timer.weak_start_new(30, w._private.brightness_update_cb)-- starts timer
    w:force_update()-- run now so we don't have to wait 30 seconds for the first update
    return w
end

function brightness:__call(...)
    return new(...)
end

return setmetatable(brightness, brightness)
