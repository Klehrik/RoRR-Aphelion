-- Obelisk Shard

local sprite = Resources.sprite_load(PATH.."assets/sprites/obeliskShard.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "obeliskShard")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.uncommon)
Item.set_loot_tags(item, Item.LOOT_TAG.category_utility)

Item.add_callback(item, "onPickup", function(actor, stack)
    if not actor.aphelion_obeliskShard_stillTime then actor.aphelion_obeliskShard_stillTime = 0 end
end)

Item.add_callback(item, "onStep", function(actor, stack)
    -- Still time
    actor.aphelion_obeliskShard_stillTime = actor.aphelion_obeliskShard_stillTime + 1
    if actor.pHspeed ~= 0.0 then actor.aphelion_obeliskShard_stillTime = 0 end

    -- Not moving + out of combat
    local still_time = math.min(actor.aphelion_obeliskShard_stillTime, actor.hud_hp_frame - actor.in_combat_last_frame)

    if still_time >= 2 *60.0 then
        Buff.apply(actor, Buff.find("aphelion-obeliskShard"), 2)

        -- Reduce equipment cooldown
        gm.player_grant_equipment_cooldown_reduction(actor, (0.1 + (stack * 0.3)))
    end
end)



-- Buff

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffObeliskShard.png", 1, false, false, 16, 16)

local buff = Buff.create("aphelion", "obeliskShard")
Buff.set_property(buff, Buff.PROPERTY.icon_sprite, sprite)