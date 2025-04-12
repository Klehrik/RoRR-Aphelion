-- Aphelion

mods["LuaENVY-ENVY"].auto()
mods["ReturnsAPI-ReturnsAPI"].auto{
    namespace = "aphelion"
}

local fn = function()
    hotloaded = true
    require("./items/ballisticVest.lua")
    require("./items/overloadedCapacitor.lua")
end
Initialize(fn)
if hotloaded then fn() end