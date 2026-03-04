-- Phi Construct (Object)

local object = Object.new("phiConstructObject")


-- ===== Assets =====

local sprite_body = Sprite.new("object/phiConstructBody", "~/assets/sprites/objects/phiConstructBody.png", 4, 8, 8)
local sprite_face = Sprite.new("object/phiConstructFace", "~/assets/sprites/objects/phiConstructFace.png", 4, 8, 8)
local sound       =  Sound.new("object/phiConstructShoot", "~/assets/sounds/objects/phiConstructShoot.ogg")

local color = Color(0x40E0D0)


-- ===== Properties =====

object:set_sprite(sprite_body)
object:set_depth(-1)

local speed_div         = 20    -- speed = distance from destination / speed_div
local max_wander_range  = 64    -- If outside this range (in pixels), move directly towards parent
local max_fire_range    = 256   -- Always centered at parent position

local base_fire_rate            = 0.7   -- Base delay (in seconds) between shots
local fire_rate_base_scaling    = 1.0   -- Base % per max shield point
local fire_rate_stack_scaling   = 0.5   -- Additional % per max shield point
local damage_coeff              = 0.7   -- Base damage coefficient


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

    inst_data.part_spark_timer = Timer()
    inst_data.part_move_timer = Timer()
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

    -- Avoid null vector (i.e., positions are the same)
    if length == 0 then
        vec = Vector.RIGHT
        length = 1
    end

    -- Set destination
    -- Move towards parent if too far
    if length > max_wander_range then
        inst_data.destination = parent_pos + (vec:normalized() * (max_wander_range * 0.95))
        inst_data.max_speed = math.huge

    -- Otherwise move randomly
    -- with a fixed max speed
    elseif inst_data.wander_timer.finished
       and inst_data.force_direction_timer.finished then
        vec.direction = vec.direction + math.random(0, 359)
        inst_data.wander_timer:start(math.random(60, 120))
        inst_data.destination = parent_pos + (vec:normalized() * math.random(16, max_wander_range * 0.5))
        inst_data.max_speed = 2
    end

    -- Move towards destination
    local vec = inst_data.destination - pos
    local length = vec.length
    local speed = math.min(length / speed_div, inst_data.max_speed)
    if length > math.max(speed, 2) then
        pos = pos + (vec:normalized() * speed)
    end
    inst.x, inst.y = pos.x, pos.y

    local xscale = inst.image_xscale

    -- Create spark particles (rate scaling with move speed)
    if inst_data.part_spark_timer.finished then
        inst_data.part_spark_timer:start(math.random(90, 120) / math.max(speed * 1.5, 1))

        local part = Particle.find("SparkB")
        part:create(pos.x + (xscale * 4), pos.y + 2)
    end

    -- Create particles when moving (rate scaling with move speed)
    if  inst_data.part_move_timer.finished
    and speed > 1 then
        inst_data.part_move_timer:start(math.random(30, 45) / math.max(speed * 1.5, 1))

        local part = Particle.find("PixelDust")
        local dir = vec.direction - 180 + math.random(-25, 25)
        part:set_direction(dir, dir, 0, 0)
        part:create(pos.x - (xscale * 6), pos.y, 1, Particle.System.BELOW)
    end


    -- Increment charge
    local x = (fire_rate_base_scaling + (fire_rate_stack_scaling * (stack - 1))) * inst_data.parent.maxshield
    local scaling = ( (35 * math.sqrt(0.3 * (x + 50))) - 135 )/100
    local required_charge = base_fire_rate / (1 + scaling)
    inst_data.charge = math.min(inst_data.charge + 1/60, required_charge)

    -- Get nearest enemy projectile (prioritized) or enemy actor
    local target
    local target_type = 0   -- 0 - projectile, 1 - actor
    local target_pos = Vector.ZERO
    local dist = max_fire_range

    local frame = Global._current_frame

    if inst_data.charge >= required_charge then
        -- Get nearest enemy projectile
        -- Check only half the "enemy_projectile" objs on any given frame
        local parity = frame % 2
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
        local obj = Object.find("EfLineTracer", "ror")
        local tracer = obj:create(pos.x + (xscale * 4), pos.y - 1)
        tracer.xend = target_pos.x
        tracer.yend = target_pos.y
        tracer.bm = 1
        tracer.rate = 0.07
        tracer.width = 2
        tracer.image_blend = color
        tracer.depth = -2

        -- Create firing particles
        local part = Particle.find("FireIce")
        part:create(pos.x + (xscale * 8), pos.y, 4)

        -- Create particles on target
        local part = Particle.find("JellyBrain")
        for i = 1, 4 do
            local dir = math.random(0, 359)
            part:set_direction(dir, dir, 0, 0)
            part:create(target_pos.x + math.random(-4, 4), target_pos.y + math.random(-4, 4))
        end

        -- Act on target
        -- Notes: Online, clients can destroy NoSync projectiles
        -- without host needing to and will take no damage from
        -- them since that damage is handled client-side
        if target_type == 0 then target:destroy()
        else
            -- Deal damage (done by local player)
            if Util.bool(inst_data.following.is_local) then
                local attack_info = inst_data.following:fire_direct(target, damage_coeff, nil, nil, nil, nil, false).attack_info
                attack_info:set_critical(false)
                attack_info.damage_color = color
            end

            -- Play sfx
            sound:play(pos.x + (xscale * 4), pos.y, 0.5, math.randomf(0.5, 0.8))
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
    local inst_y = inst.y

    -- Set facing direction
    if inst_data.force_direction_timer.finished then
        inst_data.facing_direction = math.sign(inst_data.destination.x - inst_x)
    end

    -- Rotate (i.e., slide face over to other side)
    local face_offset_to = inst_data.facing_direction * 4
    if math.abs(inst_data.face_offset - face_offset_to) > 0.0001 then
        inst_data.face_offset = inst_data.face_offset + math.sign(face_offset_to - inst_data.face_offset) / 2.5
    end

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
        inst_y,
        -- Cubic easeout is a good enough approximation for a circle
        (1 + (math.easeout(1 - math.abs(inst_data.face_offset / 4), 3) * 0.5)) * offset_direction,
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