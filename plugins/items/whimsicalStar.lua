-- Whimsical Star

local sprite = Resources.sprite_load(PATH.."assets/sprites/whimsicalStar.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "whimsicalStar")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.rare)
Item.set_loot_tags(item, Item.LOOT_TAG.category_utility)

Item.add_callback(item, "onPickup", function(actor, stack)
    if not actor.aphelion_whimsicalStar_insts then actor.aphelion_whimsicalStar_insts = gm.ds_list_create() end

    local count = 3
    if stack >= 2 then count = 2 end
    for i = 1, count do
        local inst = Object.spawn(Object.find("aphelion", "whimsicalStar"), actor.x, actor.y)
        inst.parent = actor
        inst.number = gm.ds_list_size(actor.aphelion_whimsicalStar_insts)
        inst.prev = actor
        if i > 1 then inst.prev = gm.ds_list_find_value(actor.aphelion_whimsicalStar_insts, gm.ds_list_size(actor.aphelion_whimsicalStar_insts) - 1) end
        gm.ds_list_add(actor.aphelion_whimsicalStar_insts, inst)
    end
end)

Item.add_callback(item, "onRemove", function(actor, stack)
    local count = 3
    if stack >= 2 then count = 2 end
    for i = 1, count do
        local inst = gm.ds_list_find_value(actor.aphelion_whimsicalStar_insts, gm.ds_list_size(actor.aphelion_whimsicalStar_insts) - 1)
        if Instance.exists(inst) then gm.instance_destroy(inst) end
        gm.ds_list_delete(actor.aphelion_whimsicalStar_insts, gm.ds_list_size(actor.aphelion_whimsicalStar_insts) - 1)
    end
end)



-- Object

local projectiles = {
    gm.constants.oJellyMissile,
    gm.constants.oSpiderBulletNoSync,
    gm.constants.oSpiderBullet,
    gm.constants.oGuardBulletNoSync,
    gm.constants.oGuardBullet,
    gm.constants.oWurmMissile
}

local sprite = Resources.sprite_load(PATH.."assets/sprites/whimsicalStarObject.png", 1, false, false, 98, 98)

local obj = Object.create("aphelion", "whimsicalStar")
Object.set_hitbox(obj, -8, -8, 8, 8)

Object.add_callback(obj, "Init", function(self)
    self.persistent = true
    self.sprite_index = sprite

    self.hsp = gm.random_range(-3.0, 3.0)
    self.vsp = gm.random_range(-3.0, 3.0)

    self.frame = 0
    self.damage_coeff = 0.75
    self.intercept_range = 350
    self.intercept_speed = 4.0
    self.intercept_target = -4

    self.cd_hit = 0
    self.cd_hit_max = 30
    self.cooldown = 0
    self.cooldown_max = 120
end)

Object.add_callback(obj, "Step", function(self)
    -- Follow "previous" star
    local acc = 0.25

    if self.prev.x < self.x then self.hsp = self.hsp - acc
    else self.hsp = self.hsp + acc
    end

    if self.prev.y < self.y then self.vsp = self.vsp - acc
    else self.vsp = self.vsp + acc
    end

    -- Clamp max speed
    local max_speed = gm.clamp(gm.point_distance(self.x, self.y, self.parent.x, self.parent.y) / 28.0, 4.0, 12.0)
    if math.abs(self.hsp) > max_speed then self.hsp = max_speed * gm.sign(self.hsp) end
    if math.abs(self.vsp) > max_speed then self.vsp = max_speed * gm.sign(self.vsp) end

    -- Move
    self.x = self.x + self.hsp
    self.y = self.y + self.vsp
end)

Object.add_callback(obj, "Step", function(self)
    self.frame = self.frame + 1

    -- Reduce hit cooldown
    if self.cd_hit > 0 then
        self.cd_hit = self.cd_hit - 1
        return
    end

    -- Get all collisions with pActors
    local actors = Object.get_collisions(self, gm.constants.pActor)

    -- Deal area damage on enemy collision
    for _, actor in ipairs(actors) do
        if actor.team and actor.team ~= self.parent.team then
            Actor.fire_explosion(self.parent, self.x, self.y, 8, 8, self.damage_coeff).proc = false
            self.cd_hit = self.cd_hit_max
            break
        end
    end
end)

Object.add_callback(obj, "Step", function(self)
    -- Reduce intercept cooldown
    if self.cooldown > 0 then
        self.cooldown = self.cooldown - 1
        return
    end

    -- Get nearest projectile to intercept
    if not Instance.exists(self.intercept_target) then
        local dist = self.intercept_range

        -- Check one type of projectile every frame
        -- and not all of them to reduce load
        local ind = projectiles[(self.frame % #projectiles) + 1]
        local projs = Instance.find_all(ind)
        for _, p in ipairs(projs) do
            local d = gm.point_distance(self.x, self.y, p.x, p.y)
            if d <= dist then
                self.intercept_target = p
                dist = d
            end
        end

    -- Intercept projectile
    else
        local proj = self.intercept_target

        -- Move towards target
        self.x = self.x + (self.intercept_speed * gm.sign(proj.x - self.x))
        self.y = self.y + (self.intercept_speed * gm.sign(proj.y - self.y))

        -- Check for collision
        if Object.is_colliding(self, proj) then
            gm.instance_destroy(proj)
            self.cooldown = self.cooldown_max
        end
    end
end)

Object.add_callback(obj, "Draw", function(self)
    -- Set star size
    if not self.size_set then
        self.size_set = true

        local px = (12 + (self.number * 4)) / 195.0
        if self.number > 2 then px = gm.irandom_range(12, 20) / 195.0 end
        self.image_xscale = px
        self.image_yscale = px
    end

    -- Draw self
    local blend = 16777215
    local alpha = 1.0
    if self.cooldown > 0 then
        blend = 12632256
        alpha = 0.6
    end
    gm.draw_sprite_ext(self.sprite_index, 0, self.x, self.y, self.image_xscale, self.image_yscale, self.image_angle, blend, alpha)
end)