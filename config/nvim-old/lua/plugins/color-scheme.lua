return {
  {
    'folke/tokyonight.nvim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      style = 'moon',
      transparent = true,
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
      flavour = 'frappe',
      transparent_background = true,
    },
    init = function()
      vim.cmd 'colorscheme catppuccin'
    end,
  },
  {
    'olivercederborg/poimandres.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      disable_background = true,
    },
    init = function()
      -- vim.cmd 'colorscheme poimandres'
    end,
  },
}
