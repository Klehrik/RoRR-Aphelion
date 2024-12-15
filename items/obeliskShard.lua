-- Obelisk Shard

local sprite = Resources.sprite_load("aphelion", "item/obeliskShard", PATH.."assets/sprites/items/obeliskShard.png", 1, 16, 16)

local item = Item.new("aphelion", "obeliskShard")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_utility)

item:onPostStep(function(actor, stack)
    if actor.RMT_object ~= "Player" then return end
    if actor.still_timer >= 2 *60.0 then
        -- Reduce equipment cooldown
        if actor:get_equipment_cooldown() > 0 then
            actor:reduce_equipment_cooldown(0.1 + (stack * 0.3))
        end
    end
end)



-- Particle

local loops = {}    -- Sound loops do not automatically stop when exiting a run (but do pause when pausing)

local sprite = Resources.sprite_load("aphelion", "pray", PATH.."assets/sprites/effects/pray.png", 1, 16, 4)
local sound = Resources.sfx_load("aphelion", "pray", PATH.."assets/sounds/pray.ogg")

local part = Particle.new("aphelion", "pray")
local part2 = Particle.new("aphelion", "pray2")
for _, p in ipairs({part, part2}) do
    p:set_sprite(sprite, false, false, false)
    p:set_direction(80, 100, 0, 0)
    p:set_speed(0.08, 0.15, 1/60, 0)
    p:set_color_mix(Color.WHITE, Color(0x38d5ff))
    p:set_size(0.85, 1.1, -0.2/55, 0)
    p:set_alpha3(1, 0.8, 0)
    p:set_life(50, 60)
end
part:set_orientation(25, 45, 0.8, 0.4, false)
part2:set_orientation(-25, -45, -0.8, 0.4, false)

item:onPostDraw(function(actor, stack)
    if actor.RMT_object ~= "Player" then return end
    if gm.variable_global_get("pause") then return end
    
    if actor.still_timer >= 2 *60.0 then
        local actorData = actor:get_data("pray")
        if not actorData.part then actorData.part = 0 end
        if not actorData.part2 then actorData.part2 = 18 end

        if actorData.part > 0 then actorData.part = actorData.part - 1
        else
            actorData.part = gm.irandom_range(16, 20)
            part:create(actor.x + gm.random_range(-4, 8), actor.y + 6, 1, Particle.SYSTEM.above)
        end
        if actorData.part2 > 0 then actorData.part2 = actorData.part2 - 1
        else
            actorData.part2 = gm.irandom_range(16, 20)
            part2:create(actor.x + gm.random_range(-8, 4), actor.y + 6, 1, Particle.SYSTEM.middle)
        end

        if not loops[actor.id] then
            loops[actor.id] = gm.sound_loop(sound, 0.9)   -- arg2 is volume
        end

    else
        if loops[actor.id] then
            gm._mod_sound_stop(loops[actor.id])
            loops[actor.id] = nil
        end
    end
end)

gm.post_script_hook(gm.constants.run_destroy, function(self, other, result, args)
    for _, sfx in pairs(loops) do
        gm._mod_sound_stop(sfx)
    end
    loops = {}
end)
