-- Explosive Spear

local sprite    = Sprite.new("item/explosiveSpear", "~/assets/sprites/items/explosiveSpear.png", 1, 16, 16)
local sound     = Sound.new("explosiveSpearThrow", "~/assets/sounds/explosiveSpearThrow.ogg")

local item = Item.new("explosiveSpear")
item:set_sprite(sprite)
item:set_tier(ItemTier.UNCOMMON)
item:set_loot_tags(Item.LootTag.CATEGORY_DAMAGE)
ItemLog.new_from_item(item)

-- Doing Object creation here to use the ID
local object = Object.new("explosiveSpearObject")

Callback.add(Callback.ON_HIT_PROC, function(actor, victim, hit_info)
    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Do not proc if the hit does not deal at least 200% base damage
    if hit_info.damage < actor.damage * 2 then return end

    -- Get target direction
    local actor_x = actor.x
    local dir = math.sign(hit_info.target.x - actor_x)

    -- Check cooldown (10 seconds)
    -- (current frame - last thrown frame)
    local actor_data = Instance.get_data(actor, "explosiveSpear")
    if not actor_data.last_thrown_frame then actor_data.last_thrown_frame = -600 end
    local current_frame = Global._current_frame
    if current_frame - actor_data.last_thrown_frame >= 10 *60 then
        -- Store current frame
        actor_data.last_thrown_frame = current_frame

        -- Throw spear
        local inst = object:create(actor_x, actor.y)
        local inst_data = Instance.get_data(inst)
        inst_data.parent = actor
        inst_data.direction = dir
        inst_data.damage = hit_info.damage
        inst_data.calculate_damage(stack)   -- Defined below in `on_create` callback
        sound:play(actor_x, actor.y, 1, 1 + math.randomf(-0.2, 0.2))
    end
end)



-- Object

-- TODO
-- make sure it doesn't hit the immediate wall on throw (if standing next to one)
-- sync properly

local sprite        = Sprite.new("object/explosiveSpear", "~/assets/sprites/objects/explosiveSpear.png", 1, 36, 3, 1, -20, -5, -3, 3)
local sound_hit     = Sound.new("explosiveSpearHit", "~/assets/sounds/explosiveSpearHit.ogg")
local sound_explode = Sound.new("explosiveSpearExplode", "~/assets/sounds/explosiveSpearExplode.ogg")

object:set_sprite(sprite)   -- This sprite is just to have a hitbox
object:set_depth(-1)

Callback.add(object.on_create, function(self)
    -- Manually drawn in on_draw
    self.image_alpha = 0

    -- Variables
    local self_data = Instance.get_data(self)

    self_data.hsp = 16
    self_data.vsp = -1.6
    self_data.direction = 0     -- -1 or 1
    self_data.gravity = 0.12

    self_data.damage = 0
    self_data.damage_coeff_pop = 0
    self_data.damage_coeff_explosion = 0
    self_data.explosion_radius = 100

    self_data.calculate_damage = function(stack)
        self_data.damage_coeff_pop = 0.08 + (0.08 * stack)
        self_data.damage_coeff_explosion = 1 + (1 * stack)
    end
    
    self_data.hit = -4
    self_data.hit_type = 0  -- 1 is actor, 2 is terrain
    self_data.hit_offset_x = 0
    self_data.hit_offset_y = 0
    self_data.tick = 85     -- -1 per frame after hitting; explodes at 0

    -- Cloth physics
    self_data.nodes = {}
    local x = self.x
    local y = self.y
    local prev = nil
    for i = 1, 20 do
        local node = {
            x = x,
            y = y,
            x_prev = x,
            y_prev = y,
            wind = 0.25,
            gravity = 0.8,
            length = 1,
            size = 3
        }
        if prev then node.parent = prev end
        prev = node
        table.insert(self_data.nodes, node)
    end

    self:instance_sync()
end)

