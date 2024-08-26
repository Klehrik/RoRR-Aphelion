-- Bandit Unload

local callbacks = {}



-- Add new Bandit X skill
local class_survivor = gm.variable_global_get("class_survivor")
local survivor_loadout_unlockables = gm.variable_global_get("survivor_loadout_unlockables")
local class_actor_state = gm.variable_global_get("class_actor_state")

-- Array of SurvivorSkillLoadoutUnlockable
local x_family = class_survivor[gm.survivor_find("ror-bandit") + 1][8].elements

-- Create new struct
local new = gm.struct_create()

-- Since we can't use GameMaker constructors, copy all static variables from a pre-existing SurvivorSkillLoadoutUnlockable
-- These static variables don't appear in ObjectBrowser
gm.static_set(new, gm.static_get(x_family[1]))

-- Set normal struct variables
new.skill_id = gm.skill_create("aphelion", "banditUnload")
new.achievement_id = -1.0
new.save_flag_viewed = nil
new.index = gm.array_length(survivor_loadout_unlockables)

-- Push to survivor skill array and global survivor_loadout_unlockables
gm.array_push(survivor_loadout_unlockables, new)
gm.array_push(x_family, new)

local skill = survivor_setup.Skill(new.skill_id)
Survivor.setup_skill(skill,
    "skill.banditUnload.name",
    "skill.banditUnload.description",
    gm.constants.sBanditSkills,
    8,
    gm.constants.sBanditShoot4,
    3 *60.0,
    3.0,
    false,
    new.skill_id + 1
)
skill.require_key_press = false
skill.max_stock = 6

local state = gm.actor_state_create(
    "aphelion",
    "banditUnload",
    gm.array_length(actor_states)
)

-- Skill on_activate
table.insert(callbacks, {skill.on_activate, function(self, other, result, args)
    self:actor_set_state(self, state)
end})

-- State on_enter
table.insert(callbacks, {class_actor_state[state + 1][3], function(self, other, result, args)
    self.sprite_index = gm.constants.sBanditShoot4
    self.image_index = 0
    self.image_speed = 0.22

    if self.aphelion_banditUnload_just_used then self.image_index = 4
    else self:sound_play_at(gm.constants.wBanditShoot4_1, 1.0, 1.0, self.x, self.y, nil)
    end
end})

-- State on_exit
table.insert(callbacks, {class_actor_state[state + 1][4], function(self, other, result, args)
    self.aphelion_banditUnload_just_used = 2
    self.aphelion_banditUnload_shot = nil
end})

-- State on_step
table.insert(callbacks, {class_actor_state[state + 1][5], function(self, other, result, args)
    if self.image_index >= 5 and not self.aphelion_banditUnload_shot then
        self.aphelion_banditUnload_shot = true
        self:sound_play_at(gm.constants.wBanditShoot4_2, 1.0, 1.0, self.x, self.y, nil)
        self:sound_play_at(gm.constants.wGuardDeathOLD, 0.25, 1.85 + gm.random(0.15), self.x, self.y, nil)
        self:sound_play_at(gm.constants.wBullet2, 1.0, 1.0, self.x, self.y, nil)

        Actor.fire_bullet(self, self.x, self.y, 90 - (90 * gm.sign(self.image_xscale)), 1400.0, 3.0, nil, gm.constants.sSparks15)
    end

    -- Skip end of animation if queueing another bullet
    if self.x_skill and self.image_index >= 7 and self:actor_get_skill_slot(1).active_skill.stock >= 1.0 then
        self.image_index = 9
    end

    self:skill_util_apply_friction()
    self:skill_util_exit_state_on_anim_end()
end})

Actor.add_callback("onPreStep", function(actor)
    if actor.aphelion_banditUnload_just_used
    and actor.aphelion_banditUnload_just_used > 0 then
        actor.aphelion_banditUnload_just_used = actor.aphelion_banditUnload_just_used - 1
        if actor.aphelion_banditUnload_just_used <= 0 then actor.aphelion_banditUnload_just_used = nil end
    end
end)

Actor.add_callback("onKill", function(actor, damager)
    if actor:actor_get_skill_slot(1).active_skill.name == "skill.banditUnload.name" then
        actor:actor_skill_add_stock(actor, 1, false, 1)     -- slot, ignore cap, raw value
    end
end)



gm.post_script_hook(gm.constants.callback_execute, function(self, other, result, args)
    for _, c in ipairs(callbacks) do
        if args[1].value == c[1] then
            c[2](self, other, result, args)
        end
    end
end)