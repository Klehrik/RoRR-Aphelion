-- Huntress : Stealth Hunting

local callbacks = {}

-- TODO: Add upgraded ver

local class_survivor = gm.variable_global_get("class_survivor")
local survivor_loadout_unlockables = gm.variable_global_get("survivor_loadout_unlockables")
local class_actor_state = gm.variable_global_get("class_actor_state")

local v_family = class_survivor[gm.survivor_find("ror-huntress") + 1][10].elements

local new = gm.struct_create()

gm.static_set(new, gm.static_get(v_family[1]))

new.skill_id = gm.skill_create("aphelion", "huntressStealth")
new.achievement_id = -1.0
new.save_flag_viewed = nil
new.index = gm.array_length(survivor_loadout_unlockables)

gm.array_push(survivor_loadout_unlockables, new)
gm.array_push(v_family, new)

local skill = survivor_setup.Skill(new.skill_id)
Survivor.setup_skill(skill,
    "skill.huntressStealth.name",
    "skill.huntressStealth.description",
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
    Buff.apply(self, Buff.find("aphelion-huntressStealth"), 4 *60.0)
end})



-- Buff

local buff = Buff.create("aphelion", "huntressStealth")
Buff.set_property(buff, Buff.PROPERTY.show_icon, false)

Buff.add_callback(buff, "onApply", function(actor, stack)
    actor.image_alpha = 0.5
    actor.is_targettable = false
    gm.instance_destroy(actor.target_marker)
    actor.target_marker = -4.0

    local damage = actor.damage * 0.35
    actor.damage_base = actor.damage_base + damage
    if not actor.aphelion_huntressStealth_damage_boost then actor.aphelion_huntressStealth_damage_boost = 0 end
    actor.aphelion_huntressStealth_damage_boost = actor.aphelion_huntressStealth_damage_boost + damage
end)

Buff.add_callback(buff, "onRemove", function(actor, stack)
    actor.image_alpha = 1.0
    actor.is_targettable = true
    actor.target_marker = gm.instance_create_depth(0, 0, 0, gm.constants.oActorTargetPlayer)
    actor.target_marker.parent = actor

    actor.damage_base = actor.damage_base - actor.aphelion_huntressStealth_damage_boost
    actor.aphelion_huntressStealth_damage_boost = nil
end)



-- ========== Hooks ==========

gm.post_script_hook(gm.constants.callback_execute, function(self, other, result, args)
    for _, c in ipairs(callbacks) do
        if args[1].value == c[1] then
            c[2](self, other, result, args)
        end
    end
end)