Callback.add(object.on_step, function(self)
    local self_data = Instance.get_data(self)

    -- Destroy self if parent no longer exists
    if not Instance.exists(self_data.parent) then
        self:destroy()
        return
    end

    local self_x = self.x
    local self_y = self.y


    -- Fly through the air
    if self_data.hit_type == 0 then

        -- Move
        self_x = self_x + (self_data.hsp * self_data.direction)
        self_y = self_y + self_data.vsp
        self_data.vsp = self_data.vsp + self_data.gravity

        self.x = self_x
        self.y = self_y

        -- Actor collision
        local actors = self:get_collisions(gm.constants.pActorCollisionBase)
        for _, actor in ipairs(actors) do

            -- Check if actor is hittable
            if GM.actor_canhit(self_data.parent, actor)
            or (actor.parent and GM.actor_canhit(self_data.parent, actor.parent)) then
                self_data.hit = actor
                self_data.hit_type = 1
                self_data.hit_offset_x = self_x - actor.x
                self_data.hit_offset_y = self_y - actor.y
                sound_hit:play(self_x, self_y, 1, 1 + math.randomf(-0.1, 0.1))
                break
            end
        end

        -- Wall collision
        if self:is_colliding(gm.constants.pSolidBulletCollision) then
            self_data.hit_type = 2
            sound_hit:play(self_x, self_y, 1, 1 + math.randomf(-0.1, 0.1))
        end

        -- Set image_angle to be current velocity
        self.image_angle = math.direction(0, 0, self_data.hsp * self_data.direction, self_data.vsp)

        -- Destroy when falling out of the map
        if (self_y >= Global.room_height) and (self_data.hit_type == 0) then
            self:destroy()
        end


    -- Process hit
    else
        self_data.tick = self_data.tick - 1

        local c_red = Color("ff004d")
        local hit_actor = self_data.hit
        local hit_exists = Instance.exists(hit_actor)

        if hit_exists then
            -- Move with hit actor
            self_x = hit_actor.x + self_data.hit_offset_x
            self_y = hit_actor.y + self_data.hit_offset_y

            self.x = self_x
            self.y = self_y

            -- Deal pop damage every 25 ticks
            -- if Player.get_local() == self_data.parent then
            if not Net.is_client() then
                if  (self_data.tick > 0)
                and (self_data.tick % 25 == 0) then
                    -- Get actual actor (if this is just a segment or something)
                    if type(hit_actor) ~= "Actor" then hit_actor = hit_actor.parent end

                    local damage = self_data.damage * self_data.damage_coeff_pop
                    local inst = self_data.parent:fire_direct(hit_actor, damage, nil, nil, nil, nil, false)
                    local attack_info = inst.attack_info
                    attack_info.damage_color = c_red
                    attack_info:use_raw_damage()
                    attack_info:set_critical(false)
                    attack_info:set_knockback(math.sign(self_data.hsp), 30)
                end
            end
        end

        -- Explode
        -- if Player.get_local() == self_data.parent then
        if not Net.is_client() then
            if (self_data.tick <= 0) or ((not hit_exists) and (self_data.hit_type == 1)) then
                local damage = self_data.damage * self_data.damage_coeff_explosion
                local inst = self_data.parent:fire_explosion(self_x, self_y, self_data.explosion_radius * 2, self_data.explosion_radius * 2, damage, nil, nil, false)
                local attack_info = inst.attack_info
                attack_info.damage_color = c_red
                attack_info:use_raw_damage()
                attack_info:set_critical(false)
                attack_info:set_knockback(math.sign(self_data.hsp), 2 *60)
                -- attack_info.aphelion_explosiveSpearExplosion = true

                sound_explode:play(self_x, self_y, 1, 1 + gm.random_range(-0.2, 0.2))
                self:destroy()
            end
        end
    end
end)

-- DamageCalculate.add(function(api)
--     -- Prevent crit on explosion
--     -- TODO fix for mp (hit_info does not exist)
--     api.hit_info.attack_info:print()
--     -- if api.hit_info.attack_info.aphelion_explosiveSpearExplosion then
--     --     api.set_critical(false)
--     -- end
-- end)

Callback.add(object.on_draw, function(self)
    local self_data = Instance.get_data(self)

    -- Spear
    local x = self.x
    local y = self.y
    local dir = self.image_angle
    local length = 34
    local tip = 6
    local cols = { Color("424647"), Color("25272b") }
    for i = 1, 0, -1 do
        local c = cols[i + 1]
        Draw.line(
            x + (math.dcos(dir) * tip) + (-4 * math.sign(self_data.hsp) * i),
            y - (math.dsin(dir) * tip) + i,
            x + (math.dcos(dir - 180) * length) + (-4 * math.sign(self_data.hsp) * i),
            y - (math.dsin(dir - 180) * length) + i,
            2, c
        )
    end


    -- Cloth : Move
    for _, n in ipairs(self_data.nodes) do
        -- Starting node
        if not n.parent then
            n.x = self.x
            n.y = self.y

        else
            -- Calculate velocities
            local vx = (n.x - n.x_prev) * 0.2
            local vy = (n.y - n.y_prev) * 0.4

            -- Update saved previous position
            n.x_prev = n.x
            n.y_prev = n.y

            -- Apply velocities
            local wind = math.abs(math.dsin(Global.current_time / 10) * n.wind)
            n.x = n.x + vx + wind
            n.y = n.y + vy + n.gravity
        end
    end

    -- Cloth : Apply constraints
	for _, n in ipairs(self_data.nodes) do
        if n.parent then
            local dist = math.distance(n.x, n.y, n.parent.x, n.parent.y)
            if dist > n.length then
                local dir = math.direction(n.parent.x, n.parent.y, n.x, n.y)
                n.x = n.parent.x + (math.dcos(dir) * n.length)
                n.y = n.parent.y - (math.dsin(dir) * n.length)
            end
        end
	end

    -- Cloth : Draw
    local cols = { Color("ff004d"), Color("be1250") }
    for i = 1, 0, -1 do
        for _, n in ipairs(self_data.nodes) do
            Draw.circle(n.x, n.y + i, n.size, false, cols[i + 1])
        end
    end


    -- Explosion Radius
    if self_data.hit_type > 0 then
        Draw.alpha(math.min(85 - self_data.tick, 75) / 75 * 0.4)
        Draw.circle_precision(64)

        local radius = math.easeout(math.min(85 - self_data.tick, 75) / 75, 3) * self_data.explosion_radius
        Draw.circle(self.x, self.y, radius, true, Color.WHITE)

        Draw.alpha(1)
        Draw.circle_precision()
    end
end)

Callback.add(object.on_destroy, function(self)
    self:instance_destroy_sync()
end)

Object.add_serializers(object,
    -- Serialize
    function(self, buffer)
        local inst_data = Instance.get_data(self)
        buffer:write_instance(inst_data.parent)
        buffer:write_short(inst_data.direction)
        buffer:write_int(inst_data.damage)
    end,

    -- Deserialize
    function(self, buffer)
        local inst_data = Instance.get_data(self)
        inst_data.parent = buffer:read_instance()
        inst_data.direction = buffer:read_short()
        inst_data.damage = buffer:read_int()
        inst_data.calculate_damage(inst_data.parent:item_count(item))
        sound:play(inst_data.parent.x, inst_data.parent.y, 1, 1 + math.randomf(-0.2, 0.2))
    end
)