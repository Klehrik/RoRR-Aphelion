-- -- Sniper : Spotter: BLAST

-- local sprite = Resources.sprite_load("aphelion", "skill/sniper", PATH.."assets/sprites/skills/sniper.png", 2)

-- local skill = Skill.new("aphelion", "sniperBlast")
-- skill:set_skill_icon(sprite, 0)
-- skill:set_skill_properties(0.0, 0)
-- skill:set_skill_stock(1, 1, true, 1)
-- skill:set_skill_settings(
--     true, false, 2,
--     false, false,
--     false, false,
--     false
-- )
-- skill.require_key_press = true

-- skill:onActivate(function(actor, skill, index)
--     -- local drone = nil
--     -- local drones = Instance.find_all(Object.find("ror-sniperDrone"))
--     -- for _, d in ipairs(drones) do
--     --     if d.master:same(actor) then
--     --         drone = d
--     --     end
--     -- end

--     -- if not drone then return end

--     local drone = GM._survivor_sniper_find_drone(actor)

--     drone.tt = Instance.find(gm.constants.pActor)

--     actor:set_active_skill(Skill.SLOT.special, Skill.find("ror-sniperVRecall"))
-- end)

-- Survivor.find("ror-sniper"):add_skill(skill, Skill.SLOT.special)