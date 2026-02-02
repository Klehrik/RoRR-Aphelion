-- Ration (Used)

local item = Item.new("rationUsed")


-- ===== Assets =====

local sprite = Sprite.new("item/rationUsed", "~/assets/sprites/items/rationUsed.png", 1, 16, 16)


-- ===== Properties =====

item:set_sprite(sprite)


-- ===== Hooks =====

Callback.add(Callback.ON_STAGE_START, function()
    local actors = item:get_holding_actors()

    for _, actor in ipairs(actors) do
        -- Remove used stacks and give ready stacks
        local item_ready = Item.find("ration")
        local normal     = actor:item_count(item, Item.StackKind.NORMAL)
        local temp       = actor:item_count(item, Item.StackKind.TEMPORARY_BLUE)
        if normal > 0 then
            actor:item_take(item, normal)
            actor:item_give(item_ready, normal)
        end
        if temp > 0 then
            actor:item_take(item, temp, Item.StackKind.TEMPORARY_BLUE)
            actor:item_give(item_ready, temp, Item.StackKind.TEMPORARY_BLUE)
        end
    end
end)