-- Ration

local sprite = Resources.sprite_load("aphelion", "item/ration", PATH.."assets/sprites/items/ration.png", 1, 16, 16)
local sound = Resources.sfx_load("aphelion", "ration", PATH.."assets/sounds/ration.ogg")

local item = Item.new("aphelion", "ration")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:onAcquire(function(actor, stack)
    -- Restore all used Rations
    local item_used = Item.find("aphelion-rationUsed")
    local normal    = actor:item_stack_count(item_used, Item.STACK_KIND.normal)
    local temp      = actor:item_stack_count(item_used, Item.STACK_KIND.temporary_blue)
    if normal > 0 then
        actor:item_remove(item_used, normal)
        actor:item_give(item, normal)
    end
    if temp > 0 then
        actor:item_remove(item_used, temp, Item.STACK_KIND.temporary_blue)
        actor:item_give(item, temp, Item.STACK_KIND.temporary_blue)
    end

    -- Remove cooldown
    Cooldown.set(actor, "aphelion-ration", 0)
end)

item:onDamagedProc(function(actor, attacker, stack, hit_info)
    -- Heal when at <= 25% health
    if actor.hp <= actor.maxhp * 0.25 then
        actor:heal(actor.maxhp * Helper.mixed_hyperbolic(stack, 0.07, 0.5))
        actor:sound_play_at(sound, 0.9, 1.0, actor.x, actor.y, 1.0)

        -- Remove stacks and give used stacks
        local item_used = Item.find("aphelion-rationUsed")
        local normal    = actor:item_stack_count(item, Item.STACK_KIND.normal)
        local temp      = actor:item_stack_count(item, Item.STACK_KIND.temporary_blue)
        if normal > 0 then
            actor:item_remove(item, normal)
            actor:item_give(item_used, normal)
        end
        if temp > 0 then
            actor:item_remove(item, temp, Item.STACK_KIND.temporary_blue)
            actor:item_give(item_used, temp, Item.STACK_KIND.temporary_blue)
        end
    end
end)