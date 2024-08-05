-- Ballistic Vest

local sprite = Resources.sprite_load(PATH.."/assets/sprites/ballisticVest.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "ballisticVest")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.common)
Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

Item.add_callback(item, "onPickup", function(actor, stack)
    actor.armor_base = actor.armor_base + 5
    actor.maxshield_base = actor.maxshield_base + 10
end)

Item.add_callback(item, "onRemove", function(actor, stack)
    actor.armor_base = actor.armor_base - 5
    actor.maxshield_base = actor.maxshield_base - 10
end)