-- Ballistic Vest

local sprite = Resources.sprite_load("aphelion", "item/ballisticVest", PATH.."assets/sprites/items/ballisticVest.png", 1, 16, 16)

local item = Item.new("aphelion", "ballisticVest")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:onStatRecalc(function(actor, stack)
    actor.armor = actor.armor + (5 * stack)
    actor.maxshield = actor.maxshield + (20 * stack)
end)



-- Achievement
item:add_achievement(2000, true)

Player:onDamagedProc("aphelion-ballisticVestUnlock", function(actor, attacker, hit_info)
    item:progress_achievement(math.min(hit_info.damage, actor.hp))
end)