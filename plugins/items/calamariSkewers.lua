-- Calamari Skewers

local sprite = Resources.sprite_load(PATH.."assets/sprites/calamariSkewers.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "calamariSkewers")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.common)
Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

Item.add_callback(item, "onPickup", function(actor, stack)
    actor.aphelion_calamariSkewers_cooldown = 0
    if not actor.aphelion_calamariSkewers_timers then actor.aphelion_calamariSkewers_timers = gm.ds_list_create() end
end)

Item.add_callback(item, "onKill", function(actor, victim, damager, stack)
    if actor.aphelion_calamariSkewers_cooldown <= 0 then
        Buff.apply(actor, Buff.find("aphelion-calamariSkewers"), 1)
    end
end)

Item.add_callback(item, "onStep", function(actor, stack)
    if actor.aphelion_calamariSkewers_cooldown > 0 then
        actor.aphelion_calamariSkewers_cooldown = actor.aphelion_calamariSkewers_cooldown - 1
    end
end)



-- Buff

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffCalamariSkewers.png", 1, false, false, 6, 8)

local buff = Buff.create("aphelion", "calamariSkewers")
Buff.set_property(buff, Buff.PROPERTY.icon_sprite, sprite)
Buff.set_property(buff, Buff.PROPERTY.icon_stack_subimage, false)
Buff.set_property(buff, Buff.PROPERTY.draw_stack_number, true)
Buff.set_property(buff, Buff.PROPERTY.max_stack, 4)
Buff.set_property(buff, Buff.PROPERTY.is_timed, false)

Buff.add_callback(buff, "onApply", function(actor, stack)
    gm.ds_list_add(actor.aphelion_calamariSkewers_timers, 60)
end)

Buff.add_callback(buff, "onStep", function(actor, stack)
    -- Decrease stack timers
    for i = 0, gm.ds_list_size(actor.aphelion_calamariSkewers_timers) - 1 do
        local new_time = gm.ds_list_find_value(actor.aphelion_calamariSkewers_timers, i) - 1
        gm.ds_list_set(actor.aphelion_calamariSkewers_timers, i, new_time)
    end

    -- Remove oldest stack if expired
    local first = gm.ds_list_find_value(actor.aphelion_calamariSkewers_timers, 0)
    if first and first <= 0 then
        gm.ds_list_delete(actor.aphelion_calamariSkewers_timers, 0)
    end

    -- Check if 4 kills within 1 second has been achieved
    local size = gm.ds_list_size(actor.aphelion_calamariSkewers_timers)
    if size >= 4 then
        local item_stack = Item.get_stack_count(actor, Item.find("aphelion-calamariSkewers"))
        Actor.heal(actor, (item_stack * 20) + ((actor.maxhp - actor.hp) * 0.1))
        actor.aphelion_calamariSkewers_cooldown = 2 *60
        gm.ds_list_clear(actor.aphelion_calamariSkewers_timers)
    end

    -- Remove buff stacks if more than ds_list size
    if stack > size then Buff.remove(actor, Buff.find("aphelion-calamariSkewers"), stack - size) end
end)