-- Phi Construct

local sprite = Resources.sprite_load("aphelion", "phiConstruct", PATH.."assets/sprites/phiConstruct.png", 1, 16, 16)

local item = Item.new("aphelion", "phiConstruct")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_utility)

item:onPickup(function(actor, stack)
    local actorData = actor:get_data("phiConstruct")
    if not actorData.inst then
        local obj = Object.find("aphelion", "phiConstructObject")
        local inst = obj:create(actor.x, actor.y)
        local instData = inst:get_data()
        instData.parent = actor
        actorData.inst = inst
    end
end)

item:onRemove(function(actor, stack)
    local actorData = actor:get_data("phiConstruct")
    if stack <= 1 then
        if actorData.inst:exists() then actorData.inst:destroy() end
        actorData.inst = nil
    end
end)

item:onStatRecalc(function(actor, stack)
    actor.maxshield = actor.maxshield + (20 * stack)
end)



-- Object

local sprite = Resources.sprite_load("aphelion", "phiConstructObject", PATH.."assets/sprites/phiConstructObject.png", 4, 8, 8)

local obj = Object.new("aphelion", "phiConstructObject")
obj:set_sprite(sprite)
obj:set_depth(-1)

obj:onCreate(function(self)
    local selfData = self:get_data()

    self.persistent = true
    self.image_speed = 0.2

    selfData.angle = gm.irandom_range(0, 359)
    selfData.angle_speed = 72   -- Per second
    selfData.radius = 64

    selfData.fire_range = 250
    selfData.charge = 0
end)

obj:onStep(function(self)
    local selfData = self:get_data()

    -- Orbit around parent
    local spd = selfData.angle_speed /60.0
    selfData.angle = selfData.angle + spd
    self.x = selfData.parent.x + (gm.dcos(selfData.angle) * selfData.radius)
    self.y = selfData.parent.y - (gm.dsin(selfData.angle) * selfData.radius)
end)

obj:onStep(function(self)
    local selfData = self:get_data()

    -- Increment charge
    local req = 60.0 / (1.25 * (0.9 + (selfData.parent.maxshield /200.0)))
    if selfData.charge < req then
        selfData.charge = selfData.charge + 1
        selfData.charged = nil
    else selfData.charged = true
    end

    -- Get nearest enemy or projectile (prioritized)
    --      Check two types of projectiles every frame
    --      and not all of them to reduce load
    local target = nil
    local target_type = 0

    if selfData.charged then
        local dist = selfData.fire_range

        -- Look for enemy projectiles
        local projs = Instance.find_all(Instance.projectiles)
        for _, p in ipairs(projs) do
            local d = gm.point_distance(selfData.parent.x, selfData.parent.y, p.x, p.y)
            if d <= dist then
                dist = d
                target = p
            end
        end

        -- Look for enemy actors (if no projectile was found)
        if not target then
            local actors = Instance.find_all(gm.constants.pActor)
            for _, a in ipairs(actors) do
                if a.team and a.team ~= selfData.parent.team then
                    local d = gm.point_distance(selfData.parent.x, selfData.parent.y, a.x, a.y)
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
        selfData.charge = 0

        -- Set sprite direction
        self.image_xscale = 1
        if target.x < self.x then self.image_xscale = -1 end

        -- Create tracer line and sparks
        local blend = Color(0x40E0D0)

        local obj = Object.find("ror-efLineTracer")
        local tracer = obj:create(self.x + (self.image_xscale * 4), self.y)
        tracer.xend = target.x
        tracer.yend = target.y
        tracer.bm = 1
        tracer.rate = 0.11
        tracer.width = 4.0
        tracer.image_blend = blend

        local obj = Object.find("ror-efSparks")
        local sparks = obj:create(target.x, target.y)
        sparks.sprite_index = gm.constants.sSparks1
        sparks.image_blend = blend

        -- Act on target
        if target_type == 0 then target:destroy()
        else
            local damage_coeff = 0.45 + (0.15 * selfData.parent:item_stack_count(item))
            
            local damager = selfData.parent:fire_direct(target, damage_coeff)
            damager:set_color(blend)
            damager:set_critical(false)
            damager:set_proc(false)
        end

    elseif selfData.charged then
        -- Set sprite direction relative to player
        self.image_xscale = 1
        if selfData.parent.y > self.y then self.image_xscale = -1 end

    end
end)