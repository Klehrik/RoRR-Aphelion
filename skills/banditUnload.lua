-- Bandit : Unload

-- local sprite = Resources.sprite_load("aphelion", "ballisticVest", PATH.."assets/sprites/ballisticVest.png", 1, 16, 16)

local skill = Skill.new("aphelion", "banditUnload")
skill:set_skill_icon(gm.constants.sBanditSkills, 8)
skill:set_skill_properties(2.5, 4 *60)
skill:set_skill_stock(6, 6, true, 1)
skill:set_skill_settings(
    true, 0, 0,
    true, true,
    false, false,
    true
)
skill.require_key_press = false

skill:onActivate(function(actor, skill, index)
    actor:enter_state(State.find("aphelion-banditUnload"))
end)

Survivor.find("ror-bandit"):add_skill(skill, 2)



-- State

local state = State.new("aphelion", "banditUnload")

state:onEnter(function(actor, data)
    actor.sprite_index = gm.constants.sBanditShoot4
    actor.image_index = 0
    actor.image_speed = 0.22

    if actor:get_data("banditUnload").just_used then actor.image_index = 4
    else actor.value:sound_play_at(gm.constants.wBanditShoot4_1, 1.0, 1.0, actor.x, actor.y, nil)
    end
end)

state:onExit(function(actor, data)
    actor:get_data("banditUnload").just_used = 2

    data.shot = 0.0
    actor.value:skill_util_unlock_cooldown(skill.value)
end)

state:onStep(function(actor, data)
    if actor.image_index >= 5 and data.shot ~= 1.0 then
        data.shot = 1.0
        actor.value:sound_play_at(gm.constants.wBanditShoot4_2, 1.0, 1.0, actor.x, actor.y, nil)
        actor.value:sound_play_at(gm.constants.wGuardDeathOLD, 0.25, 1.85 + gm.random(0.15), actor.x, actor.y, nil)
        actor.value:sound_play_at(gm.constants.wBullet2, 1.0, 1.0, actor.x, actor.y, nil)

        actor:fire_bullet(
            actor.x, actor.y - 8,
            1400, 90 - (90 * gm.sign(actor.image_xscale)),
            actor.value:actor_get_skill_slot(1).active_skill.damage, nil, nil,
            nil, gm.constants.sSparks15
        )

        local xstart = actor.x + (16.0 * gm.sign(actor.image_xscale))
        local ystart = actor.y - 8
        local xend = actor.x + (1400.0 * gm.sign(actor.image_xscale))
        local yend = actor.y - 8
        local hit = gm.collision_line_advanced_bullet(xstart, ystart, xend, yend, true, false)
        if Instance.exists(hit) then
            xend = hit.bbox_left
            if actor.x > hit.x then xend = hit.bbox_right end
        end

        local tracer = Object.find("ror-efLineTracer"):create(xstart, ystart)
        tracer.xend = xend
        tracer.yend = yend
        tracer.bm = 1.0
        tracer.rate = 0.15
        tracer.width = 1.0
        tracer.sprite_index = 3682.0
        tracer.image_blend = 4434400.0

        local tracer = Object.find("ror-efBanditTracer"):create(xstart, ystart)
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
    if actor.x_skill and actor.image_index >= 7 and actor.value:actor_get_skill_slot(1).active_skill.stock >= 1.0 then
        actor.image_index = 9
    end

    actor.value:skill_util_lock_cooldown(skill.value)
    actor.value:skill_util_apply_friction()
    actor.value:skill_util_exit_state_on_anim_end()
end)

Actor:onPreStep(function(actor)
    local actorData = actor:get_data("banditUnload")
    if actorData.just_used and actorData.just_used > 0 then
        actorData.just_used = actorData.just_used - 1
        if actorData.just_used <= 0 then actorData.just_used = nil end
    end
end)

Actor:onKill(function(actor, damager)
    if actor.value:actor_get_skill_slot(1).active_skill.name == "skill.banditUnload.name" then
        actor.value:actor_skill_add_stock(actor.value, 1, false, 1)     -- actor, slot, ignore cap, raw value
    end
end)