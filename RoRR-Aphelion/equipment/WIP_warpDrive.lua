-- -- 

-- local sprite = Resources.sprite_load("aphelion", "adrenaline", PATH.."assets/sprites/adrenaline.png", 2, 22, 22)

-- local equip = Equipment.new("aphelion", "warpDrive")
-- equip:set_sprite(sprite)
-- equip:set_loot_tags(Item.LOOT_TAG.category_utility)
-- equip:set_cooldown(1)

-- local dist = 150        -- in pixels
-- local max_uses = 3
-- local actual_cd = 20    -- in seconds
-- -- local use_window = 160  -- (in frames) Window to use next warp before forced cooldown

-- equip:onPickup(function(actor)
--     local actorData = actor:get_data("warpDrive")
--     actorData.uses = max_uses
-- end)

-- equip:onUse(function(actor)
--     local actorData = actor:get_data("warpDrive")
--     -- actorData.window = use_window

--     local use_dir = actor:get_equipment_use_direction()
--     local _x = actor.x + (use_dir * dist)
--     local _y = actor.y

--     local col = gm.collision_line(actor.x, actor.y, _x, _y, gm.constants.oB, false, true)
--     if col ~= -4 then
--         _x = col.bbox_left
--         if use_dir < 0 then _x = col.bbox_right end
--     end
    
--     actor.x = _x
--     actor.y = _y
--     actor:set_immune(20)

--     if actorData.uses > 0 then actorData.uses = actorData.uses - 1 end
--     if actorData.uses <= 0 then
--         actorData.uses = max_uses
--         actor:reduce_equipment_cooldown((-actual_cd + 1) *60)
--     end
-- end)

-- -- equip:onStep(function(actor)
-- --     local actorData = actor:get_data("warpDrive")
-- --     if actorData.uses < max_uses then
-- --         if actorData.window > 0 then actorData.window = actorData.window - 1
-- --         else
-- --             actorData.uses = max_uses
-- --             actor:reduce_equipment_cooldown(-actual_cd *60)
-- --         end
-- --     end
-- -- end)