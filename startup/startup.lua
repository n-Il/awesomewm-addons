-- Created n-Il 12/14/2019
-- Improved n-Il 05/31/2020
-- place this in ~/.config/awesome/startup.lua
-- add require("startup")() to the end of  rc.lua
-- 


-- startup = require("awesomewm-startup")
-- startup.startups()
awful = require("awful")
naughty = require("naughty")
gears = require("gears")
os = require("os")
local startup = {}

function new()	
	local notlua = io.open(os.getenv("HOME").."/.WMstartup","r") 
	if notlua == nil then 
		naughty.notify({preset = naughty.config.presets.critical,title = "awesomewm-startup Error",text = ".WMstartup not found"})
		return nil 
	end

	-- read this file's lines in ignoring # lines, and then add a table to the table with these three values screen,tag, and program
	for line in notlua:lines() do
		if (line ~= nil and line ~='') and (line:match('(%s*#+.*)') == nil) 
		then
			if line:match('^(\'.*\',\'.*\',\'.*\')$') == null then
			-- I'm bad at lua
				naughty.notify({preset = naughty.config.presets.critical,title = "awesomewm-startup Error",text = "Issue with formatting:"..line })
			else
				local screen,tag,program = line:match('^\'(.*)\',\'(.*)\',\'(.*)\'$')
				naughty.notify({preset = naughty.config.presets.low,--change to critical for debugging
				title = "awesomewm-startup",text = "Starting "..program.."\nScreen:"..screen.."\nTag:"..tag })
				awful.spawn(program,{tag = tag,screen = tonumber(screen)})
			end
		end 
	end
-- iterate through startup-programs and run them
	return 0;
end

function startup:__call(...)
	return new(...)
end

return setmetatable(startup,startup)--I'm bad at lua
