--- STEAMODDED HEADER
--- MOD_NAME: Ror2Relink
--- MOD_ID: Ror2Relink
--- PREFIX: ror
--- MOD_AUTHOR: [pipikai]
--- MOD_DESCRIPTION: ror2 with balatro !
--- BADGE_COLOR: 814BA8
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0909a]
--- VERSION: 1.0.1e

local current_mod = SMODS.current_mod
local mod_path = SMODS.current_mod.path
ror_config = SMODS.current_mod.config

if ror_config["Enable"] == nil then
    ror_config["Enable"] = true
end


local function Log(tag , msg)
    print("[RORAMAGE]".."   "..tag.. "msg:   "..msg)
end

local jokers_floder = "items/jokers"
local jokers = NFS.getDirectoryItems(mod_path .. jokers_floder)

RoR.obj_buff = {}
for _, files in ipairs(jokers) do
    Log("info","jocker: "..files)
    local item, err = SMODS.load_file(jokers_floder .. files .. ".lua")()
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
end

if Cryptid then
SMODS.load_mod_config(SMODS.Mods.Cryptid)
end