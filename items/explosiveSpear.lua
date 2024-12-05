-- Explosive Spear

local sprite = Resources.sprite_load("aphelion", "item/explosiveSpear", PATH.."assets/sprites/items/explosiveSpear.png", 1, 16, 16)
local spriteCooldown = Resources.sprite_load("aphelion", "cooldown/explosiveSpear", PATH.."assets/sprites/cooldowns/explosiveSpear.png", 1, 4, 4)
local sound = Resources.sfx_load("aphelion", "explosiveSpearThrow", PATH.."assets/sounds/explosiveSpearThrow.ogg")

local item = Item.new("aphelion", "explosiveSpear")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:onHitProc(function(actor, victim, stack, hit_info)
    if Cooldown.get(actor, "aphelion-explosiveSpear") > 0 then return end
    
    -- Do not proc if the hit does not deal at least 200% base damage
    if hit_info.damage < actor.damage * 2.0 then return end

    local dir = gm.sign(target.x - actor.x)

    -- Create object
    local obj = Object.find("aphelion-explosiveSpearObject")
    local inst = obj:create(actor.x + (dir * 36.0), actor.y - 4.0)
    local instData = inst:get_data()
    instData.parent = actor
    instData.hsp = 20.0 * dir
    inst:sound_play_at(sound, 1.0, 1.0, inst.x, inst.y, nil)

    -- Calculate damage
    instData.pop_damage = hit_info.damage * (0.06 + (actor:item_stack_count(item) * 0.06))
    instData.damage = hit_info.damage * (1.0 + (actor:item_stack_count(item) * 1.5))

    -- Apply cooldown
    Cooldown.set(actor, "aphelion-explosiveSpear", 10 *60, spriteCooldown, Color(0xff004d))
end)



-- Object

local sprite = Resources.sprite_load("aphelion", "object/explosiveSpear", PATH.."assets/sprites/objects/explosiveSpear.png", 1, 36, 3, 1, -20, -5, -3, 3)
local explosive_192 = Resources.sprite_load("aphelion", "explosive_192", PATH.."assets/sprites/effects/explosive_192.png", 6, 96, 96)
local soundHit = Resources.sfx_load("aphelion", "explosiveSpearHit", PATH.."assets/sounds/explosiveSpearHit.ogg")
local soundExplode = Resources.sfx_load("aphelion", "explosiveSpearExplode", PATH.."assets/sounds/explosiveSpearExplode.ogg")

local obj = Object.new("aphelion", "explosiveSpearObject")
obj:set_sprite(sprite)
obj:set_depth(-1)

obj:onCreate(function(self)
    self.image_alpha = 0

    local selfData = self:get_data()

    selfData.vsp = -2.0
    selfData.grav = 0.18

    selfData.hit = Instance.wrap_invalid()
    selfData.hit_type = 0   -- 1 for ground
    selfData.hit_offset_x = 0
    selfData.hit_offset_y = 0

    selfData.tick = 85

    -- Cloth physics
    selfData.nodes = {}
    local prev = nil
    for i = 1, 20 do
        local node = {
            x = self.x,
            y = self.y,
            xPrev = self.x,
            yPrev = self.y,
            wind = 0.25,
            grav = 0.8,
            length = 1,
            size = 3
        }
        if prev then node.parent = prev end
        prev = node
        table.insert(selfData.nodes, node)
    end
end)

