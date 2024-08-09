-- Rotting Branch

local sprite = Resources.sprite_load(PATH.."assets/sprites/rottingBranch.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "rottingBranch")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.common)
Item.set_loot_tags(item, Item.LOOT_TAG.category_damage)

Item.add_callback(item, "onHit", function(attacker, victim, damager, stack)
    if Helper.chance(0.15 + (0.1 * (stack - 1))) then
        Buff.apply(victim, Buff.find("aphelion-rottingBranch"), 1)
        victim.aphelion_rottingBranch_attacker = attacker
    end
end)



-- Buff

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffRottingBranch.png", 1, false, false, 6, 5)

local buff = Buff.create("aphelion", "rottingBranch")
Buff.set_property(buff, Buff.PROPERTY.icon_sprite, sprite)
Buff.set_property(buff, Buff.PROPERTY.icon_stack_subimage, false)
Buff.set_property(buff, Buff.PROPERTY.draw_stack_number, true)
Buff.set_property(buff, Buff.PROPERTY.max_stack, 999)
Buff.set_property(buff, Buff.PROPERTY.is_timed, false)
Buff.set_property(buff, Buff.PROPERTY.is_debuff, true)

Buff.add_callback(buff, "onApply", function(actor, stack)
    if (not actor.aphelion_rottingBranch_timer) or stack == 1 then actor.aphelion_rottingBranch_timer = 0 end
    actor.aphelion_rottingBranch_duration = math.ceil(210.0 / math.max(stack * 0.333, 1.0))
end)

Buff.add_callback(buff, "onStep", function(actor, stack)
    actor.aphelion_rottingBranch_timer = actor.aphelion_rottingBranch_timer + 1
    
    if gm.instance_exists(actor.aphelion_rottingBranch_attacker) and actor.aphelion_rottingBranch_timer % 30 == 0 then
        Actor.damage(actor, actor.aphelion_rottingBranch_attacker, actor.aphelion_rottingBranch_attacker.damage * 0.12 * stack, actor.x - 26, actor.y - 36, 8421504)
    end

    actor.aphelion_rottingBranch_duration = actor.aphelion_rottingBranch_duration - 1
    if actor.aphelion_rottingBranch_duration <= 0 then
        Buff.remove(actor, Buff.find("aphelion-rottingBranch"), 1)
        actor.aphelion_rottingBranch_duration = math.ceil(210.0 / math.max((stack - 1) * 0.333, 1.0))
    end
end)