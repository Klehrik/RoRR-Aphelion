-- Ration

local sprite = Resources.sprite_load(PATH.."assets/sprites/ration.png", 1, false, false, 16, 16)
local sound = Resources.sfx_load(PATH.."assets/sounds/ration.ogg")

local item = Item.create("aphelion", "ration")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.common)
Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

Item.add_callback(item, "onPickup", function(actor, stack)
    -- Restore all used Rations
    local item      = Item.find("aphelion-ration")
    local item_used = Item.find("aphelion-rationUsed")
    local normal    = Item.get_stack_count(actor, item_used, Item.TYPE.real)
    local temp      = Item.get_stack_count(actor, item_used, Item.TYPE.temporary)
    gm.item_take(actor, item_used, normal, false)
    gm.item_take(actor, item_used, temp, true)
    gm.item_give_internal(actor, item, normal, false)   -- Check if this still works in MP when the time comes
    gm.item_give_internal(actor, item, temp, true)
end)

Item.add_callback(item, "onDamaged", function(actor, damager, stack)
    -- Heal when at <= 25% health
    if actor.hp <= actor.maxhp * 0.25 then
        Actor.heal(actor, actor.maxhp * Helper.mixed_hyperbolic(stack, 0.07, 0.5))
        gm.sound_play_at(sound, 0.9, 1.0, actor.x, actor.y, 1.0)

        -- Remove stacks and give used stacks
        local item      = Item.find("aphelion-ration")
        local item_used = Item.find("aphelion-rationUsed")
        local normal    = Item.get_stack_count(actor, item, Item.TYPE.real)
        local temp      = Item.get_stack_count(actor, item, Item.TYPE.temporary)
        gm.item_take(actor, item, normal, false)
        gm.item_take(actor, item, temp, true)
        gm.item_give_internal(actor, item_used, normal, false)
        gm.item_give_internal(actor, item_used, temp, true)
    end
end)