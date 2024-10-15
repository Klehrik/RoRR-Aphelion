-- Rotting Branch

local sprite = Resources.sprite_load("aphelion", "item/rottingBranch", PATH.."assets/sprites/items/rottingBranch.png", 1, 16, 16)

local item = Item.new("aphelion", "rottingBranch")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:onHit(function(actor, victim, damager, stack)
    local victim_data = victim:get_data("rottingBranch")
    if Helper.chance(0.15 + (0.1 * (stack - 1))) then
        victim:buff_apply(Buff.find("aphelion-rottingBranch"), 1)
        victim_data.attacker = actor
    end
end)



-- Buff

local sprite = Resources.sprite_load("aphelion", "buff/rottingBranch", PATH.."assets/sprites/buffs/rottingBranch.png", 1, 6, 7)

local buff = Buff.new("aphelion", "rottingBranch")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = true
buff.stack_number_col = Array.new(1, Color(0xA28879))
buff.max_stack = 999
buff.is_timed = false
buff.is_debuff = true

buff:onApply(function(actor, stack)
    local actorData = actor:get_data("rottingBranch")
    if (not actorData.timer) or stack == 1 then actorData.timer = 0 end
    actorData.duration = math.ceil(210.0 / math.max(stack * 0.4, 1.0))
end)

buff:onStep(function(actor, stack)
    local actorData = actor:get_data("rottingBranch")

    actorData.timer = actorData.timer + 1
    
    if actorData.attacker:exists() and actorData.timer % 30 == 0 then
        local coeff = 0.15 * stack

        local damager = actorData.attacker:fire_direct(actor, coeff)
        damager:set_color(Color(0xA28879))
        damager:set_critical(false)
        damager:set_proc(false)
    end

    actorData.duration = actorData.duration - 1
    if actorData.duration <= 0 then
        actor:buff_remove(buff, 1)
        actorData.duration = math.ceil(210.0 / math.max((stack - 1) * 0.25, 1.0))
    end
end)