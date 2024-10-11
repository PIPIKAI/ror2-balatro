local define = {
    obj = {
        object_type = "ConsumableType",
        key = "Equipment",
        primary_colour = HEX("14b341"),
        secondary_colour = HEX("12f254"),
        shop_rate = 0.0,
        loc_txt = {},
        can_stack = true,
    }
}
local recycle_machine = {
    atalas = {
        object_type = "Atlas",
        key = "atlasrecycle_machine",
        path = "e_recycle_machine.png",
        px = 64,
        py = 64,
    },
    obj = {
        object_type = "Consumable",
        set = "Equipment",
        name = "ror-RecycleMachine",
        key = "recycle_machine",
        pos = { x = 0, y = 0 },
        config = { now_state = 0, cooldown = 3, },
        cost = 4,
        atlas = "atlasrecycle_machine",
        order = 1,
        can_use = function(self, card)
            return #G.jokers.highlighted == 1
                and not G.jokers.highlighted[1].ability.eternal
                and not (
                    type(G.jokers.highlighted[1].config.center.rarity) == "number"
                    and G.jokers.highlighted[1].config.center.rarity >= 5
                )
        end,
        use = function(self, card, area, copier)
            local deleted_joker_key = G.jokers.highlighted[1].config.center.key
            local rarity = G.jokers.highlighted[1].config.center.rarity
            local legendary = nil
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 0.75,
                func = function()
                    G.jokers.highlighted[1]:start_dissolve(nil, _first_dissolve)
                    _first_dissolve = true
                    return true
                end,
            }))
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.4,
                func = function()
                    local card = create_card("Joker", G.jokers, legendary, rarity, nil, nil, nil, "cry_commit")
                    card:add_to_deck()
                    G.jokers:emplace(card)
                    card:juice_up(0.3, 0.5)
                    if card.config.center.key == deleted_joker_key then
                        check_for_unlock({ type = "pr_unlock" })
                    end
                    return true
                end,
            }))
        end
    }
}
return {
    name = "普通装备",
    items = {
        define,
        recycle_machine
    }
}
