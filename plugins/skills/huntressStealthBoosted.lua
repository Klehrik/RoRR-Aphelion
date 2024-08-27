-- Huntress : Stealth Stalking

local callbacks = {}

-- TODO: Add upgraded ver

local class_survivor = gm.variable_global_get("class_survivor")
local survivor_loadout_unlockables = gm.variable_global_get("survivor_loadout_unlockables")
local class_actor_state = gm.variable_global_get("class_actor_state")

local v_family = class_survivor[gm.survivor_find("ror-huntress") + 1][10].elements

local new = gm.struct_create()

gm.static_set(new, gm.static_get(v_family[1]))

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
    14 *60.0,
    0.0,
    false,
    new.skill_id + 1
)
skill.require_key_press = false
skill.does_change_activity_state = false
skill.is_utility = true

-- Skill on_activate
table.insert(callbacks, {skill.on_activate, function(self, other, result, args)
    Buff.apply(self, Buff.find("aphelion-huntressStealthBoosted"), 4 *60.0)
end})



-- Buff

local buff = Buff.create("aphelion", "huntressStealthBoosted")
Buff.set_property(buff, Buff.PROPERTY.show_icon, false)

Buff.add_callback(buff, "onApply", function(actor, stack)
    actor.image_alpha = 0.5
    actor.is_targettable = false
    gm.instance_destroy(actor.target_marker)
    actor.target_marker = -4.0

    local amount = actor.damage * 0.3
    actor.damage_base = actor.damage_base + amount
    if not actor.aphelion_huntressStealth_damage_boost_2 then actor.aphelion_huntressStealth_damage_boost_2 = 0 end
    actor.aphelion_huntressStealth_damage_boost_2 = actor.aphelion_huntressStealth_damage_boost_2 + amount

    local amount = actor.critical_chance * 0.3
    actor.critical_chance_base = actor.critical_chance_base + amount
    if not actor.aphelion_huntressStealth_critical_chance_boost then actor.aphelion_huntressStealth_critical_chance_boost = 0 end
    actor.aphelion_huntressStealth_critical_chance_boost = actor.aphelion_huntressStealth_critical_chance_boost + amount

    local amount = actor.pHmax * 0.3
    actor.pHmax_base = actor.pHmax_base + amount
    if not actor.aphelion_huntressStealth_pHmax_boost then actor.aphelion_huntressStealth_pHmax_boost = 0 end
    actor.aphelion_huntressStealth_pHmax_boost = actor.aphelion_huntressStealth_pHmax_boost + amount
end)

Buff.add_callback(buff, "onRemove", function(actor, stack)
    actor.image_alpha = 1.0
    actor.is_targettable = true
    actor.target_marker = gm.instance_create_depth(0, 0, 0, gm.constants.oActorTargetPlayer)
    actor.target_marker.parent = actor

    actor.damage_base = actor.damage_base - actor.aphelion_huntressStealth_damage_boost_2
    actor.aphelion_huntressStealth_damage_boost_2 = nil

    actor.critical_chance_base = actor.critical_chance_base - actor.aphelion_huntressStealth_critical_chance_boost
    actor.aphelion_huntressStealth_critical_chance_boost = nil

    actor.pHmax_base = actor.pHmax_base - actor.aphelion_huntressStealth_pHmax_boost
    actor.aphelion_huntressStealth_pHmax_boost = nil
end)



-- ========== Hooks ==========

gm.post_script_hook(gm.constants.callback_execute, function(self, other, result, args)
    for _, c in ipairs(callbacks) do
        if args[1].value == c[1] then
            c[2](self, other, result, args)
        end
    end
end)