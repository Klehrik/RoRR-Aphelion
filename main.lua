-- Aphelion

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then for _, c in ipairs(m.Classes) do if m[c] then _G[c] = m[c] end end end end end)

PATH = _ENV["!plugins_mod_folder_path"].."/"

player_callbacks = {}



-- ========== Main ==========

function __initialize()
    -- Require all files in content folders
    local folders = {
        "items",
        "equipment",
        "skills"
    }
    for _, folder in ipairs(folders) do
        local names = path.get_files(PATH..folder)
        for _, name in ipairs(names) do require(name) end
    end

    -- Add player callbacks on run start
    Callback.add("onGameStart", "aphelion-addPlayerCallbacks", function(self, other, result, args)
        Alarm.create(function()

            --Add player callbacks
            local player = Player.get_client()
            for _, c in ipairs(player_callbacks) do
                player:add_callback(c[1], c[2], c[3], c[4])
            end

        end, 1)
    end, true)

    -- Huntress : Set Stealth Hunting upgrade
    local skill = Skill.find("aphelion-huntressStealth")
    skill.upgrade_skill = Skill.find("aphelion-huntressStealthBoosted")
end