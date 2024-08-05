-- Crimson Scarf

local sprite = Resources.sprite_load(PATH.."/assets/sprites/crimsonScarf.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "crimsonScarf")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.uncommon)
Item.set_loot_tags(item, Item.LOOT_TAG.category_damage)

Item.add_callback(item, "onKill", function(attacker, victim, stack)
    Buff.apply(attacker, Buff.find("aphelion-crimsonScarf"), 1)
end)



-- Buff

local sprite = Resources.sprite_load(PATH.."/assets/sprites/buffCrimsonScarf.png", 1, false, false, 11, 11)

local buff = Buff.create("aphelion", "crimsonScarf")
Buff.set_property(buff, Buff.PROPERTY.icon_sprite, sprite)
Buff.set_property(buff, Buff.PROPERTY.icon_stack_subimage, false)
Buff.set_property(buff, Buff.PROPERTY.draw_stack_number, true)
Buff.set_property(buff, Buff.PROPERTY.max_stack, 999)
Buff.set_property(buff, Buff.PROPERTY.is_timed, false)

Buff.add_callback(buff, "onApply", function(actor, stack)
    if (not actor.aphelion_crimsonScarf_timers) or stack == 1 then actor.aphelion_crimsonScarf_timers = gm.ds_list_create() end
    gm.ds_list_add(actor.aphelion_crimsonScarf_timers, (4 + Item.get_stack_count(actor, Item.find("aphelion-crimsonScarf"))) * 60.0)
    actor.critical_chance_base = actor.critical_chance_base + 6.0
end)

Buff.add_callback(buff, "onStep", function(actor, stack)
    for i = 0, gm.ds_list_size(actor.aphelion_crimsonScarf_timers) - 1 do
        local new_time = gm.ds_list_find_value(actor.aphelion_crimsonScarf_timers, i) - 1
        gm.ds_list_set(actor.aphelion_crimsonScarf_timers, i, new_time)
    end

    -- Check if oldest stack has expired
    if gm.ds_list_find_value(actor.aphelion_crimsonScarf_timers, 0) <= 0 then
        gm.ds_list_delete(actor.aphelion_crimsonScarf_timers, 0)
        actor.critical_chance_base = actor.critical_chance_base - 6.0
        Buff.remove(actor, Buff.find("aphelion-crimsonScarf"), 1)
    end
end)