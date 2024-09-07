-- Crimson Scarf

local sprite = Resources.sprite_load(PATH.."assets/sprites/crimsonScarf.png", 1, false, false, 16, 16)

local item = Item.new("aphelion", "crimsonScarf")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:add_callback("onKill", function(actor, victim, stack)
    actor:buff_apply(Buff.find("aphelion-crimsonScarf"), 1)
end)



-- Buff

local crit = 6.0

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffCrimsonScarf.png", 1, false, false, 7, 9)

local buff = Buff.new("aphelion", "crimsonScarf")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = true
buff.stack_number_col = Array.new(1, 3937500)
buff.max_stack = 999
buff.is_timed = false

buff:onApply(function(actor, stack)
    if not actor.aphelion_crimsonScarf_timers then actor.aphelion_crimsonScarf_timers = List.new() end
    List.wrap(actor.aphelion_crimsonScarf_timers):add((4 + actor:item_stack_count(item)) * 60.0)
    actor.critical_chance_base = actor.critical_chance_base + crit
end)

buff:onStep(function(actor, stack)
    -- Decrease stack timers
    local list = List.wrap(actor.aphelion_crimsonScarf_timers)
    for i, time in ipairs(list) do
        time = time - 1
        list[i] = time
    end

    -- Remove oldest stack if expired
    local time = list:get(0)
    if time and time <= 0 then list:delete(0) end

    -- Remove buff stacks if more than ds_list size
    local size = list:size()
    if stack > size then
        local diff = stack - size
        actor:buff_remove(buff, diff)
        actor.critical_chance = actor.critical_chance - (crit * diff)
        actor.critical_chance_base = actor.critical_chance_base - (crit * diff)
    end
end)