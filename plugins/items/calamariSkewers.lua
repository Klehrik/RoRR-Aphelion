-- Calamari Skewers

local sprite = Resources.sprite_load(PATH.."assets/sprites/calamariSkewers.png", 1, false, false, 16, 16)

local item = Item.new("aphelion", "calamariSkewers")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:add_callback("onPickup", function(actor, stack)
    actor.aphelion_calamariSkewers_cooldown = 0
    if not actor.aphelion_calamariSkewers_timers then actor.aphelion_calamariSkewers_timers = List.new() end
end)

item:add_callback("onKill", function(actor, victim, damager, stack)
    if actor.aphelion_calamariSkewers_cooldown <= 0 then
        actor:buff_apply(Buff.find("aphelion-calamariSkewers"), 1)
    end
end)

item:add_callback("onStep", function(actor, stack)
    if actor.aphelion_calamariSkewers_cooldown > 0 then
        actor.aphelion_calamariSkewers_cooldown = actor.aphelion_calamariSkewers_cooldown - 1
    end
end)



-- Buff

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffCalamariSkewers.png", 1, false, false, 6, 8)

local buff = Buff.new("aphelion", "calamariSkewers")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = true
buff.max_stack = 4
buff.is_timed = false

buff:onApply(function(actor, stack)
    List.wrap(actor.aphelion_calamariSkewers_timers):add(60)
end)

buff:onStep(function(actor, stack)
    -- Decrease stack timers
    local list = List.wrap(actor.aphelion_calamariSkewers_timers)
    for i, time in ipairs(list) do
        time = time - 1
        list[i] = time
    end

    -- Remove oldest stack if expired
    local time = list:get(0)
    if time and time <= 0 then list:delete(0) end

    -- Check if 4 kills within 1 second has been achieved
    local size = list:size()
    if size >= 4 then
        local item_stack = actor:item_stack_count(Item.find("aphelion-calamariSkewers"))
        actor:heal((item_stack * 20) + ((actor.maxhp - actor.hp) * 0.1))
        actor.aphelion_calamariSkewers_cooldown = 2 *60
        list:clear()
    end

    -- Remove buff stacks if more than ds_list size
    if stack > size then actor:buff_remove(buff, stack - size) end
end)