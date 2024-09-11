-- Barrier Damage

local sprite = Resources.sprite_load("aphelion", "barrierDamage", PATH.."assets/sprites/bandana.png", 1, 16, 16)

local item = Item.new("aphelion", "barrierDamage")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:onStep(function(actor, stack)
    if actor.hud_hp_frame - actor.in_combat_last_frame + 120 >= 5 *60.0 then
        actor:set_barrier(math.max(actor.barrier, actor.maxbarrier * 0.08))
    end

    if actor.barrier > 0 then
        actor:buff_apply(Buff.find("aphelion-barrierDamage"), 2)
    end
end)

item:onAttack(function(actor, damager, stack)
    if actor.barrier > 0 then
        local bonus = 0.09 + (stack * 0.09)
        damager.damage = damager.damage * (1 + bonus)
    end
end)



-- Buff

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffBandana.png", 1, 7, 7)

local buff = Buff.new("aphelion", "barrierDamage")
buff.icon_sprite = sprite