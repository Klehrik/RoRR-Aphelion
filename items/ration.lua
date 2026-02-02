-- Ration

local item = Item.new("ration")


-- ===== Assets =====

local sprite = Sprite.new("item/ration", "~/assets/sprites/items/ration.png", 1, 16, 16)
local sound  =  Sound.new("item/ration", "~/assets/sounds/items/ration.ogg")


-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.COMMON)
item.loot_tags = Item.LootTag.CATEGORY_HEALING


-- ===== Hooks =====

Callback.add(Callback.ON_DAMAGED_PROC, function(actor, hit_info)
    if actor:item_count(item) <= 0 then return end

    -- Heal when at <= 25% health (but not 0)
    local hp    = actor.hp
    local maxhp = actor.maxhp
    if  hp > 0
    and hp <= maxhp * 0.25 then
        actor:heal(maxhp * 0.5)
        sound:play_synced(actor.x, actor.y, 0.9)

        -- Use Medkit healing bar animation
        actor:buff_apply(Buff.find("medkit"), 94 * 0.45)

        -- Remove 1 stack and give 1 used stack
        -- Take temporary stacks first
        local item_used = Item.find("rationUsed")

        local temp = actor:item_count(item, Item.StackKind.TEMPORARY_BLUE)
        if temp > 0 then
            actor:item_take(item, 1, Item.StackKind.TEMPORARY_BLUE)
            actor:item_give(item_used, 1, Item.StackKind.TEMPORARY_BLUE)
            return
        end

        local normal = actor:item_count(item, Item.StackKind.NORMAL)
        if normal > 0 then
            actor:item_take(item, 1)
            actor:item_give(item_used, 1)
        end
    end
end)


-- ===== Additional =====

ItemLog.new_from_item(item)