-- Relic Guard

local item = Item.new("relicGuard")
local packet


-- ===== Assets =====

local sprite = Sprite.new("item/relicGuard", "~/assets/sprites/items/relicGuard.png", 1, 16, 16)


-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.UNCOMMON)
item.loot_tags = Item.LootTag.CATEGORY_HEALING

local max_range = 512
local buff_time = 300   -- In frames


-- ===== Functions =====

local spawn_particles = function(x, y)
    -- Spawn circle of particles
    local part = Particle.find("Smoke5")
    local vec = Vector.UP
    local count = 180
    for i = 1, count do
        local v = vec:rotated(math.randomf(-2, 2))
        v.length = max_range + math.randomf(-4, 4)
        part:create(x + v.x, y + v.y)
        vec.direction = vec.direction + 360/count
    end
end


-- ===== Callbacks =====

RecalculateStats.add(function(actor, api)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Add stats
    api.maxshield_add_from_maxhp(0.05 * stack)
end)


Callback.add(Callback.ON_SHIELD_BREAK, function(actor, hit_info)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end
    
    local x, y, team = actor.x, actor.y, actor.team
    local value = actor.maxshield * (0.5 + (stack * 0.5))
    local buff = Buff.find("relicGuard")
    
    -- Apply to all nearby allies
    local actors = Instance.find_all(gm.constants.pActor)
    for _, a in ipairs(actors) do
        if  a.team == team
        and math.distance(a.x, a.y, x, y) <= max_range then
            a:heal_barrier(value)
            a:buff_apply(buff, buff_time, math.max(value / 10, 1))
        end
    end

    -- Spawn circle of particles
    spawn_particles(x, y)
    packet:send_to_all(x, y)
end)


Callback.add(Callback.ON_DRAW, function()
    for _, actor in ipairs(item:get_holding_actors()) do
        gm.draw_text(actor.x, actor.y + 32, actor.armor)
    end
end)


-- ===== Packets =====

packet = Packet.new("relicGuard")
packet:set_serializers(
    function(buffer, x, y)
        buffer:write_int(x)
        buffer:write_int(y)
    end,

    function(buffer, player)
        -- Spawn particles
        spawn_particles(buffer:read_int(), buffer:read_int())
    end
)


-- ===== Additional =====

ItemLog.new_from_item(item)