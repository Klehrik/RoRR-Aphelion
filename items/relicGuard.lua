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

    -- Grant barrier
    if broken then
        local amount = actor.maxshield * (0.5 + (0.5 * stack))
        GM.actor_heal_barrier(actor, amount)
    end
end)

-- Callback.add(Callback.ON_HIT_PROC, function(actor, target, hit_info)
--     -- Check item count
--     local stack = target:item_count(item)
--     if stack <= 0 then return end

--     -- Check for shield break
--     local shield = target.shield
--     print("shield", shield)
--     local actor_data = Instance.get_data(target, "relicGuard")
--     if actor_data.shield_active and shield <= 0 then
--         actor_data.shield_active = false
--         print(tostring(target).." shield broken!")

--         -- Grant barrier
--         local amount = target.maxshield * (0.2 + (0.3 * stack))
--         print(amount)
--         GM.actor_heal_barrier(target, amount)
--     elseif target.shield > 0 then
--         actor_data.shield_active = true
--     end
-- end)

-- Callback.add(Callback.ON_ATTACK_HIT, function(hit_info)
--     local actor = hit_info.target_true  -- `inflictor` for the attacker

--     -- Check item count
--     local stack = actor:item_count(item)
--     if stack <= 0 then return end

--     -- Check for shield break
--     local shield = actor.shield
--     print("shield", shield)
--     local actor_data = Instance.get_data(actor, "relicGuard")
--     if actor_data.shield_active and shield <= 0 then
--         actor_data.shield_active = false
--         print(tostring(actor).." shield broken!")

--         -- Grant barrier
--         local amount = actor.maxshield * (0.2 + (0.3 * stack))
--         print(amount)
--         GM.actor_heal_barrier(actor, amount)
--     elseif actor.shield > 0 then
--         actor_data.shield_active = true
--     end
-- end)

-- Callback.add(Callback.ON_ATTACK_HANDLE_END, function(...)
--     print("Callback.ON_ATTACK_HANDLE_END")
--     for i, v in ipairs{...} do
--         print(i, v)
--         v:print()    -- single argument, AttackInfo
--     end
-- end)