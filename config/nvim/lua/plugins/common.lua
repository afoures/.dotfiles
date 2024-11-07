return {
  {
    'lukas-reineke/virt-column.nvim',
    opts = {
      char = { '┆' },
      virtcolumn = '100',
      highlight = { 'NonText' },
    },
  },
  {
    'numToStr/Comment.nvim',
    event = 'BufReadPost',
    opts = {
      padding = true,
      sticky = true,
      toggler = {
        line = 'gcc',
        block = 'gbc',
      },
      opleader = {
        line = 'gc',
        block = 'gb',
      },
      mappings = {
        basic = true,
        extra = true,
        extended = false,
      },
    },
  },
  {
    'windwp/nvim-autopairs',
    opts = {
      fast_wrap = {},
      disable_filetype = { 'TelescopePrompt', 'vim' },
    },
    config = function(_, opts)
      require('nvim-autopairs').setup(opts)

      -- setup cmp for autopairs
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
}
