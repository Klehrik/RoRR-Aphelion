-- Overloaded Capacitor

local sprite = Sprite.new("item/overloadedCapacitor", "~/assets/sprites/items/overloadedCapacitor.png", 1, 16, 16)

local item = Item.new("overloadedCapacitor")
item:set_sprite(sprite)
item:set_tier(ItemTier.RARE)
item:set_loot_tags(
    Item.LootTag.CATEGORY_DAMAGE,
    Item.LootTag.CATEGORY_HEALING
)
ItemLog.new_from_item(item)

RecalculateStats.add(function(actor, api)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end
    
    -- Add stats
    api.maxshield_from_maxhp(Util.mixed_hyperbolic(stack, 0.18))
end)

Callback.add(Callback.ON_HIT_PROC, function(actor, victim, hit_info)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Fire chain lightning if shield is active
    if actor.shield > 0 then
        local obj = Object.find("chainLightning")
        local lightning = obj:create(victim.x, victim.y)
        lightning.damage = hit_info.damage * (stack * 0.3)
        lightning.bounce = 2
        lightning.range = 80
    end
end)