-- -- Phi Construct

-- local sprite = Resources.sprite_load(PATH.."assets/sprites/phiConstruct.png", 1, false, false, 16, 16)

-- local item = Item.new("aphelion", "phiConstruct")
-- item:set_sprite(sprite)
-- item:set_tier(Item.TIER.uncommon)
-- item:set_loot_tags(Item.LOOT_TAG.category_utility)

-- local increase = 20

-- item:add_callback("onPickup", function(actor, stack)
--     actor.maxshield_base = actor.maxshield_base + increase

--     if not actor.aphelion_phiConstruct_inst then
--         local obj = Object.find("aphelion", "phiConstructObject")
--         local inst = obj:create(actor.x, actor.y)
--         inst.parent = actor
--         actor.aphelion_phiConstruct_inst = inst
--     end
-- end)

-- item:add_callback("onRemove", function(actor, stack)
--     actor.maxshield_base = actor.maxshield_base - increase

--     if stack <= 1 then
--         if Instance.exists(actor.aphelion_phiConstruct_inst) then Instance.destroy(actor.aphelion_phiConstruct_inst) end
--         actor.aphelion_phiConstruct_inst = nil
--     end
-- end)



-- -- Object

-- local sprite = Resources.sprite_load(PATH.."assets/sprites/phiConstructObject.png", 4, false, false, 8, 8)

-- local obj = Object.new("aphelion", "phiConstructObject")
-- obj:set_sprite(sprite)
-- obj:set_depth(-100)

-- obj:add_callback("onCreate", function(self)
--     self.persistent = true
--     self.image_speed = 0.4

--     self.angle = gm.irandom_range(0, 359)
--     self.angle_speed = 72   -- Per second
--     self.radius = 64

--     self.fire_range = 250
--     self.charge = 0
-- end)

-- obj:add_callback("onStep", function(self)
--     -- Orbit around parent
--     local spd = self.angle_speed /60.0
--     self.angle = self.angle + spd
--     self.x = self.parent.x + (gm.dcos(self.angle) * self.radius)
--     self.y = self.parent.y - (gm.dsin(self.angle) * self.radius)
-- end)

-- obj:add_callback("onStep", function(self)
--     -- Increment charge
--     local req = 60.0 / (1.25 * (0.9 + (self.parent.maxshield /200.0)))
--     if self.charge < req then
--         self.charge = self.charge + 1
--         self.charged = nil
--     else self.charged = true
--     end

--     -- Get nearest enemy or projectile (prioritized)
--     --      Check two types of projectiles every frame
--     --      and not all of them to reduce load
--     local target = nil
--     local target_type = 0

--     if self.charged then
--         local dist = self.fire_range

--         -- Look for enemy projectiles
--         local projs = Instance.find_all(Instance.projectiles)
--         for _, p in ipairs(projs) do
--             local d = gm.point_distance(self.parent.x, self.parent.y, p.x, p.y)
--             if d <= dist then
--                 dist = d
--                 target = p
--             end
--         end

--         -- Look for enemy actors (if no projectile was found)
--         if not target then
--             local actors = Instance.find_all(gm.constants.pActor)
--             for _, a in ipairs(actors) do
--                 if a.team and a.team ~= self.parent.team then
--                     local d = gm.point_distance(self.parent.x, self.parent.y, a.x, a.y)
--                     if d <= dist then
--                         dist = d
--                         target = a
--                         target_type = 1
--                     end
--                 end
--             end
--         end
--     end

--     -- Intercept / Deal damage
--     if target then
--         self.charge = 0

--         -- Set sprite direction
--         self.image_xscale = 1
--         if target.x < self.x then self.image_xscale = -1 end

--         -- Create tracer line and sparks
--         local blend = 13688896

--         local obj = Object.find("ror-efLineTracer")
--         local tracer = obj:create(self.x + (self.image_xscale * 4), self.y)
--         tracer.xend = target.x
--         tracer.yend = target.y
--         tracer.bm = 1
--         tracer.rate = 0.11
--         tracer.width = 4.0
--         tracer.image_blend = blend

--         local obj = Object.find("ror-efSparks")
--         local sparks = obj:create(target.x, target.y)
--         sparks.sprite_index = 1632.0
--         sparks.image_blend = blend

--         -- Act on target
--         if target_type == 0 then Instance.destroy(target)
--         else
--             local damage_coeff = 0.45 + (0.15 * self.parent:item_stack_count(item))
--             target:take_damage(self.parent.damage * damage_coeff, self.parent, target.x, target.y - 36, blend)
--         end

--     elseif self.charged then
--         -- Set sprite direction relative to player
--         self.image_xscale = 1
--         if self.parent.y > self.y then self.image_xscale = -1 end

--     end
-- end)