-- Overloaded Capacitor

local sprite = Resources.sprite_load(_ENV["!plugins_mod_folder_path"].."/plugins/assets/sprites/overloadedCapacitor.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "overloadedCapacitor")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.uncommon)
Item.set_loot_tags(item, Item.LOOT_TAG.category_damage)

Item.add_callback(item, "onStep", function(actor, stack)
    if actor.hud_hp_frame - actor.in_combat_last_frame >= 2.5 *60.0 then
        Actor.set_barrier(actor, math.max(actor.barrier, actor.maxbarrier * 0.06))
    end

    if actor.barrier > 0 then
        Buff.apply(actor, Buff.find("aphelion-overloadedCapacitor"), 2)
    end
end)

Item.add_callback(item, "onAttack", function(actor, damager, stack)
    if actor.barrier > 0 then
        local bonus = 0.2 + (0.15 * (stack - 1))
        damager.damage = damager.damage * (1 + bonus)
    end
end)



-- Buff

local sprite = Resources.sprite_load(_ENV["!plugins_mod_folder_path"].."/plugins/assets/sprites/overloadedCapacitor.png", 1, false, false, 16, 16)

local buff = Buff.create("aphelion", "overloadedCapacitor")
Buff.set_property(buff, Buff.PROPERTY.icon_sprite, sprite)