-- Mystery Box

local sprite = Resources.sprite_load("aphelion", "item/mysteryBox", PATH.."assets/sprites/items/mysteryBox.png", 1, 16, 16)
local spriteObj = Resources.sprite_load("aphelion", "object/mysteryBox", PATH.."assets/sprites/objects/mysteryBox.png", 1, 25, 35)
local spriteObjUse = Resources.sprite_load("aphelion", "object/mysteryBoxUse", PATH.."assets/sprites/objects/mysteryBoxUse.png", 8, 32, 39)

local item = Item.new("aphelion", "mysteryBox")
item:set_sprite(sprite)
item:set_tier(Item.TIER.rare)

local function spawn_boxes(actor, stack)
    local spacing = 44
    local x = (stack - 1) * -spacing/2
    for i = 1, stack do
        local choices = {}
        for j = 1, 5 do
            -- Pick tier
            local tier = Item.TIER.common
            if      Helper.chance(0.29) then tier = Item.TIER.uncommon
            elseif  Helper.chance(0.03) then tier = Item.TIER.rare
            elseif  Helper.chance(0.03) then tier = Item.TIER.boss
            end

            -- Pick unselected item
            local _item
            local items = Item.find_all(tier, Item.ARRAY.tier)
            while #items > 0 do
                local pos = gm.irandom_range(1, #items)
                _item = items[pos]

                if _item:is_loot()
                and _item:is_unlocked()
                and (not Helper.table_has(choices, _item.value))
                and _item.value ~= item.value
                then
                    break
                end

                _item = nil
                table.remove(items, pos)
            end

            -- Add to choices
            if _item then table.insert(choices, _item.value) end
        end
        local box = Item.spawn_crate(actor.x + x, actor.y, Item.TIER.common, choices)
        box.sprite_index = spriteObj
        box.sprite_death = spriteObjUse
        x = x + spacing
    end
end

item:onAcquire(function(actor, stack)
    -- Spawn boxes immediately on first pickup
    if actor.RMT_object ~= "Player" then return end
    if stack == 1 then spawn_boxes(actor, stack + 1) end
end)

item:onStageStart(function(actor, stack)
    spawn_boxes(actor, stack + 1)
end)



-- Achievement
item:add_achievement()

Player:onPickupCollected("aphelion-mysteryBoxUnlock", function(actor, pickup_instance)
    if item:is_unlocked() then return end

    local obj_index = pickup_instance.__object_index
    if not obj_index then obj_index = pickup_instance.object_index end

    local items = Item.find_all("ror")
    for _, _item in ipairs(items) do
        if  _item.object_id
        and _item.object_id ~= obj_index
        and _item.tier <= 4
        then
            local key = gm.item_get_stat_key_total_collected(_item.object_id)
            local total = gm.save_stat_get(key)
            if total <= 0 then return end
        end
    end

    local equips = Equipment.find_all("ror")
    for _, equip in ipairs(equips) do
        if  equip.object_id
        and equip.object_id ~= obj_index
        and equip.tier <= 4
        and equip.identifier ~= "strangeBattery"
        then
            local key = gm.equipment_get_stat_key_time_held(equip.object_id)
            local time = gm.save_stat_get(key)
            if time <= 0 then return end
        end
    end

    item:progress_achievement()
end)