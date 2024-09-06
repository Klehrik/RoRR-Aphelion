-- Ration

local sprite = Resources.sprite_load(PATH.."assets/sprites/ration.png", 1, false, false, 16, 16)
local sound = Resources.sfx_load(PATH.."assets/sounds/ration.ogg")

local item = Item.new("aphelion", "ration")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:add_callback("onPickup", function(actor, stack)
    -- Restore all used Rations
    local item      = Item.find("aphelion-ration")
    local item_used = Item.find("aphelion-rationUsed")
    local normal    = actor:item_stack_count(item_used, Item.TYPE.real)
    local temp      = actor:item_stack_count(item_used, Item.TYPE.temporary)
    actor:item_remove(item_used, normal, false)
    actor:item_remove(item_used, temp, true)
    gm.item_give_internal(actor.value, item.value, normal, false)   -- Check if this still works in MP when the time comes
    gm.item_give_internal(actor.value, item.value, temp, true)
end)

item:add_callback("onDamaged", function(actor, damager, stack)
    -- Heal when at <= 25% health
    if actor.hp <= actor.maxhp * 0.25 then
        actor:heal(actor.maxhp * Helper.mixed_hyperbolic(stack, 0.07, 0.5))
        gm.sound_play_at(sound, 0.9, 1.0, actor.x, actor.y, 1.0)

        -- Remove stacks and give used stacks
        local item      = Item.find("aphelion-ration")
        local item_used = Item.find("aphelion-rationUsed")
        local normal    = actor:item_stack_count(item, Item.TYPE.real)
        local temp      = actor:item_stack_count(item, Item.TYPE.temporary)
        actor:item_remove(item, normal, false)
        actor:item_remove(item, temp, true)
        gm.item_give_internal(actor.value, item_used.value, normal, false)
        gm.item_give_internal(actor.value, item_used.value, temp, true)
    end
end)