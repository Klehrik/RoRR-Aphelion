-- Huntress : Stealth Stalking

local callbacks = {}



-- Skill
local survivor_loadout_unlockables = gm.variable_global_get("survivor_loadout_unlockables")

local survivor = gm.array_get(Class.SURVIVOR, gm.survivor_find("ror-huntress"))
local v_family = gm.array_get(survivor, 9).elements

local new = gm.struct_create()
gm.static_set(new, gm.static_get(gm.array_get(v_family, 0)))
new.skill_id = gm.skill_create("aphelion", "huntressStealthBoosted")
new.achievement_id = -1.0
new.save_flag_viewed = nil
new.index = gm.array_length(survivor_loadout_unlockables)

local skill = survivor_setup.Skill(new.skill_id)
Survivor.setup_skill(skill,
    "skill.huntressStealthBoosted.name",
    "skill.huntressStealthBoosted.description",
    gm.constants.sHuntressSkills,
    0,
    gm.constants.sBanditShoot4,
    15 *60.0,
    0.0,
    false,
    new.skill_id + 1
)
skill.require_key_press = false
skill.does_change_activity_state = false
skill.is_utility = true
skill.required_interrupt_priority = 2.0

-- Skill on_activate
table.insert(callbacks, {skill.on_activate, function(self, other, result, args)
    Buff.apply(self, Buff.find("aphelion-huntressStealthBoosted"), 5 *60.0)

    local smoke = gm.instance_create_depth(self.x, self.y, 0, gm.constants.oEfBullet2)
    smoke.sprite_index = gm.constants.sBanditShoot3
    smoke.image_speed = 0.3
    smoke.image_yscale = 1
    gm.sound_play_at(gm.constants.wWispSpawn, 1.0, 1.5, self.x, self.y, nil)
end})



-- Buff

local crit_boost = 30.0
local speed_boost = 2.8 * 0.30

local buff = Buff.create("aphelion", "huntressStealthBoosted")
Buff.set_property(buff, Buff.PROPERTY.show_icon, false)

Buff.add_callback(buff, "onApply", function(actor, stack)
    actor.image_alpha = 0.5
    actor.is_targettable = false
    gm.instance_destroy(actor.target_marker)
    actor.target_marker = -4.0

    local amount = actor.damage * 0.30
    actor.damage_base = actor.damage_base + amount
    if not actor.aphelion_huntressStealth_damage_boost_2 then actor.aphelion_huntressStealth_damage_boost_2 = 0 end
    actor.aphelion_huntressStealth_damage_boost_2 = actor.aphelion_huntressStealth_damage_boost_2 + amount

    actor.critical_chance_base = actor.critical_chance_base + crit_boost
    actor.pHmax_base = actor.pHmax_base + speed_boost
end)

Buff.add_callback(buff, "onRemove", function(actor, stack)
    actor.image_alpha = 1.0
    actor.is_targettable = true
    actor.target_marker = gm.instance_create_depth(0, 0, 0, gm.constants.oActorTargetPlayer)
    actor.target_marker.parent = actor

    actor.damage_base = actor.damage_base - actor.aphelion_huntressStealth_damage_boost_2
    actor.aphelion_huntressStealth_damage_boost_2 = nil

    actor.critical_chance_base = actor.critical_chance_base - crit_boost
    actor.pHmax_base = actor.pHmax_base - speed_boost

    local smoke = gm.instance_create_depth(actor.x, actor.y, 0, gm.constants.oEfBullet2)
    smoke.sprite_index = gm.constants.sBanditShoot3
    smoke.image_speed = 0.3
    smoke.image_yscale = 1
    gm.sound_play_at(gm.constants.wWispSpawn, 1.0, 1.5, actor.x, actor.y, nil)
end)



-- ========== Hooks ==========

gm.post_script_hook(gm.constants.callback_execute, function(self, other, result, args)
    for _, c in ipairs(callbacks) do
        if args[1].value == c[1] then
            c[2](self, other, result, args)
        end
    end
end)