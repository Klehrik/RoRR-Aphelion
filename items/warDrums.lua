-- War Drums

local sprite = Resources.sprite_load("aphelion", "item/ballisticVest", PATH.."assets/sprites/items/ballisticVest.png", 1, 16, 16)

local item = Item.new("aphelion", "warDrums")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_utility)

item:onHitProc(function(actor, victim, stack, hit_info)
    local actorData = actor:get_data("warDrums")

    -- Reset kill timer
    actorData.item_stack = stack
    actorData.timer = 5 *60

    -- Apply buff (if haven't already)
    local buff = Buff.find("aphelion-warDrumsBuff")
    if actor:buff_stack_count(buff) <= 0 then
        actorData.frame = 0
        actor:buff_apply(buff, 1, 1)
    end
end)



-- Buff

local sprite = Resources.sprite_load("aphelion", "buff/barrierDamage", PATH.."assets/sprites/buffs/bandana.png", 1, 7, 7)

local buff = Buff.new("aphelion", "warDrumsBuff")
buff.icon_sprite = sprite
buff.draw_stack_number = true
buff.max_stack = 25
buff.is_timed = false

buff:onPostStatRecalc(function(actor, stack)
    local actorData = actor:get_data("warDrums")
    local max = 0.04 + (actorData.item_stack * 0.03)
    local val = 1 + (stack/buff.max_stack * max)

    actor.damage = actor.damage * val
    actor.attack_speed = actor.attack_speed * val
    actor.critical_chance = actor.critical_chance * val
    actor.maxhp = gm.round(actor.maxhp * val)
    actor.maxshield = gm.round(actor.maxshield * val)
    actor.hp_regen = actor.hp_regen * val
    actor.armor = actor.armor * val
    actor.pHmax = actor.pHmax * val
end)

buff:onPostStep(function(actor, stack)
    local actorData = actor:get_data("warDrums")

    -- Increment buff
    actorData.frame = actorData.frame + 1
    if actorData.frame >= 60 then
        actorData.frame = 0
        actor:buff_apply(buff, 1, 1)
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

    if actor:callback_exists("aphelion-warDrumsUnlock") then return end
    local actorData = actor:get_data("warDrums")
    actorData.kills = 0
    actorData.add_kills = false

    actor:onKillProc("aphelion-warDrumsUnlock", function(actor, victim, stack)
        local actorData = actor:get_data("warDrums")
        if not actorData.add_kills then return end

        actorData.kills = actorData.kills + 1
        if actorData.kills >= 25 then
            item:progress_achievement()
            actor:remove_callback("aphelion-warDrumsUnlock")
        end
    end)
end)

Buff.find("ror-warbanner"):onApply(function(actor, stack)
    local actorData = actor:get_data("warDrums")
    actorData.add_kills = true
end)

Buff.find("ror-warbanner"):onRemove(function(actor, stack)
    -- Reset on buff loss
    local actorData = actor:get_data("warDrums")
    actorData.kills = 0
    actorData.add_kills = false
end)