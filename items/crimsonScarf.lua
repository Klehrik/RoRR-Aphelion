-- Crimson Scarf

local sprite = Sprite.new("item/crimsonScarf", "~/assets/sprites/items/crimsonScarf.png", 1, 16, 16)

local item = Item.new("crimsonScarf")
item:set_sprite(sprite)
item:set_tier(ItemTier.UNCOMMON)
item.loot_tags = Item.LootTag.CATEGORY_DAMAGE

ItemLog.new_from_item(item)

-- Doing Buff creation here to use the ID
local buff = Buff.new("crimsonScarf")

Callback.add(Callback.ON_KILL_PROC, function(actor, attacker)
    -- Check item count
    local stack = attacker:item_count(item)
    if stack <= 0 then return end

    -- Apply a buff stack
    attacker:buff_apply(buff, (4 + stack) *60)
end)



-- Buff

local sprite = Sprite.new("buff/crimsonScarf", "~/assets/sprites/buffs/crimsonScarf.png", 1, 7, 9)

buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = false
buff.max_stack = -1 -- Stacks applied separately (own timer per stack)

Callback.add(buff.on_apply, function(actor)
    -- Increment internal buff counter
    local actor_data = Instance.get_data(actor, "crimsonScarf")
    actor_data.count = actor_data.count or 0
    actor_data.count = actor_data.count + 1
end)

Callback.add(buff.on_remove, function(actor)
    -- Decrement internal buff counter
    local actor_data = Instance.get_data(actor, "crimsonScarf")
    actor_data.count = actor_data.count or 0
    actor_data.count = actor_data.count - 1
end)

RecalculateStats.add(function(actor, api)
    -- Check buff count
    local stack = actor:buff_count(buff)
    if stack <= 0 then return end

    -- Get actual buff count
    -- Since each is applied separately,
    -- `actor:buff_count` always returns <= 1
    local actor_data = Instance.get_data(actor, "crimsonScarf")
    local count = actor_data.count or 0
    
    -- Add stats
    api.critical_chance_add(7 * count)
end)