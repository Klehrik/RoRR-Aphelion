-- Relic Guard

local sprite = Sprite.new("item/relicGuard", "~/assets/sprites/items/relicGuard.png", 1, 16, 16)

local item = Item.new("relicGuard")
item:set_sprite(sprite)
item:set_tier(ItemTier.UNCOMMON)
item:set_loot_tags(Item.LootTag.CATEGORY_HEALING)
ItemLog.new_from_item(item)

RecalculateStats.add(function(actor, api)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end
    
    -- Add stats
    api.maxshield_add(20 + (20 * stack))
end)

Callback.add(Callback.ON_DAMAGED_PROC, function(actor, hit_info)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Check for shield break
    local broken
    local actor_data = Instance.get_data(actor, "relicGuard")
    if actor.shield <= 0 then
        if actor_data.shield_active then
            actor_data.shield_active = false
            broken = true
        end
    else actor_data.shield_active = true
    end

    -- Grant barrier to all nearby allies
    -- TODO actually check distance and grant to non-player allies
    if broken then
        local amount = actor.maxshield * (0.5 + (0.5 * stack))
        local players = Instance.find_all(gm.constants.oP)
        for _, p in ipairs(players) do
            GM.actor_heal_barrier(p, amount)
        end
    end
end)