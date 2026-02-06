-- Overloaded Capacitor

local item = Item.new("overloadedCapacitor")
local packet


-- ===== Assets =====

local sprite = Sprite.new("item/overloadedCapacitor", "~/assets/sprites/items/overloadedCapacitor.png", 1, 16, 16)

local color = Color(0x29adff)

-- Seems to get garbage collected unless stored GM side
Global.aphelion_effectdisplay_overloadedCapacitor
= EffectDisplay.particles(Particle.find("Spark"), 8, 2, Particle.System.ABOVE, 0, 0, color)


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
    api.maxshield_add_from_maxhp(Util.mixed_hyperbolic(stack, 0.18))
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
        local obj = Object.find("chainLightning")
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
    local actor_data = Instance.get_data(actor, "overloadedCapacitor")
    if not actor_data.shield_broken then
        actor_data.shield_broken = true
        GM.actor_effectdisplay_remove(actor, Global.aphelion_effectdisplay_overloadedCapacitor)
        packet:send_to_all(actor)
    end
end)


Callback.add(Callback.ON_STEP, function()
    local actors = item:get_holding_actors()

    -- Reattach effect display
    for _, actor in ipairs(actors) do
        local actor_data = Instance.get_data(actor, "overloadedCapacitor")
        if actor_data.shield_broken and actor.shield > 0 then
            actor_data.shield_broken = nil
            GM.actor_effectdisplay_attach(actor, Global.aphelion_effectdisplay_overloadedCapacitor)
        end
    end
end)


-- ===== Packets =====

packet = Packet.new("overloadedCapacitor")
packet:set_serializers(
    function(buffer, actor)
        buffer:write_instance(actor)
    end,

    function(buffer, player)
        -- Remove effect display
        local actor = buffer:read_instance()
        if Instance.exists(actor) then
            local actor_data = Instance.get_data(actor, "overloadedCapacitor")
            actor_data.shield_broken = true
            GM.actor_effectdisplay_remove(actor, Global.aphelion_effectdisplay_overloadedCapacitor)
        end
    end
)


-- ===== Additional =====

ItemLog.new_from_item(item)