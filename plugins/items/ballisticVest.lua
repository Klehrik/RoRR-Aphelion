-- Ballistic Vest

local sprite = Resources.sprite_load(PATH.."assets/sprites/ballisticVest.png", 1, false, false, 16, 16)

local item = Item.new("aphelion", "ballisticVest")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:add_callback("onPickup", function(actor, stack)
    actor.armor_base = actor.armor_base + 5
    local increase = 20
    if stack > 1 then increase = 15 end
    actor.maxshield_base = actor.maxshield_base + increase
end)

item:add_callback("onRemove", function(actor, stack)
    actor.armor_base = actor.armor_base - 5
    local increase = 20
    if stack > 1 then increase = 15 end
    actor.maxshield_base = actor.maxshield_base - increase
end)



-- Achievement
item:add_achievement(2000, true)

Actor.add_callback("onDamaged", function(actor, damager)
    if not actor:same(Player.get_client()) then return end
    if damager then item:progress_achievement(damager.damage) end
end)