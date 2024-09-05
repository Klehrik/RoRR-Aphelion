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
buff.stack_number_col = gm.array_create(1, 3937500)
buff.max_stack = 999
buff.is_timed = false

buff:add_callback("onApply", function(actor, stack)
    if not actor.aphelion_crimsonScarf_timers then actor.aphelion_crimsonScarf_timers = gm.ds_list_create() end
    gm.ds_list_add(actor.aphelion_crimsonScarf_timers, (4 + actor:item_stack_count(Item.find("aphelion-crimsonScarf"))) * 60.0)
    actor.critical_chance_base = actor.critical_chance_base + crit
end)

buff:add_callback("onStep", function(actor, stack)
    -- Decrease stack timers
    for i = 0, gm.ds_list_size(actor.aphelion_crimsonScarf_timers) - 1 do
        local new_time = gm.ds_list_find_value(actor.aphelion_crimsonScarf_timers, i) - 1
        gm.ds_list_set(actor.aphelion_crimsonScarf_timers, i, new_time)
    end

    -- Remove oldest stack if expired
    local first = gm.ds_list_find_value(actor.aphelion_crimsonScarf_timers, 0)
    if first and first <= 0 then
        gm.ds_list_delete(actor.aphelion_crimsonScarf_timers, 0)
    end

    -- Remove buff stacks if more than ds_list size
    local size = gm.ds_list_size(actor.aphelion_crimsonScarf_timers)
    if stack > size then
        local diff = stack - size
        actor:buff_remove(buff, diff)
        actor.critical_chance = actor.critical_chance - (crit * diff)
        actor.critical_chance_base = actor.critical_chance_base - (crit * diff)
    end
end)