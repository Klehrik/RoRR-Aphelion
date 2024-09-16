-- Whimsical Star

local sprite = Resources.sprite_load("aphelion", "whimsicalStar", PATH.."assets/sprites/whimsicalStar.png", 1, 16, 16)

local item = Item.new("aphelion", "whimsicalStar")
item:set_sprite(sprite)
item:set_tier(Item.TIER.rare)
item:set_loot_tags(Item.LOOT_TAG.category_utility)

item:onPickup(function(actor, stack)
    local actor_data = actor:get_data("aphelion-whimsicalStar")
    if not actor_data.insts then actor_data.insts = {} end

    local count = 3
    if stack >= 2 then count = 2 end
    for i = 1, count do
        local obj = Object.find("aphelion", "whimsicalStarObject")
        local inst = obj:create(actor.x, actor.y)
        inst.parent = actor
        inst.number = #actor_data.insts
        inst.prev = actor
        if i > 1 then inst.prev = actor_data.insts[#actor_data.insts] end
        table.insert(actor_data.insts, inst)
    end
end)

item:onRemove(function(actor, stack)
    local actor_data = actor:get_data("aphelion-whimsicalStar")
    local count = 3
    if stack >= 2 then count = 2 end
    for i = 1, count do
        local inst = actor_data.insts[#actor_data.insts]
        if inst:exists() then inst:destroy() end
        table.remove(actor_data.insts)
    end
end)



-- Object

local sprite = Resources.sprite_load("aphelion", "whimsicalStarObject", PATH.."assets/sprites/whimsicalStarObject.png", 1, 98, 98, 1, -90, -90, 90, 90)

local obj = Object.new("aphelion", "whimsicalStarObject")
obj:set_sprite(sprite)
obj:set_depth(-1)

obj:onCreate(function(self)
    self.persistent = true

    self.hsp = gm.random_range(-3.0, 3.0)
    self.vsp = gm.random_range(-3.0, 3.0)
    
    self.damage_coeff = 0.75

    self.intercept_range = 350
    self.intercept_target = -4
    self.intercept_x_start = 0
    self.intercept_y_start = 0
    self.intercept_frame = 0
    self.intercept_frame_max = 12.0    -- Will lerp to target position in 12 frames

    self.cd_hit = 0
    self.cd_hit_max = 40
    self.cooldown = 0
    self.cooldown_max = 60
end)

obj:onStep(function(self)
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

obj:onStep(function(self)
    -- Reduce hit cooldown
    if self.cd_hit > 0 then
        self.cd_hit = self.cd_hit - 1
        return
    end

    -- Get all collisions with pActors
    local actors = self:get_collisions(gm.constants.pActor, gm.constants.oWormBody, gm.constants.oWurmBody)

    -- Deal area damage on enemy collision
    for _, actor in ipairs(actors) do
        if (actor.team and actor.team ~= self.parent.team)
        or (actor.parent and actor.parent.team and actor.parent.team ~= self.parent.team) then
            self.parent:fire_explosion(self.x, self.y, self.bbox_right - self.bbox_left, self.bbox_bottom - self.bbox_top, self.damage_coeff, nil, Color(0xA5C28C), nil, nil, {
                Actor.DAMAGER.no_crit,
                Actor.DAMAGER.no_proc
            })
            self.cd_hit = self.cd_hit_max
            break
        end
    end
end)

obj:onStep(function(self)
    -- Reduce intercept cooldown
    if self.cooldown > 0 then
        self.cooldown = self.cooldown - 1
        return
    end

    -- Get nearest projectile to intercept
    if not Instance.exists(self.intercept_target) then
        local found = false
        local dist = self.intercept_range
        local projs = Instance.find_all(Instance.projectiles)
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
        -- Many projectiles have no collision mask until they
        -- reach their destination, so checking by distance instead
        if gm.point_distance(self.x, self.y, proj.x, proj.y) <= 12.0 then
            proj:destroy()
            self.cooldown = self.cooldown_max
        end
    end
end)

obj:onStep(function(self)
    -- Set star size
    if not self.size_set then
        self.size_set = true

        local px = (12 + (self.number * 4)) / 195.0
        if self.number > 2 then px = gm.irandom_range(12, 20) / 195.0 end
        self.image_xscale = px
        self.image_yscale = px
    end

    -- Set sprite stuff
    self.image_blend = Color.WHITE
    self.image_alpha = 1.0
    if self.cooldown > 0 then
        self.image_blend = 12632256
        self.image_alpha = 0.6
    end
end)



-- Achievement
item:add_achievement()

Actor.add_callback("onSkillUse", function(actor)
    if not actor:same(Player.get_client()) then return end
    actor.aphelion_whimsicalStar_achievement_check = 2
end, Skill.find("ror-commandoX"))

Actor.add_callback("onPreStep", function(actor)
    if actor.aphelion_whimsicalStar_achievement_check and actor.aphelion_whimsicalStar_achievement_check > 0 then
        actor.aphelion_whimsicalStar_achievement_check = actor.aphelion_whimsicalStar_achievement_check - 1
        if actor.aphelion_whimsicalStar_achievement_check <= 0 then actor.aphelion_whimsicalStar_achievement_check = nil end
    end
end)

Actor.add_callback("onPostAttack", function(actor, damager)
    if not actor.aphelion_whimsicalStar_achievement_check then return end
    if damager.kill_number >= 7 then
        item:progress_achievement()
    end
end)