obj:onStep(function(self)
    local selfData = self:get_data()

    -- Destroy self if parent no longer exists
    if not selfData.parent:exists() then
        self:destroy()
        return
    end


    if not selfData.flag_hit then
        -- Move
        self.x = self.x + selfData.hsp
        self.y = self.y + selfData.vsp
        selfData.vsp = selfData.vsp + selfData.grav

        -- Actor collision
        local actors = self:get_collisions(gm.constants.pActorCollisionBase)
        for _, actor in ipairs(actors) do
            if (actor.team and actor.team ~= selfData.parent.team)
            or (actor.parent and actor.parent.team and actor.parent.team ~= selfData.parent.team) then
                selfData.flag_hit = true
                selfData.hit = actor
                selfData.hit_offset_x = actor.x - self.x
                selfData.hit_offset_y = actor.y - self.y
                self:sound_play_at(soundHit, 1.0, 1.0, self.x, self.y, nil)
                break
            end
        end

        -- Wall collision
        if self:is_colliding(gm.constants.pSolidBulletCollision) then
            selfData.flag_hit = true
            selfData.hit_type = 1
            self:sound_play_at(soundHit, 1.0, 1.0, self.x, self.y, nil)
        end

        -- Set image_angle
        self.image_angle = gm.point_direction(0, 0, selfData.hsp, selfData.vsp)
    end


    if selfData.flag_hit then
        selfData.tick = selfData.tick - 1

        local c_red = Color(0xFF004D)

        if selfData.hit:exists() then
            -- Embed into hit actor
            self.x = selfData.hit.x - selfData.hit_offset_x
            self.y = selfData.hit.y - selfData.hit_offset_y

            -- Deal pop damage
            if selfData.tick % 25 == 0 then
                local actor = selfData.hit
                if actor.RMT_object ~= "Actor" then actor = actor.parent end

                local attack_info = selfData.parent:fire_direct(actor, selfData.pop_damage, nil, nil, nil, nil, false).attack_info
                attack_info:use_raw_damage()
                attack_info:set_color(c_red)
                attack_info:set_critical(false)
                attack_info:set_stun(1)
            end
        end

        -- Explode
        if selfData.tick <= -20 or (selfData.hit_type == 0 and not selfData.hit:exists()) then
            local attack_info = selfData.parent:fire_explosion(self.x, self.y, 200, 200, selfData.damage, explosive_192, false).attack_info
            attack_info:use_raw_damage()
            attack_info:set_color(c_red)
            attack_info:set_critical(false)
            attack_info:set_stun(2.5)

            self:sound_play_at(soundExplode, 1.0, 1.0, self.x, self.y, nil)
            self:destroy()
        end
    end


    -- Destroy when falling out of map
    if self.y >= gm.variable_global_get("room_height") and not selfData.hit then
        self:destroy()
    end
end)

obj:onDraw(function(self)
    local selfData = self:get_data()

    -- Spear
    local dir = gm.point_direction(0, 0, selfData.hsp, selfData.vsp)
    local length = 34
    local tip = 6
    local cols = {Color(0x424647), Color(0x25272b)}
    for i = 1, 0, -1 do
        local c = cols[i + 1]
        gm.draw_line_width_color(
            self.x + (gm.dcos(dir) * tip) + (-4 * gm.sign(selfData.hsp) * i), self.y - (gm.dsin(dir) * tip) + i,
            self.x + (gm.dcos(dir - 180) * length) + (-4 * gm.sign(selfData.hsp) * i), self.y - (gm.dsin(dir - 180) * length) + i,
            2, c, c)
    end

    -- Cloth : Move
    for _, n in ipairs(selfData.nodes) do
        -- Starting node
        if not n.parent then
            n.x = self.x
            n.y = self.y

        else
            -- Calculate velocities
            local vx = (n.x - n.xPrev) * 0.2
            local vy = (n.y - n.yPrev) * 0.4

            -- Update saved previous position
            n.xPrev = n.x
            n.yPrev = n.y

            -- Apply velocities
            local wind = math.abs(gm.dsin(gm.variable_global_get("current_time")/10) * n.wind)
            n.x = n.x + vx + wind
            n.y = n.y + vy + n.grav
        end
    end

    -- Cloth : Apply constraints
	for _, n in ipairs(selfData.nodes) do
        if n.parent then
            local dist = gm.point_distance(n.x, n.y, n.parent.x, n.parent.y)
            if dist > n.length then
                local dir = gm.point_direction(n.parent.x, n.parent.y, n.x, n.y)
                n.x = n.parent.x + (gm.dcos(dir) * n.length)
                n.y = n.parent.y - (gm.dsin(dir) * n.length)
            end
        end
	end

    -- Cloth : Draw
    local cols = {Color(0xff004d), Color(0xbe1250)}
    for i = 1, 0, -1 do
        for _, n in ipairs(selfData.nodes) do
            local c = cols[i + 1]
            gm.draw_circle_color(n.x, n.y + i, n.size, c, c, false)
        end
    end

    -- Explosion Radius
    if selfData.flag_hit then
        -- Show explosion radius
        local radius = Helper.ease_out(math.min(85.0 - selfData.tick, 45.0) / 45.0) * 100
        gm.draw_set_circle_precision(64)
        gm.draw_set_alpha(0.5)
        local c = Color.WHITE
        gm.draw_circle(self.x, self.y, radius, c, c, true)
        gm.draw_set_alpha(1)
        gm.draw_set_circle_precision(24)
    end
end)