-- Misc

-- Huntress : Set Stealth Hunting upgrade
Skill.find("aphelion-huntressStealth").upgrade_skill = Skill.find("aphelion-huntressStealthBoosted")

-- Huntress : Grant 15 i-frames on Blink
Player:onSkillUse("aphelion-huntressBlinkTweak", function(actor)
    actor:set_immune(15)
end, Skill.find("ror-huntressC"))