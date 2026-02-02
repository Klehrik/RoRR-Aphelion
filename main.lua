-- Aphelion

mods["LuaENVY-ENVY"].auto()
mods["ReturnsAPI-ReturnsAPI"].auto{
    namespace = "aphelion",
    mp        = true
}

PATH = _ENV["!plugins_mod_folder_path"]

Initialize.add_hotloadable(function()    
    -- Require all files in content folders
    local folders = {
        "items",
        "equipment"
    }
    for _, folder in ipairs(folders) do
        local names = path.get_files(path.combine(PATH, folder))
        for _, name in ipairs(names) do require(name) end
    end
end)