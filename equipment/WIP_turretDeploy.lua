-- -- Turret Deploy (wip name)

-- local sprite = Resources.sprite_load("aphelion", "equipment/adrenaline", PATH.."assets/sprites/equipment/adrenaline.png", 2, 22, 22)

-- local equip = Equipment.new("aphelion", "turretDeploy")
-- equip:set_sprite(sprite)
-- equip:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_utility)
-- equip:set_cooldown(45)

-- equip:onUse(function(actor)
--     local inst = GM.instance_create(actor.x, actor.y - 8, gm.constants.oEngiTurret)
--     inst.parent = actor
--     inst.level = actor.level
--     inst:recalculate_stats()

--     inst:onPostStep("aphelion-turretDeployDecay", function(self)
--         -- Decay
--         self.hp = self.hp - (self.maxhp * 0.025)/60

--         local selfData = self:get_data()
--         if not selfData.managed_items then
--             selfData.managed_items = true

--             -- Remove existing items
--             local items = self.inventory_item_order
--             local i = #items
--             while i > 0 do
--                 local item = items[i]
--                 self:item_remove(item, self:item_stack_count(item))
--                 i = i - 1
--             end

--             -- Inherit random ones
--             items = Array.new()
--             local par_items = self.parent.inventory_item_order
--             GM.array_copy(items, 0, par_items, 0, #par_items)
--             local copied = 0
--             while (copied < 5) and (#items > 0) do
--                 local pos = gm.irandom_range(1, #items)
--                 local item = items[pos]
--                 self:item_give(item, self.parent:item_stack_count(item))
--                 items:delete(pos)
--                 copied = copied + 1
--             end
--         end
--     end)
-- end)