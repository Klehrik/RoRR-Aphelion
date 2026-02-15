-- Phi Construct

local item = Item.new("phiConstruct")


-- ===== Assets =====

local sprite = Sprite.new("item/phiConstruct", "~/assets/sprites/items/phiConstruct.png", 1, 16, 16)


-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.UNCOMMON)
item.loot_tags = Item.LootTag.CATEGORY_DAMAGE
               + Item.LootTag.CATEGORY_UTILITY


-- ===== Functions =====

local create_construct = function(actor)
    local obj = Object.find("phiConstructObject")
    if not obj then log.error("Could not find phiConstructObject") end

    -- Find construct
    local insts = Instance.find_all(obj)
    for _, inst in ipairs(insts) do
        local inst_data = Instance.get_data(inst)
        if inst_data.parent == actor then
            return
        end
    end

    -- Create construct if existn't
    local inst = obj:create(actor.x, actor.y)
    Instance.get_data(inst).parent = actor
end


-- ===== Callbacks =====

RecalculateStats.add(function(actor, api)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Add stats
    api.maxshield_add(20 * stack)
end)


Callback.add(item.on_acquired, function(actor, stack)
    create_construct(actor)
end)


Callback.add(Callback.ON_STAGE_START, function()
    local actors = item:get_holding_actors()
    for _, actor in ipairs(actors) do
        create_construct(actor)
    end
end)


-- ===== Additional =====

ItemLog.new_from_item(item)