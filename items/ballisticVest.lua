-- Ballistic Vest

local sprite = Sprite.new("item/ballisticVest", "~/assets/sprites/items/ballisticVest.png", 1, 16, 16)

local item = Item.new("ballisticVest")
item:set_sprite(sprite)
item:set_tier(ItemTier.COMMON)
item.loot_tags = Item.LootTag.CATEGORY_HEALING

ItemLog.new_from_item(item)

RecalculateStats.add(function(actor, api)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Add stats
    api.armor_add(5 * stack)
    api.maxshield_add(20 * stack)
end)