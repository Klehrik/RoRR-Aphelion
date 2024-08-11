-- Super Shield

local sprite = Resources.sprite_load(PATH.."assets/sprites/ballisticVest.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "superShield")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.rare)
Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

Item.add_callback(item, "onPickup", function(actor, stack)
    actor.aphelion_superShield_increase = 0.0
end)

-- Item.add_callback(item, "onRemove", function(actor, stack)
--     local increase = 20
--     if stack > 1 then increase = 15 end
--     actor.maxshield_base = actor.maxshield_base - increase
-- end)

Item.add_callback(item, "onStep", function(actor, stack)
    
end)