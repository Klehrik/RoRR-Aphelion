-- Huntress : Stealth Stalking

local function create_smoke(actor)
    local smoke = Object.find("ror-efBullet2"):create(actor.x, actor.y)
    smoke.sprite_index = gm.constants.sBanditShoot3
    smoke.image_speed = 0.3
    smoke.image_yscale = 1
    actor:sound_play_at(gm.constants.wWispSpawn, 1.0, 1.5, actor.x, actor.y, nil)
end



-- Skill

-- local sprite = Resources.sprite_load("aphelion", "ballisticVest", PATH.."assets/sprites/ballisticVest.png", 1, 16, 16)

local skill = Skill.new("aphelion", "huntressStealthBoosted")
skill:set_skill_icon(gm.constants.sHuntressSkills, 1)
skill:set_skill_properties(0.0, 14 *60)
skill:set_skill_stock(1, 1, true, 1)
skill:set_skill_settings(
    true, false, 2,
    false, false,
    false, false,
    false
)

skill:onActivate(function(actor, skill, index)
    actor:buff_apply(Buff.find("aphelion-huntressStealthBoosted"), 4 *60.0)

    create_smoke(actor)
end)



-- Buff

local buff = Buff.new("aphelion", "huntressStealthBoosted")
buff.show_icon = false

buff:onApply(function(actor, stack)
    actor.image_alpha = 0.5
    actor.is_targettable = false
    actor.target_marker:destroy()
    actor.target_marker = -4.0
end)

buff:onRemove(function(actor, stack)
    actor.image_alpha = 1.0
    actor.is_targettable = true
    actor.target_marker = Object.find("ror-actorTargetPlayer"):create()
    actor.target_marker.parent = actor

    create_smoke(actor)
end)

buff:onStatRecalc(function(actor, stack)
    actor.critical_chance = actor.critical_chance + 30.0
    actor.pHmax = actor.pHmax + (0.3 * 2.8)
end)

buff:onPostStatRecalc(function(actor, stack)
    actor.damage = actor.damage * 1.3
end)