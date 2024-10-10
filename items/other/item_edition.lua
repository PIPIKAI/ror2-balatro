return {
    object_type = "Edition",
    key = "roritem",
    order = 2,
    weight = 1,
    shader = "roritem",
    in_shop = false,
    extra_cost = 6,
    config = {  },
    get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self, info_queue)
        return {  }
    end,
}
