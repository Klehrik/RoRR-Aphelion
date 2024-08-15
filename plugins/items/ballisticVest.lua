-- Ballistic Vest

local sprite = Resources.sprite_load(PATH.."assets/sprites/ballisticVest.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "ballisticVest")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.common)
Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

Item.add_callback(item, "onPickup", function(actor, stack)
    actor.armor_base = actor.armor_base + 5
    local increase = 15
    if stack > 1 then increase = 10 end
    actor.maxshield_base = actor.maxshield_base + increase
end)

Item.add_callback(item, "onRemove", function(actor, stack)
    actor.armor_base = actor.armor_base - 5
    local increase = 15
    if stack > 1 then increase = 10 end
    actor.maxshield_base = actor.maxshield_base - increase
end)



-- Achievement
Item.add_achievement(item, 2000, true)

Actor.add_callback("onDamaged", function(actor, damager)
    if actor ~= Player.get_client() then return end
    Item.progress_achievement(Item.find("aphelion-ballisticVest"), damager.damage)
end)