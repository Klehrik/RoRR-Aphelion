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
    gm.item_give(actor, item, normal, false)
    gm.item_give(actor, item, temp, true)
end)

Item.add_callback(item, "onStep", function(actor, stack)
    -- Heal when at <= 25% health
    if actor.hp <= actor.maxhp * 0.25 then
        Actor.heal(actor, actor.maxhp * 0.5)
        gm.sound_play_at(sound, 1.0, 1.0, actor.x, actor.y, 1.0)

        -- Remove stacks and give used stacks
        local item      = Item.find("aphelion-ration")
        local item_used = Item.find("aphelion-rationUsed")
        local normal    = Item.get_stack_count(actor, item, Item.TYPE.real)
        local temp      = Item.get_stack_count(actor, item, Item.TYPE.temporary)
        gm.item_take(actor, item, normal, false)
        gm.item_take(actor, item, temp, true)
        gm.item_give(actor, item_used, normal, false)
        gm.item_give(actor, item_used, temp, true)
    end
end)