return {
    -- tokyonight
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            style = "moon",
            transparent = true,
            styles = {
                sidebars = "transparent",
                floats = "transparent",
            },
        },
        init = function()
            -- vim.cmd 'colorscheme tokyonight'
        end,
    },
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        priority = 1000,
        opts = {
            flavour = 'mocha',
            transparent_background = true,
        },
        init = function()
            vim.cmd 'colorscheme catppuccin'
        end,
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            dashboard = {
                enabled = true,
                sections = {
                    { section = "header" },
                    { section = "keys", gap = 1, padding = 1 },
                    { section = "startup" },
                },
            },
            input = {
                enabled = true,
            },
        },
    },
}
