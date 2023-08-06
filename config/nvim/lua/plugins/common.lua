return {
  {
    'numToStr/Comment.nvim',
    event = "BufReadPost",
    config = function()
      require("Comment").setup({
        padding = true,
        sticky = true,
        toggler = {
          line = "gcc",
          block = "gbc",
        },
        opleader = {
          line = "gc",
          block = "gb",
        },
        mappings = {
          basic = true,
          extra = true,
          extended = false,
        },
      })
    end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    opts = {
      -- char = '┊',
      show_trailing_blankline_indent = false,
      show_current_context = true,
      -- show_current_context_start = false,
    },
  },
  {
    "windwp/nvim-autopairs",
    opts = {
      fast_wrap = {},
      disable_filetype = { "TelescopePrompt", "vim" },
    },
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)

      -- setup cmp for autopairs
      local cmp_autopairs = require "nvim-autopairs.completion.cmp"
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
}
