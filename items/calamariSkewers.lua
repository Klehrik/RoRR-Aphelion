-- Calamari Skewers

local sprite = Resources.sprite_load("aphelion", "item/calamariSkewers", PATH.."assets/sprites/items/calamariSkewers.png", 1, 16, 16)

local item = Item.new("aphelion", "calamariSkewers")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:add_callback("onPickup", function(actor, stack)
    local actorData = actor:get_data("calamariSkewers")
    actorData.cooldown = 0
    if not actorData.timers then actorData.timers = {} end
end)

item:add_callback("onKill", function(actor, victim, damager, stack)
    local actorData = actor:get_data("calamariSkewers")
    if actorData.cooldown <= 0 then
        actor:buff_apply(Buff.find("aphelion-calamariSkewers"), 1)
    end
end)

item:add_callback("onStep", function(actor, stack)
    local actorData = actor:get_data("calamariSkewers")
    if actorData.cooldown > 0 then
        actorData.cooldown = actorData.cooldown - 1
    end
end)



-- Buff

local sprite = Resources.sprite_load("aphelion", "buff/calamariSkewers", PATH.."assets/sprites/buffs/calamariSkewers.png", 1, 6, 8)

local buff = Buff.new("aphelion", "calamariSkewers")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = true
buff.max_stack = 4
buff.is_timed = false

buff:onApply(function(actor, stack)
    local actorData = actor:get_data("calamariSkewers")
    table.insert(actorData.timers, 60)
end)

buff:onStep(function(actor, stack)
    local actorData = actor:get_data("calamariSkewers")

    -- Decrease stack timers
    -- and remove if expired
    for i, time in ipairs(actorData.timers) do
        actorData.timers[i] = time - 1
        if time <= 0 then table.remove(actorData.timers, i) end
    end

    -- Check if 4 kills within 1 second has been achieved
    if #actorData.timers >= 4 then
        local item_stack = actor:item_stack_count(item)
        actor:heal((item_stack * 20) + ((actor.maxhp - actor.hp) * 0.1))
        actorData.cooldown = 2 *60
        actorData.timers = {}
    end

    -- Remove buff stacks if more than table size
    if stack > #actorData.timers then actor:buff_remove(buff, stack - #actorData.timers) end
end)