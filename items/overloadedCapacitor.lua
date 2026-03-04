-- Overloaded Capacitor

local item = Item.new("overloadedCapacitor")
local packet


-- ===== Assets =====

local sprite = Sprite.new("item/overloadedCapacitor", "~/assets/sprites/items/overloadedCapacitor.png", 1, 16, 16)

local color = Color(0x29adff)

-- Seems to get garbage collected unless stored GM side
Global.aphelion_effectdisplay_overloadedCapacitor
= EffectDisplay.particles(Particle.find("Spark"), 6, 2, Particle.System.ABOVE, 0, 0, color)


-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.RARE)
item.loot_tags = Item.LootTag.CATEGORY_DAMAGE
               + Item.LootTag.CATEGORY_HEALING


-- ===== Callbacks =====

Callback.add(item.on_acquired, function(actor, stack)
    -- Attach effect display
    GM.actor_effectdisplay_attach(actor, Global.aphelion_effectdisplay_overloadedCapacitor)
end)


RecalculateStats.add(function(actor, api)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Add stats
    api.maxshield_add_from_maxhp(0.18 * stack)
end)


Hook.add_post(gm.constants.damager_proc_onaoe, function(self, other, result, args)
    local attack_info = args[1].value
    if not Util.bool(attack_info.proc) then return end

    local actor = attack_info.parent
    if not Instance.exists(actor) then return end

    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Fire chain lightning if shield is active
    if actor.shield > 0 then
        local obj = Object.find("ChainLightning")
        local lightning = obj:create(args[2].value, args[3].value)
        lightning.damage = attack_info.damage * (stack * 0.3)
        lightning.bounce = 2
        lightning.range = 80
        lightning.blend = color
    end
end)


Callback.add(Callback.ON_SHIELD_BREAK, function(actor, hit_info)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Remove effect display
    GM.actor_effectdisplay_remove(actor, Global.aphelion_effectdisplay_overloadedCapacitor)
    packet:send_to_all(actor, false)
end)


Callback.add(Callback.ON_SHIELD_RESTORE, function(actor)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Reattach effect display
    -- (if shield had fully broken)
    if actor.shield <= 0 then
        GM.actor_effectdisplay_attach(actor, Global.aphelion_effectdisplay_overloadedCapacitor)
        packet:send_to_all(actor, true)
    end
end)


-- ===== Packets =====

packet = Packet.new("overloadedCapacitor")
packet:set_serializers(
    function(buffer, actor, op_attach)
        buffer:write_instance(actor)
        buffer:write_bool(op_attach)
    end,

    function(buffer, player)
        -- Add/remove effect display
        local actor = buffer:read_instance()
        local op_attach = buffer:read_bool()

        if Instance.exists(actor) then
            GM["actor_effectdisplay_"..(op_attach and "attach" or "remove")](actor, Global.aphelion_effectdisplay_overloadedCapacitor)
        end
    end
)


-- ===== Additional =====

ItemLog.new_from_item(item)