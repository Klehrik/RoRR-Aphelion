-- Bandit : Unload

local sprite = Resources.sprite_load("aphelion", "skill/test", PATH.."assets/sprites/skills/bandit.png", 1)

local skill = Skill.new("aphelion", "testSkill")
skill:set_skill_icon(sprite, 0)
skill:set_skill_properties(3.0, 1 *60)
skill:set_skill_stock(1, 1, true, 1)
skill:set_skill_settings(
    true, false, 0,
    true, true,
    false, false,
    true
)

skill:onCanActivate(function(actor, skill, index)
    log.info("^ onCanActivate")
end)

skill:onActivate(function(actor, skill, index)
    log.info("^ onActivate")
end)

skill:onPreStep(function(actor, skill, index)
    log.info("^ onPreStep")
end)

skill:onPostStep(function(actor, skill, index)
    actor.hp = actor.hp - 1
    log.info("^ onPostStep")
end)

skill:onEquipped(function(actor, skill, index)
    log.info("^ onEquipped")
end)

skill:onUnequipped(function(actor, skill, index)
    log.info("^ onUnequipped")
end)

Survivor.find("ror-commando"):add_skill(skill, Skill.SLOT.secondary)