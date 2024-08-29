-- Bandit : Unload

local callbacks = {}



-- Skill
local survivor_loadout_unlockables = gm.variable_global_get("survivor_loadout_unlockables")

local survivor = gm.array_get(Class.SURVIVOR, gm.survivor_find("ror-bandit"))
local x_family = gm.array_get(survivor, 7).elements

local new = gm.struct_create()
gm.static_set(new, gm.static_get(gm.array_get(x_family, 0)))
new.skill_id = gm.skill_create("aphelion", "banditUnload")
new.achievement_id = -1.0
new.save_flag_viewed = nil
new.index = gm.array_length(survivor_loadout_unlockables)

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
local state_array = gm.array_get(Class.ACTOR_STATE, state)

-- Skill on_activate
table.insert(callbacks, {skill.on_activate, function(self, other, result, args)
    self:actor_set_state(self, state)
end})

-- State on_enter
table.insert(callbacks, {gm.array_get(state_array, 2), function(self, other, result, args)
    self.sprite_index = gm.constants.sBanditShoot4
    self.image_index = 0
    self.image_speed = 0.22

    if self.aphelion_banditUnload_just_used then self.image_index = 4
    else self:sound_play_at(gm.constants.wBanditShoot4_1, 1.0, 1.0, self.x, self.y, nil)
    end
end})

-- State on_exit
table.insert(callbacks, {gm.array_get(state_array, 3), function(self, other, result, args)
    self.aphelion_banditUnload_just_used = 2
    self.aphelion_banditUnload_shot = nil

    self:skill_util_unlock_cooldown(Actor.find_skill_id("aphelion-banditUnload"))
end})

-- State on_step
table.insert(callbacks, {gm.array_get(state_array, 4), function(self, other, result, args)
    self:skill_util_lock_cooldown(Actor.find_skill_id("aphelion-banditUnload"))

    if self.image_index >= 5 and not self.aphelion_banditUnload_shot then
        self.aphelion_banditUnload_shot = true
        self:sound_play_at(gm.constants.wBanditShoot4_2, 1.0, 1.0, self.x, self.y, nil)
        self:sound_play_at(gm.constants.wGuardDeathOLD, 0.25, 1.85 + gm.random(0.15), self.x, self.y, nil)
        self:sound_play_at(gm.constants.wBullet2, 1.0, 1.0, self.x, self.y, nil)

        Actor.fire_bullet(self, self.x, self.y - 8, 90 - (90 * gm.sign(self.image_xscale)), 1400.0, self:actor_get_skill_slot(1).active_skill.damage, nil, gm.constants.sSparks15)

        local xstart = self.x + (16.0 * gm.sign(self.image_xscale))
        local ystart = self.y - 8
        local xend = self.x + (1400.0 * gm.sign(self.image_xscale))
        local yend = self.y - 8
        local hit = gm.collision_line_advanced_bullet(xstart, ystart, xend, yend, true, false)
        if Instance.exists(hit) then
            xend = hit.bbox_left
            if self.x > hit.x then xend = hit.bbox_right end
        end

        local tracer = gm.instance_create_depth(xstart, ystart, -1, gm.constants.oEfLineTracer)
        tracer.xend = xend
        tracer.yend = yend
        tracer.bm = 1.0
        tracer.rate = 0.15
        tracer.width = 1.0
        tracer.sprite_index = 3682.0
        tracer.image_blend = 4434400.0

        local tracer = gm.instance_create_depth(xstart, ystart, -1, gm.constants.oEfBanditTracer)
        tracer.xend = xend
        tracer.yend = yend
        tracer.sprite_index = gm.constants.sBanditTracer
        tracer.blend_1 = 7719114.0
        tracer.blend_2 = 8421504.0
        tracer.blend_f = 1.0
        tracer.blend_rate = 0.5
        tracer.bm = 0.0
        tracer.max_rate = 0.5
        tracer.rate = 0.01
        tracer.width = 2.0
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
        actor:actor_skill_add_stock(actor, 1, false, 1)     -- actor, slot, ignore cap, raw value
    end
end)



-- ========== Hooks ==========

gm.post_script_hook(gm.constants.callback_execute, function(self, other, result, args)
    for _, c in ipairs(callbacks) do
        if args[1].value == c[1] then
            c[2](self, other, result, args)
        end
    end
end)