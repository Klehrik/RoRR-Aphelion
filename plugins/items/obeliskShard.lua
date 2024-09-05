-- Obelisk Shard

local sprite = Resources.sprite_load(PATH.."assets/sprites/obeliskShard.png", 1, false, false, 16, 16)

local item = Item.new("aphelion", "obeliskShard")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_utility)

item:add_callback("onStep", function(actor, stack)
    if actor.still_timer >= 2 *60.0 then
        actor:buff_apply(Buff.find("aphelion-obeliskShard"), 2)

        -- Reduce equipment cooldown
        if actor:get_equipment_cooldown() > 0 then
            actor:reduce_equipment_cooldown(0.1 + (stack * 0.3))
        end
    end
end)



-- Buff

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffObeliskShard.png", 1, false, false, 7, 8)

local buff = Buff.new("aphelion", "obeliskShard")
buff.icon_sprite = sprite