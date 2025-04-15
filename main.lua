-- Aphelion

mods["LuaENVY-ENVY"].auto()
mods["ReturnsAPI-ReturnsAPI"].auto{
    namespace = "aphelion"
}

PATH = _ENV["!plugins_mod_folder_path"].."/"

local fn = function()
    hotloaded = true
    
    -- Require all files in content folders
    local folders = {
        "items"
    }
    for _, folder in ipairs(folders) do
        local names = path.get_files(PATH..folder)
        for _, name in ipairs(names) do require(name) end
    end
end
Initialize.add(fn)
if hotloaded then fn() end