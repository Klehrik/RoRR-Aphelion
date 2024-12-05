-- War Drum

local sprite = Resources.sprite_load("aphelion", "item/warDrum", PATH.."assets/sprites/items/warDrum.png", 1, 17, 16)

local item = Item.new("aphelion", "warDrum")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_healing, Item.LOOT_TAG.category_utility)

item:onAcquire(function(actor, stack)
    if stack == 1 then actor:get_data("warDrum").alpha = 0 end
end)

item:onHitProc(function(actor, victim, stack, hit_info)
    local actorData = actor:get_data("warDrum")

    -- Reset kill timer
    actorData.item_stack = stack
    actorData.timer = 5 *60

    -- Apply buff (if haven't already)
    local buff = Buff.find("aphelion-warDrumBuff")
    if actor:buff_stack_count(buff) <= 0 then
        actorData.frame = 0
        actorData.alpha = 0
        actor:buff_apply(buff, 1, 1)
    end
end)

item:onPreDraw(function(actor, stack)
    local actorData = actor:get_data("warDrum")

    -- Pulse ring
    if actorData.alpha > 0 then
        actorData.radius = actorData.radius + actorData.radius_inc
        actorData.alpha = actorData.alpha - 1/60

        local c = Color.WHITE
        gm.draw_set_alpha(actorData.alpha)
        gm.draw_circle_color(actor.x, actor.y, actorData.radius, c, c, true)
        gm.draw_set_alpha(1)
    end
end)



-- Buff

local sound = Resources.sfx_load("aphelion", "warDrum", PATH.."assets/sounds/warDrum.ogg")

local buff = Buff.new("aphelion", "warDrumBuff")
buff.show_icon = false
buff.max_stack = 25
buff.is_timed = false

local function pulse(actor)
    if not actor:exists() then return end
    local stack = actor:buff_stack_count(buff)
    if stack <= 0 then return end

    local actorData = actor:get_data("warDrum")
    actorData.radius = 0
    actorData.radius_inc = 0.75 + (stack/5 * 0.25)
    actorData.alpha = 1
    actor:sound_play_at(sound, 0.25 + (stack/5 * 0.1), 1.0 + gm.random_range(-0.25, 0.25), actor.x, actor.y)

    actorData.alarm = Alarm.create(pulse, 5 *60, actor)
end

buff:onApply(function(actor, stack)
    local actorData = actor:get_data("warDrum")
    if stack == 1 then
        Alarm.destroy(actorData.alarm)
        actorData.alarm = Alarm.create(pulse, 5 *60, actor)
    end
end)

buff:onPostStatRecalc(function(actor, stack)
    local actorData = actor:get_data("warDrum")
    local max = 0.035 + (actorData.item_stack * 0.035)
    local val = 1 + (stack/buff.max_stack * max)

    actor.damage = actor.damage * val
    actor.attack_speed = actor.attack_speed * val
    actor.pHmax = actor.pHmax * val
    actor.critical_chance = actor.critical_chance * val
    actor.hp_regen = actor.hp_regen * val
    actor.armor = actor.armor * val
    -- actor.maxhp = gm.round(actor.maxhp * val)    -- Removing these because goofy stuff happens
    -- actor.maxshield = gm.round(actor.maxshield * val)
end)

buff:onPostStep(function(actor, stack)
    local actorData = actor:get_data("warDrum")

    -- Increment buff
    if stack < 25 then
        actorData.frame = actorData.frame + 1
        if actorData.frame >= 60 then
            actorData.frame = 0
            actor:buff_apply(buff, 1, 1)
        end
    end

    -- Decrement kill timer
    actorData.timer = actorData.timer - 1
    if actorData.timer <= 0 then
        actor:buff_remove(buff, 1)
    end
end)



-- Achievement
item:add_achievement()

Item.find("ror-warbanner"):onAcquire(function(actor, stack)
    if item:is_unlocked() then return end

    if actor:callback_exists("aphelion-warDrumUnlock") then return end
    local actorData = actor:get_data("warDrum")
    actorData.kills = 0
    actorData.add_kills = false

    actor:onKillProc("aphelion-warDrumUnlock", function(actor, victim, stack)
        local actorData = actor:get_data("warDrum")
        if not actorData.add_kills then return end

        actorData.kills = actorData.kills + 1
        if actorData.kills >= 25 then
            item:progress_achievement()
            actor:remove_callback("aphelion-warDrumUnlock")
        end
    end)
end)

Buff.find("ror-warbanner"):onApply(function(actor, stack)
    local actorData = actor:get_data("warDrum")
    actorData.add_kills = true
end)

Buff.find("ror-warbanner"):onRemove(function(actor, stack)
    -- Reset on buff loss
    local actorData = actor:get_data("warDrum")
    actorData.kills = 0
    actorData.add_kills = false
end)