local roritem = {
    shader = {
        object_type = "Shader",
        key = "roritemfs",
        path = "roritemfs.fs",
    },
    obj = {
        object_type = "Edition",
        in_shop = false,
        key = "roritem",
        weight = 0,
        shader = 'roritemfs',
        extra_cost = 0,
        config = {  },
        disable_base_shader = true,
        disable_shadow = true,
        loc_vars = function(self, info_queue)
            return {  }
        end,
        on_apply = function(card)
            card.pinned = true
            G.jokers.config.card_limit= G.jokers.config.card_limit + 1
        end,
        on_remove = function(card)
            G.jokers.config.card_limit= G.jokers.config.card_limit - 1
        end
    }
}

return {
    name = "增强类型",
    items = {
        roritem
    },
    init = function()
        local ccs = Card.can_sell_card
		function Card:can_sell_card(dt)
            ccs(self, dt)
            if self.ability.roritem then
                return false
            end
        end


    end
}