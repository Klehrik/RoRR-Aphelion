-- Calamari Skewers

local sprite = Resources.sprite_load(PATH.."assets/sprites/calamariSkewers.png", 1, 16, 16)

local item = Item.new("aphelion", "calamariSkewers")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:add_callback("onPickup", function(actor, stack)
    local actor_data = actor:get_data("aphelion-calamariSkewers")
    actor_data.cooldown = 0
    if not actor_data.timers then actor_data.timers = {} end
end)

item:add_callback("onKill", function(actor, victim, damager, stack)
    local actor_data = actor:get_data("aphelion-calamariSkewers")
    if actor_data.cooldown <= 0 then
        actor:buff_apply(Buff.find("aphelion-calamariSkewers"), 1)
    end
end)

item:add_callback("onStep", function(actor, stack)
    local actor_data = actor:get_data("aphelion-calamariSkewers")
    if actor_data.cooldown > 0 then
        actor_data.cooldown = actor_data.cooldown - 1
    end
end)



-- Buff

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffCalamariSkewers.png", 1, 6, 8)

local buff = Buff.new("aphelion", "calamariSkewers")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = true
buff.max_stack = 4
buff.is_timed = false

buff:onApply(function(actor, stack)
    local actor_data = actor:get_data("aphelion-calamariSkewers")
    table.insert(actor_data.timers, 60)
end)

buff:onStep(function(actor, stack)
    local actor_data = actor:get_data("aphelion-calamariSkewers")

    -- Decrease stack timers
    -- and remove if expired
    for i, time in ipairs(actor_data.timers) do
        actor_data.timers[i] = time - 1
        if time <= 0 then table.remove(actor_data.timers, i) end
    end

    -- Check if 4 kills within 1 second has been achieved
    if #actor_data.timers >= 4 then
        local item_stack = actor:item_stack_count(item)
        actor:heal((item_stack * 20) + ((actor.maxhp - actor.hp) * 0.1))
        actor_data.cooldown = 2 *60
        actor_data.timers = {}
    end

    -- Remove buff stacks if more than table size
    if stack > #actor_data.timers then actor:buff_remove(buff, stack - #actor_data.timers) end
end)