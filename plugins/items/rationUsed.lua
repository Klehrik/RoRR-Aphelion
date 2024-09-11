-- Ration (Used)

local sprite = Resources.sprite_load("aphelion", "rationUsed", PATH.."assets/sprites/rationUsed.png", 1, 16, 16)

local item = Item.new("aphelion", "rationUsed", true)
item:set_sprite(sprite)

item:onPickup(function(actor, stack)
    actor.aphelion_ration_cooldown = 240 *60 * (1 - Helper.mixed_hyperbolic(stack, 0.2, 0))
end)

item:onStep(function(actor, stack)
    -- Tick down timer
    if actor.aphelion_ration_cooldown > 0 then actor.aphelion_ration_cooldown = actor.aphelion_ration_cooldown - 1
    else
         -- Restore all used Rations
        local item      = Item.find("aphelion-ration")
        local item_used = Item.find("aphelion-rationUsed")
        local normal    = actor:item_stack_count(item_used, Item.TYPE.real)
        local temp      = actor:item_stack_count(item_used, Item.TYPE.temporary)
        actor:item_remove(item_used, normal, false)
        actor:item_remove(item_used, temp, true)
        gm.item_give_internal(actor.value, item.value, normal, false)
        gm.item_give_internal(actor.value, item.value, temp, true)
    end
end)