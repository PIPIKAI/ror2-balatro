return {
    object_type = "Edition",
    in_shop = false,
    key = "roritem",
    weight = 0,
    shader = "roritem",
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
    end,
    can_sell_card = function(card)
        return false
    end
}
