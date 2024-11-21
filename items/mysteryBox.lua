-- Mystery Box

local sprite = Resources.sprite_load("aphelion", "item/silicaPacket", PATH.."assets/sprites/items/silicaPacket.png", 1, 16, 16)

local item = Item.new("aphelion", "mysteryBox")
item:set_sprite(sprite)
item:set_tier(Item.TIER.rare)

local function spawn_boxes(actor, stack)
    -- wip
    local spacing = 44
    local x = (stack - 1) * -spacing/2
    for i = 1, stack do
        log.info(x)
        Item.spawn_crate(actor.x + x, actor.y, Item.TIER.common)
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