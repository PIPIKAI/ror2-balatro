ROR = {}
ROR = SMODS.current_mod
ROR.config = SMODS.load_file("config.lua")()
local mod_path = SMODS.current_mod.path

ROR.obj_buffer = {}
ROR = SMODS.current_mod
ROR.prefix = "ror"
ROR.badge_colour = HEX("9db95f")


function Log(tag, msg)
    if ROR.config.debug then
        print("[ROR-LOG]" .. " | " .. tag .. "| " .. msg)
    end
end

Log("debug", inspect(ROR))

local item_order = 0

local function perase_lua_file(dir, files)
    local file_path = dir .. '/' .. files
    Log("INFO", "Loading file: " .. file_path)
    local f, err = SMODS.load_file(file_path)
    if err then
        print("Error loading file: " .. err)
    end
    local current_object = f()
    Log("INFO", "table: " .. inspect(current_object))

    if not current_object then
        return
    end
    if not current_object.name then
        Log("Warning", ": " .. file_path .. " has no name")
    end

    if current_object.init then
        current_object:init()
    end

    if not current_object.items then
        return
    end
    for _, item in ipairs(current_object.items) do
        for key, value in pairs(item) do
            -- todo config
            -- if config[key] == "enable" then

            -- end
            if value.object_type and SMODS[value.object_type] then
                if not value.order then
                    value.order = item_order
                end
                item_order = value.order + 1

                if not ROR.obj_buffer[value.object_type] then
                    ROR.obj_buffer[value.object_type] = {}
                end
                ROR.obj_buffer[value.object_type][#ROR.obj_buffer[value.object_type] + 1] = value
            else
                print("Error loading item " .. key .. " of unknown type ")
            end
        end
    end
end

local function load_obj_from_dir(dir)
    for _, files in ipairs(NFS.getDirectoryItems(mod_path .. dir)) do
        if files:sub(-4) == ".lua" and files ~= "init.lua" then
            perase_lua_file(dir, files)
        else
            load_obj_from_dir(dir .. '/' .. files)
        end
    end
end


load_obj_from_dir("data")

Log("info", "obj_buffer:\n" .. inspect(ROR.obj_buffer))
Log("info", "Parese files done!")

local load_order = {
    'Shader',
    'Atlas',
    'Consumable',
    'Joker',
    'Edition',
}
for key, name in ipairs(load_order) do
    local objects = ROR.obj_buffer[load_order[key]]
    Log("info", "inspect " .. name .. ":\n" .. inspect(objects))

    for i = 1, #objects do
        if objects[i].post_process and type(objects[i].post_process) == "function" then
            objects[i]:post_process()
        end
        SMODS[objects[i].object_type](objects[i])
        Log("info", "load " .. objects[i].object_type .. ": " .. objects[i].key)
    end
end
-- todo  free obj_buffer

if Cryptid then
    SMODS.load_mod_config(SMODS.Mods.Cryptid)
end
