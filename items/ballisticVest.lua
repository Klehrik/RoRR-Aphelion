-- Ballistic Vest

local sprite = Resources.sprite_load("aphelion", "ballisticVest", PATH.."assets/sprites/ballisticVest.png", 1, 16, 16)

local item = Item.new("aphelion", "ballisticVest")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:onStatRecalc(function(actor, stack)
    actor.armor = actor.armor + (5 * stack)
    actor.maxshield = actor.maxshield + 5 + (15 * stack)
end)



-- Achievement
item:add_achievement(2000, true)

table.insert(player_callbacks, {
    "onDamaged",
    "aphelion-ballisticVestUnlock",
    function(actor, damager)
        if damager then item:progress_achievement(damager.damage) end
    end
})

-- Actor:onDamaged("aphelion-ballisticVestUnlock", function(actor, damager)
--     if not actor:same(Player.get_client()) then return end
--     if damager then item:progress_achievement(damager.damage) end
-- end)