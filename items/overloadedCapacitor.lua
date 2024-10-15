-- Overloaded Capacitor

local sprite = Resources.sprite_load("aphelion", "item/overloadedCapacitor", PATH.."assets/sprites/items/overloadedCapacitor.png", 1, 16, 16)

local item = Item.new("aphelion", "overloadedCapacitor")
item:set_sprite(sprite)
item:set_tier(Item.TIER.rare)
item:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_healing)

item:onPostStatRecalc(function(actor, stack)
    actor.maxshield = actor.maxshield + (actor.maxhp * Helper.mixed_hyperbolic(stack, 0.18, 0.18))
end)

item:onHit(function(actor, victim, damager, stack)
    if actor.shield > 0 then
        local obj = Object.find("ror-chainLightning")
        local lightning = obj:create(victim.x, victim.y)
        lightning.damage = damager.damage * (stack * 0.3)
        lightning.bounce = 2
        lightning.range = 150.0
    end
end)