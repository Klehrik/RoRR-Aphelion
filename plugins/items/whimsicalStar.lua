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

local sprite = Resources.sprite_load(PATH.."assets/sprites/whimsicalStarObject.png", 1, false, false, 98, 98)

local obj = Object.create("aphelion", "whimsicalStar")
Object.set_hitbox(obj, -8, -8, 8, 8)

Object.add_callback(obj, "Init", function(self)
    self.persistent = true
    self.sprite_index = sprite

    self.hsp = gm.random_range(-3.0, 3.0)
    self.vsp = gm.random_range(-3.0, 3.0)
    
    self.damage_coeff = 0.7

    self.proj_check = 0
    self.intercept_range = 350
    self.intercept_target = -4
    self.intercept_x_start = 0
    self.intercept_y_start = 0
    self.intercept_frame = 0
    self.intercept_frame_max = 15.0    -- Will lerp to target position in 8 frames

    self.cd_hit = 0
    self.cd_hit_max = 40
    self.cooldown = 0
    self.cooldown_max = 90
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
    if not Instance.exists(self.intercept_target) then
        self.x = self.x + self.hsp
        self.y = self.y + self.vsp
    end
end)

Object.add_callback(obj, "Step", function(self)
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
            local damager = Actor.fire_explosion(self.parent, self.x, self.y, 8, 8, self.damage_coeff)
            damager.proc = false
            damager.damage_color = 9224869
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
    --      Check two types of projectiles every frame
    --      and not all of them to reduce load
    if not Instance.exists(self.intercept_target) then
        self.proj_check = self.proj_check + 2

        local found = false
        local dist = self.intercept_range
        for i = 0, 1 do
            local pos = ((self.proj_check + i) % #Instance.projectiles) + 1
            local ind = Instance.projectiles[pos]
            local projs = Instance.find_all(ind)
            for _, p in ipairs(projs) do
                if not p.aphelion_whimsicalStar_targetted then
                    local d = gm.point_distance(self.parent.x, self.parent.y, p.x, p.y)
                    if d <= dist then
                        found = true
                        dist = d
                        self.intercept_target = p
                    end
                end
            end
        end
        if found then
            self.intercept_target.aphelion_whimsicalStar_targetted = true
            self.intercept_frame = 0
            self.intercept_x_start = self.x
            self.intercept_y_start = self.y
        end

    -- Intercept projectile
    else
        if self.intercept_frame < self.intercept_frame_max then self.intercept_frame = self.intercept_frame + 1 end

        local proj = self.intercept_target

        -- Move towards target
        local interp = Helper.ease_out(self.intercept_frame / self.intercept_frame_max, 0.5)
        self.x = self.intercept_x_start + ((proj.x - self.intercept_x_start) * interp)
        self.y = self.intercept_y_start + ((proj.y - self.intercept_y_start) * interp)

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



-- Achievement
Item.add_achievement(item)

Actor.add_callback("onSkillUse", function(actor)
    actor.aphelion_whimsicalStar_achievement_check = 2
end, Actor.find_skill_id("ror-commandoX"))

Actor.add_callback("onPreStep", function(actor, damager)
    if actor.aphelion_whimsicalStar_achievement_check and actor.aphelion_whimsicalStar_achievement_check > 0 then
        actor.aphelion_whimsicalStar_achievement_check = actor.aphelion_whimsicalStar_achievement_check - 1
        if actor.aphelion_whimsicalStar_achievement_check <= 0 then actor.aphelion_whimsicalStar_achievement_check = nil end
    end
end)

Actor.add_callback("onPostAttack", function(actor, damager)
    if not actor.aphelion_whimsicalStar_achievement_check then return end
    if damager.kill_number >= 7 then
        Item.progress_achievement(Item.find("aphelion-whimsicalStar"))
    end
end)