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
        vanity = true,
        config = {},
        disable_base_shader = true,
        disable_shadow = true,
        loc_vars = function(self, info_queue)
            return {}
        end,
        on_apply = function(card)
            card.pinned = true
            -- card:set_edition({
			-- 	negative = true,
			-- })
            -- G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        end,
        on_remove = function(card)
            -- G.jokers.config.card_limit = G.jokers.config.card_limit - 1
        end
    }
}


local holofoil = {
    shader = {
        object_type = "Shader",
        key = "holofoil",
        path = "holofoil.fs",
    },
    obj = {
        object_type = "Edition",
        in_shop = false,
        key = "holofoil",
        weight = 0,
        shader = 'holofoil',
        extra_cost = 0,
        vanity = true,
        config = {},
        disable_base_shader = true,
        disable_shadow = true,
        loc_vars = function(self, info_queue)
            return {}
        end,
        on_apply = function(card)
            -- card.pinned = true
            -- card:set_edition({
			-- 	negative = true,
			-- })
            -- G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        end,
        on_remove = function(card)
            -- G.jokers.config.card_limit = G.jokers.config.card_limit - 1
        end
    }
}

local foilholo = {
    shader = {
        object_type = "Shader",
        key = "foilholo",
        path = "foilholo.fs",
    },
    obj = {
        object_type = "Edition",
        in_shop = false,
        key = "foilholo",
        weight = 0,
        shader = 'foilholo',
        extra_cost = 0,
        vanity = true,
        config = {},
        disable_base_shader = true,
        disable_shadow = true,
        loc_vars = function(self, info_queue)
            return {}
        end,
        on_apply = function(card)
            -- card.pinned = true
            -- card:set_edition({
			-- 	negative = true,
			-- })
            -- G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        end,
        on_remove = function(card)
            -- G.jokers.config.card_limit = G.jokers.config.card_limit - 1
        end
    }
}


return {
    name = "增强类型",
    items = {
        roritem,
        holofoil,
        foilholo
    },
    init = function()
        local ccs = Card.can_sell_card
        function Card:can_sell_card(dt)
            ccs(self, dt)
            if self.ability.roritem then
                return false
            end
        end

        -- copy from cryptid 创建虚空的badge
        local smcmb = SMODS.create_mod_badges
        function SMODS.create_mod_badges(obj, badges)
            smcmb(obj, badges)
            if obj and obj.vanity then
                local function calc_scale_fac(text)
                    local size = 0.9
                    local font = G.LANG.font
                    local max_text_width = 2 - 2 * 0.05 - 4 * 0.03 * size - 2 * 0.03
                    local calced_text_width = 0
                    -- Math reproduced from DynaText:update_text
                    for _, c in utf8.chars(text) do
                        local tx = font.FONT:getWidth(c) * (0.33 * size) * G.TILESCALE * font.FONTSCALE
                            + 2.7 * 1 * G.TILESCALE * font.FONTSCALE
                        calced_text_width = calced_text_width + tx / (G.TILESIZE * G.TILESCALE)
                    end
                    local scale_fac = calced_text_width > max_text_width and max_text_width / calced_text_width or 1
                    return scale_fac
                end
                local credits_text = { localize("ror_vanity") ,"哈哈哈哈哈"}
                local scale_fac = {}

                for i = 1, #credits_text do
                    scale_fac[i] = calc_scale_fac(credits_text[i])
                end

                local ct = {}
                for i = 1, #credits_text do
                    ct[i] = {
                        string = credits_text[i],
                        scale = scale_fac[i],
                        spacing = scale_fac[i],
                    }
                end
                badges[#badges + 1] = {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = {
                                align = "cm",
                                colour = HEX("8b008b"),
                                r = 0.1,
                                minw = 2,
                                minh = 0.36,
                                emboss = 0.05,
                                padding = 0.03 * 0.9,
                            },
                            nodes = {
                                { n = G.UIT.B, config = { h = 0.1, w = 0.03 } },
                                {
                                    n = G.UIT.O,
                                    config = {
                                        object = DynaText({
                                            string = ct or "ERROR",
                                            colours = { G.C.WHITE },
                                            silent = true,
                                            float = true,
                                            shadow = true,
                                            offset_y = -0.03,
                                            spacing = 1,
                                            scale = 0.33 * 0.9,
                                        }),
                                    },
                                },
                                { n = G.UIT.B, config = { h = 0.1, w = 0.03 } },
                            },
                        },
                    },
                }
            end
        end
    end
}
