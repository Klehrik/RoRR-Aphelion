-- Rotting Branch

local sprite = Resources.sprite_load(PATH.."assets/sprites/rottingBranch.png", 1, false, false, 16, 16)

local item = Item.new("aphelion", "rottingBranch")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:add_callback("onHit", function(actor, victim, damager, stack)
    if Helper.chance(0.15 + (0.1 * (stack - 1))) then
        victim:buff_apply(Buff.find("aphelion-rottingBranch"), 1)
        victim.aphelion_rottingBranch_attacker = actor
    end
end)



-- Buff

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffRottingBranch.png", 1, false, false, 6, 7)

local buff = Buff.new("aphelion", "rottingBranch")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = true
buff.stack_number_col = gm.array_create(1, 7964834)
buff.max_stack = 999
buff.is_timed = false
buff.is_debuff = true

buff:add_callback("onApply", function(actor, stack)
    if (not actor.aphelion_rottingBranch_timer) or stack == 1 then actor.aphelion_rottingBranch_timer = 0 end
    actor.aphelion_rottingBranch_duration = math.ceil(210.0 / math.max(stack * 0.4, 1.0))
end)

buff:add_callback("onStep", function(actor, stack)
    actor.aphelion_rottingBranch_timer = actor.aphelion_rottingBranch_timer + 1
    
    if actor.aphelion_rottingBranch_attacker:exists() and actor.aphelion_rottingBranch_timer % 30 == 0 then
        actor:take_damage(actor.aphelion_rottingBranch_attacker.damage * 0.15 * stack, actor.aphelion_rottingBranch_attacker, actor.x - 26, actor.y - 36, 7964834)
    end

    actor.aphelion_rottingBranch_duration = actor.aphelion_rottingBranch_duration - 1
    if actor.aphelion_rottingBranch_duration <= 0 then
        actor:buff_remove(buff, 1)
        actor.aphelion_rottingBranch_duration = math.ceil(210.0 / math.max((stack - 1) * 0.25, 1.0))
    end
end)

buff:add_callback("onChange", function(actor, to, stack)
    -- Pass attacker to new actor instance
    to.aphelion_rottingBranch_attacker = actor.aphelion_rottingBranch_attacker
end)