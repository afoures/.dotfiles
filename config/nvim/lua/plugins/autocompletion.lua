return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- snippet engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        mapping = cmp.mapping.preset.insert {
          -- select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- accept ([y]es) the completion.
          --  this will auto-import if your LSP supports it.
          --  this will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- if you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- manually trigger a completion from nvim-cmp.
          --  generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- think of <c-l> as moving to the right of your snippet expansion.
          --  so if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- for more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },
  -- {
  --   'hrsh7th/nvim-cmp',
  --   -- event = 'InsertEnter',
  --   dependencies = {},
  --   config = function()
  --     local cmp = require 'cmp'
  --
  --     cmp.setup {
  --       snippet = {},
  --       window = {
  --         completion = cmp.config.window.bordered(),
  --         documentation = cmp.config.window.bordered(),
  --       },
  --       mapping = {
  --         ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
  --         ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
  --         -- C-b (back) C-f (forward) for snippet placeholder navigation.
  --         ['<C-Space>'] = cmp.mapping.complete(),
  --         ['<CR>'] = cmp.mapping.confirm {
  --           behavior = cmp.ConfirmBehavior.Replace,
  --           select = true,
  --         },
  --         ['<Tab>'] = cmp.mapping(function(fallback)
  --           if cmp.visible() then
  --             cmp.select_next_item()
  --           else
  --             fallback()
  --           end
  --         end, { 'i', 's' }),
  --         ['<S-Tab>'] = cmp.mapping(function(fallback)
  --           if cmp.visible() then
  --             cmp.select_prev_item()
  --           else
  --             fallback()
  --           end
  --         end, { 'i', 's' }),
  --       },
  --       sources = {
  --         { name = 'nvim_lsp' },
  --       },
  --     }
  --   end,
  -- },
}
