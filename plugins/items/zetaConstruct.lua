-- Zeta Construct

local sprite = Resources.sprite_load(PATH.."assets/sprites/whimsicalStar.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "zetaConstruct")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.uncommon)
Item.set_loot_tags(item, Item.LOOT_TAG.category_utility)

Item.add_callback(item, "onPickup", function(actor, stack)
    local increase = 20
    if stack > 1 then increase = 20 end
    actor.maxshield_base = actor.maxshield_base + increase

    if not actor.aphelion_zetaConstruct_inst then
        local inst = Object.spawn(Object.find("aphelion", "zetaConstruct"), actor.x, actor.y)
        inst.parent = actor
        actor.aphelion_zetaConstruct_inst = inst
    end
end)

Item.add_callback(item, "onRemove", function(actor, stack)
    local increase = 20
    if stack > 1 then increase = 20 end
    actor.maxshield_base = actor.maxshield_base - increase

    if stack <= 1 then
        if Instance.exists(actor.aphelion_zetaConstruct_inst) then gm.instance_destroy(actor.aphelion_zetaConstruct_inst) end
    end
end)



-- Object

local sprite = Resources.sprite_load(PATH.."assets/sprites/ration.png", 1, false, false, 16, 16)

local obj = Object.create("aphelion", "zetaConstruct")

Object.add_callback(obj, "Init", function(self)
    self.persistent = true
    self.sprite_index = sprite

    self.angle = gm.irandom_range(0, 359)
    self.angle_speed = 72   -- Per second
    self.radius = 64

    self.damage_coeff = 0.75
    self.fire_range = 250
    self.charge = 0
end)

Object.add_callback(obj, "Step", function(self)
    -- Orbit around parent
    self.angle = self.angle + self.angle_speed /60.0
    self.x = self.parent.x + (gm.dcos(self.angle) * self.radius)
    self.y = self.parent.y - (gm.dsin(self.angle) * self.radius)
end)

Object.add_callback(obj, "Step", function(self)
    -- Set active
    if self.parent.shield > 0 then self.active = true
    else self.active = nil
    end

    if self.active then
        -- Increment charge
        local req = 60.0 / (1.111 * (0.9 + (0.1 * self.parent.maxshield /20.0)))
        if self.charge < req then
            self.charge = self.charge + 1
            self.charged = nil
        else self.charged = true
        end

        -- Get nearest enemy or projectile (prioritized)
        --      Check two types of projectiles every frame
        --      and not all of them to reduce load
        local target = nil
        local target_type = 0

        if self.charged then
            local dist = self.fire_range

            -- Look for enemy projectiles
            local projs = Instance.find_all(Instance.projectiles)
            for _, p in ipairs(projs) do
                local d = gm.point_distance(self.parent.x, self.parent.y, p.x, p.y)
                if d <= dist then
                    dist = d
                    target = p
                end
            end

            -- Look for enemy actors (if no projectile was found)
            if not target then
                local actors = Instance.find_all(gm.constants.pActor)
                for _, a in ipairs(actors) do
                    if a.team and a.team ~= self.parent.team then
                        local d = gm.point_distance(self.parent.x, self.parent.y, a.x, a.y)
                        if d <= dist then
                            dist = d
                            target = a
                            target_type = 1
                        end
                    end
                end
            end
        end

        -- Intercept / Deal damage
        if target then
            self.charge = 0

            local tracer = gm.instance_create_depth(self.x, self.y, -1, gm.constants.oEfLineTracer)
            tracer.xend = target.x
            tracer.yend = target.y
            tracer.bm = 1
            tracer.rate = 0.15
            tracer.sprite_index = 3682.0
            tracer.image_blend = 4434400

            local sparks = gm.instance_create_depth(target.x, target.y, -1, gm.constants.oEfSparks)
            sparks.sprite_index = 1632.0

            if target_type == 0 then gm.instance_destroy(target)
            else Actor.damage(target, self.parent, self.parent.damage * self.damage_coeff, target.x, target.y - 36, 4434400)
            end
        end

    else self.charge = 0
    end
end)

Object.add_callback(obj, "Draw", function(self)
    -- Draw self
    local blend = 16777215
    local alpha = 1.0
    if not self.active then
        blend = 12632256
        alpha = 0.6
    end
    gm.draw_sprite_ext(self.sprite_index, 0, self.x, self.y, self.image_xscale, self.image_yscale, self.image_angle, blend, alpha)
end)