-- Mystery Box

local sprite = Resources.sprite_load("aphelion", "item/mysteryBox", PATH.."assets/sprites/items/mysteryBox.png", 1, 16, 16)

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
            elseif  Helper.chance(0.03) then tier = Item.TIER.rare
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
        Item.spawn_crate(actor.x + x, actor.y, Item.TIER.boss, choices)
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
-- item:add_achievement(50)

-- Player:onAttackHandleEndProc("aphelion-silicaPacketUnlock", function(actor, attack_info)
--     if attack_info:get_attack_flag(Attack_Info.ATTACK_FLAG.drifter_execute) then
--         item:progress_achievement(attack_info.kill_number)
--     end
-- end)