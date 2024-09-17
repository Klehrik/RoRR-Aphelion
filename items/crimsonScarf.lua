-- Crimson Scarf

local sprite = Resources.sprite_load("aphelion", "crimsonScarf", PATH.."assets/sprites/crimsonScarf.png", 1, 16, 16)

local item = Item.new("aphelion", "crimsonScarf")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:add_callback("onKill", function(actor, victim, stack)
    actor:buff_apply(Buff.find("aphelion-crimsonScarf"), 1)
end)



-- Buff

local sprite = Resources.sprite_load("aphelion", "buffCrimsonScarf", PATH.."assets/sprites/buffCrimsonScarf.png", 1, 7, 9)

local buff = Buff.new("aphelion", "crimsonScarf")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = true
buff.stack_number_col = Array.new(1, Color(0xDC143C))
buff.max_stack = 999
buff.is_timed = false

buff:onApply(function(actor, stack)
    local actorData = actor:get_data("crimsonScarf")
    if not actorData.timers then actorData.timers = {} end
    table.insert(actorData.timers, (4 + actor:item_stack_count(item)) * 60.0)
end)

buff:onStep(function(actor, stack)
    local actorData = actor:get_data("crimsonScarf")

    -- Decrease stack timers
    -- and remove if expired
    for i, time in ipairs(actorData.timers) do
        actorData.timers[i] = time - 1
        if time <= 0 then table.remove(actorData.timers, i) end
    end

    -- Remove buff stacks if more than ds_list size
    if stack > #actorData.timers then
        local diff = stack - #actorData.timers
        actor:buff_remove(buff, diff)
        actor:recalculate_stats()
    end
end)

buff:onStatRecalc(function(actor, stack)
    actor.critical_chance = actor.critical_chance + (6 * stack)
end)