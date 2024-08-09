-- Obelisk Shard

local sprite = Resources.sprite_load(PATH.."assets/sprites/obeliskShard.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "obeliskShard")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.uncommon)
Item.set_loot_tags(item, Item.LOOT_TAG.category_utility)

Item.add_callback(item, "onStep", function(actor, stack)
    if actor.still_timer >= 2 *60.0 then
        Buff.apply(actor, Buff.find("aphelion-obeliskShard"), 2)

        -- Reduce equipment cooldown
        if gm.player_get_equipment_cooldown(actor) > 0 then
            gm.player_grant_equipment_cooldown_reduction(actor, (0.1 + (stack * 0.3)))
        end
    end
end)



-- Buff

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffObeliskShard.png", 1, false, false, 7, 8)

local buff = Buff.create("aphelion", "obeliskShard")
Buff.set_property(buff, Buff.PROPERTY.icon_sprite, sprite)