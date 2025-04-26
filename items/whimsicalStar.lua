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
        if Instance.exists(inst) then inst:destroy() end
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

    self_data.hsp                       = math.random(-3, 3)
    self_data.vsp                       = math.random(-3, 3)
    self_data.acceleration              = 0.15
    self_data.max_speed                 = 4
    
    self_data.damage_coeff              = 0.75

    self_data.intercept_range           = 350
    self_data.intercept_target          = -4
    self_data.intercept_x_start         = 0
    self_data.intercept_y_start         = 0
    self_data.intercept_frame           = 0
    self_data.intercept_frame_max       = 12    -- Will lerp to target position in 12 frames

    self_data.hit_cooldown              = 0
    self_data.hit_cooldown_max          = 15    -- Hits every 15 frames (0.25 sec)
    self_data.intercept_cooldown        = 0
    self_data.intercept_cooldown_max    = 60
end)

Callback.add(object.on_step, function(self)
    local self_data = Instance.get_data(self)

    -- Destroy self if parent no longer exists
    if not Instance.exists(self_data.parent) then
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
        self_data.hit_cooldown = math.random(self_data.hit_cooldown_max - 1, self_data.hit_cooldown_max + 1)

        -- Fire explosion from the local player
        -- (Star movement is a chaotic system so it's not worth syncing)
        if Player.get_local() == self_data.parent then
            local inst = self_data.parent:fire_explosion(self.x, self.y, self.bbox_right - self.bbox_left, self.bbox_bottom - self.bbox_top, self_data.damage_coeff, nil, nil, false)
            local attack_info = inst.attack_info
            attack_info.damage_color = Color("a5c28c")
            attack_info:set_critical(false) -- Items cannot crit
        end
    end


    -- Projectile interception
    if self_data.intercept_cooldown <= 0 then

        -- Get nearest enemy projectile to intercept
        if not Instance.exists(self_data.intercept_target) then
            local found = false
            local min_dist = self_data.intercept_range

            -- Loop through all enemy projectile objects
            local objs = Object.find_by_tag("enemy_projectile")
            for _, obj in pairs(objs) do
                
                -- Loop through all instances of the object
                local insts = Instance.find_all(obj)
                for _, inst in ipairs(insts) do
                    local inst_data = Instance.get_data(inst, "whimsicalStar")

                    -- Check if instance is not already targeted
                    if not inst_data.targeted then
                    
                        -- Check if distance is closer than stored
                        local dist = self:distance_to(inst.x, inst.y)
                        if (dist <= min_dist) then
                            found = true
                            min_dist = dist
                            self_data.intercept_target = inst
                        end
                    end
                end
            end

            -- Mark target projectile as "targeted"
            if found then
                local target_data = Instance.get_data(self_data.intercept_target, "whimsicalStar")
                target_data.targeted = true

                self_data.intercept_frame = 0
                self_data.intercept_x_start = self.x
                self_data.intercept_y_start = self.y

            -- If no target is found, check again in a few frames
            -- to lessen burden of this running every frame
            else
                self_data.intercept_target = -4
                self_data.intercept_cooldown = math.random(2, 3)

            end

        -- Move to intercept projectile
        else
            -- Increment interception ease time
            self_data.intercept_frame = math.min(self_data.intercept_frame + 1, self_data.intercept_frame_max)

            local target = self_data.intercept_target

            -- Ease towards target
            local ease = math.easeout(self_data.intercept_frame / self_data.intercept_frame_max, 0.5)
            self.x = self_data.intercept_x_start + ((target.x - self_data.intercept_x_start) * ease)
            self.y = self_data.intercept_y_start + ((target.y - self_data.intercept_y_start) * ease)

            -- Check for collision
            -- Many projectiles have no collision mask until they
            -- reach their destination, so checking by distance instead
            if self:distance_to(target.x, target.y) <= 12 then
                target:destroy()
                self_data.intercept_target = -4
                self_data.intercept_cooldown = self_data.intercept_cooldown_max
            end
        end
    end


    -- Darken sprite while on intercept cooldown
    if self_data.intercept_cooldown > 3 then
        self.image_blend = 12632256
        self.image_alpha = 0.6

    -- Restore normal sprite
    elseif self_data.intercept_cooldown > 0 then
        self.image_blend = Color.WHITE
        self.image_alpha = 1
    end


    -- TODO
    -- visual: trail while moving
        -- no trail while on intercept cd
    -- maybe the stars can occasionally spin too :)
    -- also make particles on projectile interception
end)

Callback.add(Callback.ON_STAGE_START, function()
    -- Teleport all stars to owner on stage transition
    local insts = Instance.find_all(object)
    for _, inst in ipairs(insts) do
        local inst_data = Instance.get_data(inst)
        if Instance.exists(inst_data.parent) then
            inst.x = inst_data.parent.x
            inst.y = inst_data.parent.y
        end
    end
end)