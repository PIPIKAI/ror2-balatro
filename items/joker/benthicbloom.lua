local code_atlas = {
    object_type = "Atlas",
    key = "benthicbloom",
    path = "j_benthicbloom.png",
    px = 71,
    py = 95,
}
return {
    object_type = "Joker",
    name = "Benthic Bloom",
    key = "benthicbloom",
    config = { extra = { replication = 1 } },
    pos = { x = 0, y = 0 },
    rarity = 'cry_exotic',
    cost = 50,
    blueprint_compat = true,
    eternal_compat = false,
    atlas = "benthicbloom",
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.replication } }
    end,
    calculate = function(self, card, context)
        if
            context.end_of_round
            and context.blind.boss
            and not context.individual
            and not context.repetition
            and not context.retrigger_joker
        then
            local deletable_jokers = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= self and G.jokers.cards[i].config.center.rarity ~= 'cry_exotic'
                    and not G.jokers.cards[i].ability.eternal
                    and not G.jokers.cards[i].getting_sliced then
                    deletable_jokers[#deletable_jokers + 1] = G.jokers.cards[i]
                end
            end
            local chosen_joker = #deletable_jokers > 0 and
            pseudorandom_element(deletable_jokers, pseudoseed('ror_benthicbloom')) or nil
            if chosen_joker and not self.getting_sliced and not chosen_joker.ability.eternal and not chosen_joker.getting_sliced then
                local sliced_card = chosen_joker
                sliced_card.getting_sliced = true
                G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.GAME.joker_buffer = 0
                        self:juice_up(0.8, 0.8)
                        sliced_card:start_dissolve({ HEX("ff00ff") }, nil, 1.6)
                        play_sound('slice1', 0.96 + math.random() * 0.08)
                        return true
                    end
                }))

                local rarity = chosen_joker.config.center.rarity 
                if rarity == "cry_epic" or rarity == 4 then
                    rarity = "cry_exotic"
                else
                    rarity = rarity + 1
                end
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        play_sound('timpani')
                        local card = create_card('Joker', G.jokers, rarity > 3, rarity, nil, nil, nil, 'ror_benthicbloom')
                        -- card:set_edition({ cry_m = true })
                        card:add_to_deck()
                        G.jokers:emplace(card)

                        return true
                    end
                }))
            end
        end
    end,
}
