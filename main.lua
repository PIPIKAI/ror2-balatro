--- STEAMODDED HEADER
--- MOD_NAME: RoR
--- MOD_ID: RoR
--- PREFIX: ror
--- MOD_AUTHOR: [pipikai]
--- MOD_DESCRIPTION: ror2 with balatro !
--- BADGE_COLOR: 814BA8
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0909a]
--- VERSION: 1.0.1e

local RoR = {}
local current_mod = SMODS.current_mod
local mod_path = SMODS.current_mod.path
ror_config = SMODS.current_mod.config

RoR.obj_buffer = {}

if ror_config["Enable"] == nil then
    ror_config["Enable"] = true
end


local function Log(tag , msg)
    print("[RORAMAGE]".." | "..tag.. "| "..msg)
end


local function load_obj_from_dir(dir)
    for _, files in ipairs(NFS.getDirectoryItems(mod_path ..dir)) do
        if files:sub(-4) == ".lua" then
            local file_path = dir .. '/' .. files
            Log("INFO","Loading file: " .. file_path)
            local item, err = SMODS.load_file(file_path)()
            if err then
                print("Error loading file: " .. err)
            end
            if  SMODS[item.object_type] then
                if not RoR.obj_buffer[item.object_type] then
                    RoR.obj_buffer[item.object_type] = {}
                end
                RoR.obj_buffer[item.object_type][#RoR.obj_buffer[item.object_type] + 1] = item
            else
                Log("ERROR","Error loading item " .. item.key .. " of unknown type " .. item.object_type)
            end
        else
            load_obj_from_dir(dir..'/'..files)
        end
    end
end
load_obj_from_dir("items")

for _, objects in pairs(RoR.obj_buffer) do
    for _, object in ipairs(objects) do
        SMODS[object.object_type](object)
        Log("info","load "..object.object_type..": "..object.key)
    end
end
if Cryptid then
SMODS.load_mod_config(SMODS.Mods.Cryptid)
end