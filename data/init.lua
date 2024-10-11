ROR.config = SMODS.load_file("config.lua")()


ROR = SMODS.current_mod
local mod_path = SMODS.current_mod.path

ROR.obj_buffer = {}
ROR = SMODS.current_mod
ROR.prefix = "ror"
ROR.badge_colour = HEX("9db95f")
if ror_config["Enable"] == nil then
    ror_config["Enable"] = true
end

function Log(tag, msg)
    if ROR.config.debug then
        print("[ROR-LOG]" .. " | " .. tag .. "| " .. msg)
    end
end

Log("debug", inspect(Reverie))


local item_order = 0
for _, dir_name in ipairs(NFS.getDirectoryItems(mod_path .. "data")) do
    local enter_file = dir_name .. '/init.lua'

    Log("INFO", "Loading file: " .. enter_file)
    local enters, err = SMODS.load_file(enter_file)()
    if err then
        print("Error loading file: " .. err)
    end
    for i = 1, #enters do
        local current_object = enters[i]
        Log("debug", "loading " .. current_object.name)
            if current_object.init then
                current_object:init()
            end
            if not current_object.items then
                Log("Warning: " .. current_object.name .. " has no items")
            else

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
                        print("Error loading item " ..  key .. " of unknown type ")
                    end
                end

            end
        end
    end
end

Log("info","obj_buffer:\n".. inspect(ROR.obj_buffer))
Log("info","Parese files done!")
for _, objects in pairs(ROR.obj_buffer) do
    for i = 1, #objects do
        if objects[i].post_process and type(objects[i].post_process) == "function" then
            objects[i]:post_process()
        end
        SMODS[objects.object_type](objects[i])
        Log("info", "load " .. objects[i].object_type .. ": " .. objects[i].key)
    end
end
-- todo  free obj_buffer

if Cryptid then
    SMODS.load_mod_config(SMODS.Mods.Cryptid)
end
