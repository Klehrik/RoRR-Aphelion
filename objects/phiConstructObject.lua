-- Phi Construct (Object)

local object = Object.new("phiConstructObject")


-- ===== Assets =====

local sprite_body = Sprite.new("object/phiConstructBody", "~/assets/sprites/objects/phiConstructBody.png", 4, 8, 8)
local sprite_face = Sprite.new("object/phiConstructFace", "~/assets/sprites/objects/phiConstructFace.png", 4, 8, 8)
local color = Color(0x40E0D0)


-- ===== Properties =====

object:set_sprite(sprite_body)
object:set_depth(-1)

local speed_div         = 20    -- speed = distance from destination / speed_div
local max_wander_range  = 64    -- If outside this range (in pixels), move directly towards parent
local max_fire_range    = 256   -- Always centered at parent position

local base_fire_rate    = 1.1   -- Base delay (in seconds) between shots
local fire_rate_scaling = 0.5   -- % per max shield point
local damage_coeff      = 0.75  -- Base damage coefficient


-- ===== Hooks =====

Callback.add(object.on_create, function(inst)
    inst.image_speed = 0.1

    local inst_data = Instance.get_data(inst)
    inst_data.following = nil
    inst_data.find_new_following = false    -- Set to `true` once on player death

    inst_data.destination = Vector.ZERO
    inst_data.max_speed = math.huge
    inst_data.wander_timer = Timer()

    inst_data.facing_direction = 1
    inst_data.face_offset = 4
    inst_data.force_direction_timer = Timer()

    inst_data.charge = 0
end)


Callback.add(object.on_step, function(inst)
    local inst_data = Instance.get_data(inst)
    if not Instance.exists(inst_data.parent) then return end

    -- Set initial following
    if not inst_data.following then
        inst_data.following = inst_data.parent
    end

    -- Find player drone on death
    if inst_data.find_new_following then
        local drones = Instance.find_all(gm.constants.oPDrone)
        for _, drone in ipairs(drones) do
            if drone.m_id == inst_data.parent.m_id then
                inst_data.following = drone
                inst_data.find_new_following = false
            end
        end
    end

    -- Destroy self if parent no longer has the item
    -- or if following is dead
    local stack = inst_data.parent:item_count(Item.find("phiConstruct"))
    if stack <= 0
    or (not Instance.exists(inst_data.following)) then
        Instance.get_data(inst_data.parent, "phiConstruct").inst = nil
        inst_data.destroy = true
        inst:destroy()
        return
    end


    local pos = Vector(inst.x, inst.y)
    local parent_pos = Vector(inst_data.following.x, inst_data.following.y)
    local vec = pos - parent_pos
    local length = vec.length

    -- Set destination
    -- Move towards parent if too far
    if length > max_wander_range then
        inst_data.destination = parent_pos + (vec/length * (max_wander_range * 0.95))
        inst_data.max_speed = math.huge

    -- Otherwise move randomly
    -- with a fixed max speed
    elseif inst_data.wander_timer.finished
       and inst_data.force_direction_timer.finished then
        vec.direction = vec.direction + math.random(0, 359)
        inst_data.wander_timer:start(math.random(60, 120))
        inst_data.destination = parent_pos + (vec/length * math.random(16, max_wander_range * 0.5))
        inst_data.max_speed = 2
    end

    -- Move towards destination
    local vec = inst_data.destination - pos
    local length = vec.length
    local speed = math.min(length / speed_div, inst_data.max_speed)
    if length > math.max(speed, 2) then
        pos = pos + (vec/length * speed)
    end
    inst.x, inst.y = pos.x, pos.y


    -- Increment charge
    local required_charge = base_fire_rate / (1 + (fire_rate_scaling/100 * stack * inst_data.parent.maxshield))
    inst_data.charge = math.min(inst_data.charge + 1/60, required_charge)

    -- Get nearest enemy projectile (prioritized) or enemy actor
    local target
    local target_type = 0   -- 0 - projectile, 1 - actor
    local target_pos = Vector.ZERO
    local dist = max_fire_range

    if inst_data.charge >= required_charge then
        -- Get nearest enemy projectile
        -- Check only half the "enemy_projectile" objs on any given frame
        local parity = Global._current_frame % 2
        local i = 0
        for _, obj in pairs(Object.find_all_by_tag("enemy_projectile")) do
            i = i + 1
            if i % 2 == parity then
                local near = Instance.nearest(parent_pos.x, parent_pos.y, obj)
                if Instance.exists(near) then
                    local t_pos = Vector(near.x, near.y)
                    local length = (t_pos - parent_pos).length
                    if length <= dist then
                        target      = near
                        target_pos  = t_pos
                        dist        = length
                    end
                end
            end
        end

        -- Get nearest enemy actor
        -- if no projectile was found
        if not target then
            local near = GM.find_target_nearest(parent_pos.x, parent_pos.y, 1)
            if Instance.exists(near) then
                local t_pos = Vector(near.x, near.y)
                if (t_pos - parent_pos).length <= max_fire_range then
                    local actor = near.parent
                    if Instance.exists(actor) then
                        target      = actor
                        target_type = 1
                        target_pos  = t_pos
                    end
                end
            end
        end
    end

    -- Intercept / Deal damage
    if target then
        inst_data.charge = 0

        -- Create tracer line and sparks
        local obj = Object.find("efLineTracer", "ror")
        local tracer = obj:create(pos.x + (inst.image_xscale * 4), pos.y - 1)
        tracer.xend = target_pos.x
        tracer.yend = target_pos.y
        tracer.bm = 1
        tracer.rate = 0.11
        tracer.width = 2
        tracer.image_blend = color
        tracer.depth = -2

        local obj = Object.find("efSparks", "ror")
        local sparks = obj:create(target_pos.x, target_pos.y)
        sparks.sprite_index = gm.constants.sSparks1
        sparks.image_blend = color

        -- Act on target
        -- Notes: Online, clients can destroy NoSync projectiles
        -- without host needing to and will take no damage from
        -- them since that damage is handled client-side
        if target_type == 0 then target:destroy()
        else
            if Util.bool(inst_data.following.is_local) then
                local attack_info = inst_data.following:fire_direct(target, damage_coeff, nil, nil, nil, nil, false).attack_info
                attack_info:set_critical(false)
                attack_info.damage_color = color
            end
        end

        -- Set facing direction and prevent
        -- flipping directions for a bit
        inst_data.facing_direction = math.sign(target_pos.x - pos.x)
        inst_data.force_direction_timer:start(required_charge * 60)
    end
end)


