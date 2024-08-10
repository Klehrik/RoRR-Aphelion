-- Ration (Used)

local sprite = Resources.sprite_load(PATH.."assets/sprites/rationUsed.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "rationUsed", true)
Item.set_sprite(item, sprite)

Item.add_callback(item, "onPickup", function(actor, stack)
    actor.aphelion_ration_cooldown = 240 *60 * (1 - Helper.mixed_hyperbolic(stack, 0.2, 0))
end)

Item.add_callback(item, "onStep", function(actor, stack)
    -- Tick down timer
    if actor.aphelion_ration_cooldown > 0 then actor.aphelion_ration_cooldown = actor.aphelion_ration_cooldown - 1
    else
        -- Restore all used Rations
        local item      = Item.find("aphelion-ration")
        local item_used = Item.find("aphelion-rationUsed")
        local normal    = Item.get_stack_count(actor, item_used, Item.TYPE.real)
        local temp      = Item.get_stack_count(actor, item_used, Item.TYPE.temporary)
        gm.item_take(actor, item_used, normal, false)
        gm.item_take(actor, item_used, temp, true)
        gm.item_give(actor, item, normal, false)
        gm.item_give(actor, item, temp, true)
    end
end)