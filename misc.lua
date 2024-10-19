-- Misc

-- Thermite Flare : Change sprites for item log and achievement
local spr = GM.sprite_find("aphelion-equipment/thermiteFlareLast")
Item_Log.find("aphelion-thermiteFlare").sprite_id = spr
Achievement.find("aphelion-thermiteFlare").sprite_id = spr

-- Set special upgrades
Skill.find("aphelion-huntressStealth").upgrade_skill = Skill.find("aphelion-huntressStealthBoosted")
Skill.find("aphelion-sniperBlast").upgrade_skill = Skill.find("aphelion-sniperBlastBoosted")

-- Huntress : Grant 15 i-frames on Blink
Skill.find("ror-huntressC"):onActivate(function(actor, skill, index)
    actor:set_immune(15)
end)