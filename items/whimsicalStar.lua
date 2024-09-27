-- Whimsical Star

local sprite = Resources.sprite_load("aphelion", "whimsicalStar", PATH.."assets/sprites/whimsicalStar.png", 1, 16, 16)

local item = Item.new("aphelion", "whimsicalStar")
item:set_sprite(sprite)
item:set_tier(Item.TIER.rare)
item:set_loot_tags(Item.LOOT_TAG.category_utility)

item:onPickup(function(actor, stack)
    local actorData = actor:get_data("whimsicalStar")
    if not actorData.insts then actorData.insts = {} end

    local count = 3
    if stack >= 2 then count = 2 end
    for i = 1, count do
        local obj = Object.find("aphelion", "whimsicalStarObject")
        local inst = obj:create(actor.x, actor.y)
        local instData = inst:get_data()
        instData.parent = actor
        instData.number = #actorData.insts
        instData.prev = actor
        if i > 1 then inst.prev = actorData.insts[#actorData.insts] end
        table.insert(actorData.insts, inst)
    end
end)

item:onRemove(function(actor, stack)
    local actorData = actor:get_data("whimsicalStar")
    local count = 3
    if stack >= 2 then count = 2 end
    for i = 1, count do
        local inst = actorData.insts[#actorData.insts]
        if inst:exists() then inst:destroy() end
        table.remove(actorData.insts)
    end
end)



-- Object

local sprite = Resources.sprite_load("aphelion", "whimsicalStarObject", PATH.."assets/sprites/whimsicalStarObject.png", 1, 98, 98, 1, -90, -90, 90, 90)

local obj = Object.new("aphelion", "whimsicalStarObject")
obj:set_sprite(sprite)
obj:set_depth(-1)

obj:onCreate(function(self)
    local selfData = self:get_data()

    self.persistent = true
    self.image_alpha = 0

    selfData.hsp = gm.random_range(-3.0, 3.0)
    selfData.vsp = gm.random_range(-3.0, 3.0)
    
    selfData.damage_coeff = 0.75

    selfData.intercept_range = 350
    selfData.intercept_target = Instance.wrap_invalid()
    selfData.intercept_x_start = 0
    selfData.intercept_y_start = 0
    selfData.intercept_frame = 0
    selfData.intercept_frame_max = 12.0    -- Will lerp to target position in 12 frames

    selfData.cd_hit = 0
    selfData.cd_hit_max = 40
    selfData.cooldown = 0
    selfData.cooldown_max = 60
end)

obj:onStep(function(self)
    local selfData = self:get_data()

    -- Follow "previous" star
    local acc = 0.25

    if selfData.prev.x < self.x then selfData.hsp = selfData.hsp - acc
    else selfData.hsp = selfData.hsp + acc
    end

    if selfData.prev.y < self.y then selfData.vsp = selfData.vsp - acc
    else selfData.vsp = selfData.vsp + acc
    end

    -- Clamp max speed
    local max_speed = gm.clamp(gm.point_distance(self.x, self.y, selfData.parent.x, selfData.parent.y) / 28.0, 4.0, 12.0)
    if math.abs(selfData.hsp) > max_speed then selfData.hsp = max_speed * gm.sign(selfData.hsp) end
    if math.abs(selfData.vsp) > max_speed then selfData.vsp = max_speed * gm.sign(selfData.vsp) end

    -- Move
    if not selfData.intercept_target:exists() then
        self.x = self.x + selfData.hsp
        self.y = self.y + selfData.vsp
    end
end)

obj:onStep(function(self)
    local selfData = self:get_data()

    -- Reduce hit cooldown
    if selfData.cd_hit > 0 then
        selfData.cd_hit = selfData.cd_hit - 1
        return
    end

    -- Get all collisions with pActors
    local actors = self:get_collisions(gm.constants.pActor, table.unpack(Instance.worm_bodies))

    -- Deal area damage on enemy collision
    for _, actor in ipairs(actors) do
        if (actor.team and actor.team ~= selfData.parent.team)
        or (actor.parent and actor.parent.team and actor.parent.team ~= selfData.parent.team) then
            local damager = selfData.parent:fire_explosion(self.x, self.y, self.bbox_right - self.bbox_left, self.bbox_bottom - self.bbox_top, selfData.damage_coeff)
            damager:set_color(Color(0xA5C28C))
            damager:set_critical(false)
            damager:set_proc(false)

            selfData.cd_hit = selfData.cd_hit_max
            break
        end
    end
end)

obj:onStep(function(self)
    local selfData = self:get_data()

    -- Reduce intercept cooldown
    if selfData.cooldown > 0 then
        selfData.cooldown = selfData.cooldown - 1
        return
    end

    -- Get nearest projectile to intercept
    if not selfData.intercept_target:exists() then
        local found = false
        local dist = selfData.intercept_range
        local projs = Instance.find_all(Instance.projectiles)
        for _, p in ipairs(projs) do
            if not p.aphelion_whimsicalStar_targetted then
                local d = gm.point_distance(selfData.parent.x, selfData.parent.y, p.x, p.y)
                if d <= dist then
                    found = true
                    dist = d
                    selfData.intercept_target = p
                end
            end
        end
        if found then
            selfData.intercept_target.aphelion_whimsicalStar_targetted = true
            selfData.intercept_frame = 0
            selfData.intercept_x_start = self.x
            selfData.intercept_y_start = self.y
        end

    -- Intercept projectile
    else
        if selfData.intercept_frame < selfData.intercept_frame_max then selfData.intercept_frame = selfData.intercept_frame + 1 end

        local proj = selfData.intercept_target

        -- Move towards target
        local interp = Helper.ease_out(selfData.intercept_frame / selfData.intercept_frame_max, 0.5)
        self.x = selfData.intercept_x_start + ((proj.x - selfData.intercept_x_start) * interp)
        self.y = selfData.intercept_y_start + ((proj.y - selfData.intercept_y_start) * interp)

        -- Check for collision
        -- Many projectiles have no collision mask until they
        -- reach their destination, so checking by distance instead
        if gm.point_distance(self.x, self.y, proj.x, proj.y) <= 12.0 then
            proj:destroy()
            selfData.cooldown = selfData.cooldown_max
        end
    end
end)

obj:onStep(function(self)
    local selfData = self:get_data()

    -- Set star size
    if not selfData.size_set then
        selfData.size_set = true

        local px = (12 + (selfData.number * 4)) / 195.0
        if selfData.number > 2 then px = gm.irandom_range(12, 20) / 195.0 end
        self.image_xscale = px
        self.image_yscale = px
    end

    -- Set sprite stuff
    self.image_blend = Color.WHITE
    self.image_alpha = 1
    if selfData.cooldown > 0 then
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