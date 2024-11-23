-- Mystery Box

local sprite = Resources.sprite_load("aphelion", "item/mysteryBox", PATH.."assets/sprites/items/mysteryBox.png", 1, 16, 16)
local spriteObj = Resources.sprite_load("aphelion", "object/mysteryBox", PATH.."assets/sprites/objects/mysteryBox.png", 1, 25, 35)
local spriteObjUse = Resources.sprite_load("aphelion", "object/mysteryBoxUse", PATH.."assets/sprites/objects/mysteryBoxUse.png", 8, 32, 39)

local item = Item.new("aphelion", "mysteryBox")
item:set_sprite(sprite)
item:set_tier(Item.TIER.rare)

local function spawn_boxes(actor, stack)
    -- WIP
    local spacing = 44
    local x = (stack - 1) * -spacing/2
    for i = 1, stack do
        local choices = {}
        for j = 1, 5 do
            -- Pick tier
            local tier = Item.TIER.common
            if      Helper.chance(0.29) then tier = Item.TIER.uncommon
            elseif  Helper.chance(0.04) then tier = Item.TIER.rare
            end

            -- Pick unselected item
            local _item = nil
            repeat
                _item = Item.get_random(tier)
            until _item:is_loot()
              and _item:is_unlocked()
              and (not Helper.table_has(choices, _item.value))
              and _item.value ~= item.value

            -- Add to choices
            table.insert(choices, _item.value)
        end
        local box = Item.spawn_crate(actor.x + x, actor.y, Item.TIER.common, choices)
        box.sprite_index = spriteObj
        box.sprite_death = spriteObjUse
        x = x + spacing
    end
end

item:onAcquire(function(actor, stack)
    -- Spawn a box immediately on first stack
    if stack == 1 then spawn_boxes(actor, stack) end
end)

item:onStageStart(function(actor, stack)
    spawn_boxes(actor, stack)
end)



-- Achievement
item:add_achievement()

Player:onPickupCollected("aphelion-mysteryBoxUnlock", function(actor, pickup_object)
    -- Item: ~107
    -- Equipment: ~29 (excluding Strange Battery)

    if item:is_unlocked() then return end

    local found_all = true

    for i = 0, 107 do
        local _item = Class.ITEM:get(i)
        local object_id = _item:get(8)
        local tier = _item:get(8)
        if object_id and tier <= 4 then
            local key = gm.item_get_stat_key_total_collected(object_id)
            local total = gm.save_stat_get(key)
            if total <= 0 then
                found_all = false
                break
            end
        end
    end

    if not found_all then return end

    for i = 0, 29 do
        local equip = Class.EQUIPMENT:get(i)
        local object_id = equip:get(8)
        local tier = equip:get(6)
        if object_id and tier <= 4 then
            local key = gm.equipment_get_stat_key_time_held(object_id)
            local total = gm.save_stat_get(key)
            if total <= 0 then
                found_all = false
                break
            end
        end
    end

    if not found_all then return end

    item:progress_achievement()
end)