Callback.add(object.on_draw, function(inst)
    local inst_data = Instance.get_data(inst)
    if inst_data.destroy then return end

    local inst_x = inst.x

    -- Set facing direction
    if inst_data.force_direction_timer.finished then
        inst_data.facing_direction = math.sign(inst_data.destination.x - inst_x)
    end

    -- Rotate
    local face_offset_to = inst_data.facing_direction * 4
    inst_data.face_offset = inst_data.face_offset + math.sign(face_offset_to - inst_data.face_offset) / 2.5

    -- Set body direction
    local offset_direction = math.sign(inst_data.face_offset)
    if offset_direction == 0 then offset_direction = 1 end
    inst.image_xscale = offset_direction

    -- Draw face
    -- Stretch when close to center to simulate 3D rotation
    GM.draw_sprite_ext(
        sprite_face,
        inst.image_index,
        inst_x + inst_data.face_offset,
        inst.y,
        -- Cubic easeout is a good enough approximation for a circle
        (1 + math.easeout((4 - math.abs(inst_data.face_offset)) * 0.1, 3)) * offset_direction,
        1,
        0,
        Color.WHITE,
        1
    )
end)


Callback.add(Callback.ON_PLAYER_DEATH, function(player)
    -- Check item count
    local stack = player:item_count(Item.find("phiConstruct"))
    if stack <= 0 then return end

    -- Find construct
    local insts = Instance.find_all(object)
    for _, inst in ipairs(insts) do
        local inst_data = Instance.get_data(inst)
        
        if inst_data.parent == player then
            -- Allow following player drone in multiplayer
            inst_data.find_new_following = true
            return
        end
    end
end)