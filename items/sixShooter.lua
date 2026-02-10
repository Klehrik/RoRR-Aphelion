-- Six Shooter

local item = Item.new("sixShooter")
local packet


-- ===== Assets =====

local sprite = Sprite.new("item/sixShooter", "~/assets/sprites/items/sixShooter.png", 1, 16, 17)


-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.UNCOMMON)
item.loot_tags = Item.LootTag.CATEGORY_DAMAGE

local fade_speed   = 8      -- Time (in frames) to fully fade-in/out the display
local damage_bonus = 0.33   -- 6th shot damage bonus per stack


-- ===== Functions =====

local increment_and_rotate = function(actor_data)
    actor_data.count = actor_data.count + 1
    actor_data.rotation_to = actor_data.rotation_to + 60
    actor_data.visible:start()

    if actor_data.count >= 6 then
        actor_data.count = actor_data.count - 6
        actor_data.ready = true
        actor_data.flash:start()
    end
end


-- ===== Callbacks =====

Callback.add(item.on_acquired, function(actor, stack)
    local actor_data = Instance.get_data(actor, "sixShooter")
    actor_data.count       = 0
    actor_data.ready       = false
    actor_data.rotation    = 90
    actor_data.rotation_to = 90
    actor_data.alpha       = 0
    actor_data.visible     = Timer(120)
    actor_data.flash       = Timer(20)
    actor_data.surface     = -1
end)


Callback.add(Callback.ON_SKILL_ACTIVATE, function(actor, slot)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    if slot == Skill.Slot.PRIMARY then
        local actor_data = Instance.get_data(actor, "sixShooter")
        actor_data.primary_use = true
    end
end)


-- This callback only runs for the local player
Callback.add(Callback.ON_ATTACK_CREATE, function(attack_info)

    -- Check if this is a procing attack
    if not Util.bool(attack_info.proc) then return end

    local actor = attack_info.parent
    if not Instance.exists(actor) then return end

    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    local actor_data = Instance.get_data(actor, "sixShooter")

    -- Check if primary skill has been used
    -- Not 100% accurate but works fine for the most part
    if actor_data.primary_use then
        actor_data.primary_use = nil

        -- Increment and start rotation
        increment_and_rotate(actor_data)
        packet:send_to_all(actor)
    end

    -- Check if 6th shot has been fired
    if actor_data.ready then
        actor_data.ready = false

        -- Apply damage bonus and guaranteed crit
        attack_info:set_damage(attack_info:get_damage_nocrit() * (1 + (damage_bonus * stack)))
        attack_info:set_critical(true)
    end
end)


Callback.add(Callback.ON_DRAW, function()
    local actors = item:get_holding_actors()

    for _, actor in ipairs(actors) do
        local actor_data = Instance.get_data(actor, "sixShooter")

        -- Fade-in/out
        local dir = math.sign(actor_data.visible.time_left)
        actor_data.alpha = math.clamp(actor_data.alpha + dir/fade_speed, 0, 1)

        -- Rotate
        local delta = actor_data.rotation_to - actor_data.rotation
        local speed_div = 4
        if delta < 1 then
            actor_data.rotation = actor_data.rotation_to
        else
            actor_data.rotation = actor_data.rotation + delta/speed_div
        end

        -- Create surface if existn't
        if not Util.bool(gm.surface_exists(actor_data.surface)) then
            actor_data.surface = gm.surface_create(49, 49)
        end
        gm.surface_set_target(actor_data.surface)

        -- Cylinder body
        gm.draw_circle(24, 24, 24, false)

        gm.gpu_set_blendmode(3)

        -- Center
        gm.draw_circle(24, 24, 4, false)

        local vec = Vector.UP
        vec.direction = actor_data.rotation

        for i = 1, 6 do
            -- Cylinder
            local offset = 15

            -- Loaded round
            if actor_data.count < i then
                for r = 5, 6, 0.5 do
                    gm.draw_circle(24 + vec.x * offset, 24 + vec.y * offset, r, true)
                end
                gm.draw_circle(24 + vec.x * offset, 24 + vec.y * offset, 2, true)

            -- Spent casing
            else
                gm.draw_circle(24 + vec.x * offset, 24 + vec.y * offset, 6, false)

            end

            -- Groove
            local offset = 28
            local v = vec:rotated(-30)
            gm.draw_circle(24 + v.x * offset, 24 + v.y * offset, 6, false)

            vec.direction = vec.direction - 60
        end

        gm.gpu_set_blendmode(0)
        gm.surface_reset_target()

        -- Draw surface
        local flash = math.max(actor_data.flash.time_left / actor_data.flash.duration, 0)
        local color = gm.merge_color(Color.WHITE, Color.YELLOW, flash)
        gm.draw_surface_ext(actor_data.surface, actor.x - 24, actor.y - 66, 1, 1, 0, color, (actor_data.alpha * 0.4) + (flash * 0.6))
    end
end)


-- ===== Packets =====

packet = Packet.new("sixShooter")
packet:set_serializers(
    function(buffer, actor)
        buffer:write_instance(actor)
    end,

    function(buffer, player)
        local actor = buffer:read_instance()
        if Instance.exists(actor) then
            local actor_data = Instance.get_data(actor, "sixShooter")
            increment_and_rotate(actor_data)
        end
    end
)


-- ===== Additional =====

ItemLog.new_from_item(item)