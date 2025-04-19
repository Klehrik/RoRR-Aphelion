-- Whimsical Star

local sprite = Sprite.new("item/whimsicalStar", "~/assets/sprites/items/whimsicalStar.png", 1, 16, 16)

local item = Item.new("whimsicalStar")
item:set_sprite(sprite)
item:set_tier(ItemTier.RARE)
item:set_loot_tags(
    Item.LootTag.CATEGORY_DAMAGE,
    Item.LootTag.CATEGORY_UTILITY
)
ItemLog.new_from_item(item)

-- Doing Object creation here to use the ID
local object = Object.new("whimsicalStarObject")

Callback.add(item.on_acquired, function(actor, stack)
    -- Table holding star follow chain in order
    local actor_data = Instance.get_data(actor, "whimsicalStar")

    -- Create new stars
    local count = 3
    if stack >= 2 then count = 2 end
    for i = 1, count do
        -- Create star
        local inst = object:create(actor.x, actor.y)

        -- Set star variables
        local inst_data = Instance.get_data(inst)
        inst_data.parent = actor

        -- Set size
        -- Sprite size is 195 px^2
        local size = (12 + (#actor_data * 4)) / 195
        if #actor_data > 3 then size = math.random(12, 20) / 195 end
        inst.image_xscale = size
        inst.image_yscale = size

        -- Link to previous star in follow chain
        -- or `actor` if this is the first star
        inst_data.prev = actor
        if #actor_data > 0 then inst_data.prev = actor_data[#actor_data] end
        table.insert(actor_data, inst)
    end
end)

Callback.add(item.on_removed, function(actor, stack)
    local actor_data = Instance.get_data(actor, "whimsicalStar")

    -- Destroy stars
    local count = 3
    if stack >= 2 then count = 2 end
    for i = 1, count do
        local inst = actor_data[#actor_data]
        if inst:exists() then inst:destroy() end
        table.remove(actor_data, #actor_data)
    end
end)



-- Object

local sprite = Sprite.new("object/whimsicalStar", "~/assets/sprites/objects/whimsicalStar.png", 1, 98, 98, 1, -90, -90, 90, 90)

object:set_sprite(sprite)
object:set_depth(-1)

Callback.add(object.on_create, function(self)
    -- Allow star to persist between stages
    self.persistent = true

    -- Variables
    local self_data = Instance.get_data(self)

    self_data.hsp = math.random(-3, 3)
    self_data.vsp = math.random(-3, 3)
    self_data.acceleration = 0.15
    self_data.max_speed = 4
    
    self_data.damage_coeff = 0.9

    self_data.intercept_range = 350
    self_data.intercept_target = Instance.wrap(-4)
    self_data.intercept_x_start = 0
    self_data.intercept_y_start = 0
    self_data.intercept_frame = 0
    self_data.intercept_frame_max = 12  -- Will lerp to target position in 12 frames

    self_data.hit_cooldown = 0
    self_data.hit_cooldown_max = 40     -- Hits every 40 frames (0.66 sec)
    self_data.intercept_cooldown = 0
    self_data.intercept_cooldown_max = 60
end)

Callback.add(object.on_step, function(self)
    local self_data = Instance.get_data(self)

    -- Destroy self if parent no longer exists
    if not self_data.prev:exists() then
        self:destroy()
        return
    end

    -- Follow previous star in chain
    local x, y = self.x, self.y
    local acc = self_data.acceleration

    if self_data.prev.x < x then self_data.hsp = self_data.hsp - acc
    else self_data.hsp = self_data.hsp + acc
    end

    if self_data.prev.y < y then self_data.vsp = self_data.vsp - acc
    else self_data.vsp = self_data.vsp + acc
    end

    -- Clamp max speed
    local max_speed = self_data.max_speed
    if math.abs(self_data.hsp) > max_speed then self_data.hsp = max_speed * gm.sign(self_data.hsp) end
    if math.abs(self_data.vsp) > max_speed then self_data.vsp = max_speed * gm.sign(self_data.vsp) end

    -- Apply movement
    self.x = x + self_data.hsp
    self.y = y + self_data.vsp


    -- Reduce cooldowns
    self_data.hit_cooldown = math.max(self_data.hit_cooldown - 1, 0)
    self_data.intercept_cooldown = math.max(self_data.intercept_cooldown - 1, 0)


    -- Collision damage
    if self_data.hit_cooldown <= 0 then
        -- Get all collisions with pActors
        local actors = self:get_collisions(gm.constants.pActorCollisionBase)

        -- Deal area damage on enemy collision
        for _, target in ipairs(actors) do
            if (GM.actor_canhit(self_data.parent, target))
            or (target.parent and GM.actor_canhit(self_data.parent, target.parent)) then
            -- if (actor.team and actor.team ~= self_data.parent.team)
            -- or (actor.parent and actor.parent.team and actor.parent.team ~= self_data.parent.team) then
                local inst = self_data.parent:fire_explosion(self.x, self.y, self.bbox_right - self.bbox_left, self.bbox_bottom - self.bbox_top, self_data.damage_coeff, nil, nil, false)
                local attack_info = inst.attack_info
                -- attack_info:set_color(Color(0xA5C28C))
                -- attack_info:set_critical(false)

                self_data.hit_cooldown = self_data.hit_cooldown_max
                break
            end
        end
    end
end)

-- Callback.add(object.on_draw, function(self)
--     Draw.rectangle(self.bbox_left, self.bbox_top, self.bbox_right, self.bbox_bottom, true)
-- end)

-- object:onStep(function(self)
--     local self_data = self:get_data()

--     -- Destroy self if parent no longer exists
--     if not self_data.prev:exists() then
--         self:destroy()
--         return
--     end


--     -- Follow "previous" star
--     local acc = 0.15

--     if self_data.prev.x < self.x then self_data.hsp = self_data.hsp - acc
--     else self_data.hsp = self_data.hsp + acc
--     end

--     if self_data.prev.y < self.y then self_data.vsp = self_data.vsp - acc
--     else self_data.vsp = self_data.vsp + acc
--     end

--     -- Clamp max speed
--     local max_speed = gm.clamp(gm.point_distance(self.x, self.y, self_data.parent.x, self_data.parent.y) / 28.0, 4.0, 12.0)
--     if math.abs(self_data.hsp) > max_speed then self_data.hsp = max_speed * gm.sign(self_data.hsp) end
--     if math.abs(self_data.vsp) > max_speed then self_data.vsp = max_speed * gm.sign(self_data.vsp) end

--     -- Move
--     if not self_data.intercept_target:exists() then
--         self.x = self.x + self_data.hsp
--         self.y = self.y + self_data.vsp
--     end


--     -- Reduce cooldowns
--     self_data.cd_hit = math.max(self_data.cd_hit - 1, 0)
--     self_data.cooldown = math.max(self_data.cooldown - 1, 0)


--     if self_data.cd_hit <= 0 then
--         -- Get all collisions with pActors
--         local actors = self:get_collisions(gm.constants.pActorCollisionBase)

--         -- Deal area damage on enemy collision
--         for _, actor in ipairs(actors) do
--             if (actor.team and actor.team ~= self_data.parent.team)
--             or (actor.parent and actor.parent.team and actor.parent.team ~= self_data.parent.team) then
--                 local attack_info = self_data.parent:fire_explosion(self.x, self.y, self.bbox_right - self.bbox_left, self.bbox_bottom - self.bbox_top, self_data.damage_coeff, nil, nil, false).attack_info
--                 attack_info:set_color(Color(0xA5C28C))
--                 attack_info:set_critical(false)

--                 self_data.cd_hit = self_data.cd_hit_max
--                 break
--             end
--         end
--     end


--     if self_data.cooldown <= 0 then
--         -- Get nearest projectile to intercept
--         if not self_data.intercept_target:exists() then
--             local found = false
--             local dist = self_data.intercept_range
--             local projs = Instance.find_all(Instance.projectiles)
--             for _, p in ipairs(projs) do
--                 if not p.aphelion_whimsicalStar_targetted then
--                     local d = gm.point_distance(self_data.parent.x, self_data.parent.y, p.x, p.y)
--                     if d <= dist then
--                         found = true
--                         dist = d
--                         self_data.intercept_target = p
--                     end
--                 end
--             end
--             if found then
--                 self_data.intercept_target.aphelion_whimsicalStar_targetted = true
--                 self_data.intercept_frame = 0
--                 self_data.intercept_x_start = self.x
--                 self_data.intercept_y_start = self.y
--             end

--         -- Intercept projectile
--         else
--             if self_data.intercept_frame < self_data.intercept_frame_max then self_data.intercept_frame = self_data.intercept_frame + 1 end

--             local proj = self_data.intercept_target

--             -- Move towards target
--             local interp = Helper.ease_out(self_data.intercept_frame / self_data.intercept_frame_max, 0.5)
--             self.x = self_data.intercept_x_start + ((proj.x - self_data.intercept_x_start) * interp)
--             self.y = self_data.intercept_y_start + ((proj.y - self_data.intercept_y_start) * interp)

--             -- Check for collision
--             -- Many projectiles have no collision mask until they
--             -- reach their destination, so checking by distance instead
--             if gm.point_distance(self.x, self.y, proj.x, proj.y) <= 12.0 then
--                 proj:destroy()
--                 self_data.cooldown = self_data.cooldown_max
--             end
--         end
--     end


--     -- Set star size
--     if not self_data.size_set then
--         self_data.size_set = true

--         local px = (12 + (self_data.number * 4)) / 195.0
--         if self_data.number > 2 then px = gm.irandom_range(12, 20) / 195.0 end
--         self.image_xscale = px
--         self.image_yscale = px
--     end

--     -- Set sprite stuff
--     self.image_blend = Color.WHITE
--     self.image_alpha = 1
--     if self_data.cooldown > 0 then
--         self.image_blend = 12632256
--         self.image_alpha = 0.6
--     end
-- end)