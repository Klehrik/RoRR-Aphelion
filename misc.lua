-- Misc

-- Huntress : Set Stealth Hunting upgrade
Skill.find("aphelion-huntressStealth").upgrade_skill = Skill.find("aphelion-huntressStealthBoosted")

-- Huntress : Grant 15 i-frames on Blink
Skill.find("ror-huntressC"):onActivate(function(actor, skill, index)
    actor:set_immune(15)
end)