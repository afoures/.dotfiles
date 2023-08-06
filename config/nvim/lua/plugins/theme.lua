return {
  {
    "folke/tokyonight.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function ()
      require("tokyonight").setup({
        style = "moon",
        transparent = true,
      });
      -- vim.cmd("colorscheme tokyonight");
    end
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config= function()
      require("catppuccin").setup({
        flavour = 'frappe',
        transparent_background =  true,
      });
      vim.cmd("colorscheme catppuccin");
    end
  },
  {
    'olivercederborg/poimandres.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('poimandres').setup({
        disable_background = true
      })
      -- vim.cmd("colorscheme poimandres");
    end
  },
}
