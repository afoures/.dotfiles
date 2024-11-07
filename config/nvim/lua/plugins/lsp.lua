return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true, opts = {
        ui = {
          border = 'rounded',
        },
      } }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- { 'j-hui/fidget.nvim', opts = {} },

      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('gT', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>sds', require('telescope.builtin').lsp_document_symbols, '[S]earch [D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>sws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[S]earch [W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>cr', vim.lsp.buf.rename, '[R]ename')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        ts_ls = { enabled = false },

        vtsls = {
          filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
          },
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = 'always' },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = true },
              },
            },
          },
        },

        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      require('mason-tool-installer').setup {
        ensure_installed = {
          'stylua', -- Used to format Lua code
          'eslint_d',
          'prettierd',
        },
      }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            if server_name == 'tsserver' then
              server_name = 'ts_ls'
            end
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
        ensure_installed = {
          'lua_ls',
          -- todo: switch this to ts_ls when supported
          'tsserver',
          'vtsls',
        },
      }

      local signs = { Error = '󰅚 ', Warn = '󰀪 ', Hint = '󰌶 ', Info = ' ' }
      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end,
  },
  -- {
  --   'neovim/nvim-lspconfig',
  --   -- lazy = false,
  --   -- priority = 1000,
  --   -- cmd = 'LspInfo',
  --   -- event = {'BufReadPre', 'BufNewFile'},
  --   dependencies = {
  --     -- LSP Support
  --     { 'hrsh7th/cmp-nvim-lsp' },
  --     { 'williamboman/mason-lspconfig.nvim' },
  --     {
  --       'williamboman/mason.nvim',
  --       build = ':MasonUpdate',
  --       opts = {
  --         ui = {
  --           border = 'rounded',
  --         },
  --       },
  --     },
  --   },
  --   config = function()
  --     require('mason').setup()
  --
  --     require('mason-lspconfig').setup {
  --       ensure_installed = {
  --         'tsserver',
  --         'lua_ls',
  --       },
  --     }
  --
  --     local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
  --     local lsp_attach = function(client, bufnr)
  --       local opts = { buffer = bufnr, remap = false }
  --
  --       vim.keymap.set('n', 'gd', function()
  --         vim.lsp.buf.definition()
  --       end, opts)
  --       vim.keymap.set('n', 'gh', function()
  --         vim.lsp.buf.hover()
  --       end, opts)
  --       -- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  --       -- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  --       -- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  --       -- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  --       -- vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  --       vim.keymap.set('n', 'gr', function()
  --         vim.lsp.buf.references()
  --       end, opts)
  --       vim.keymap.set('n', '<leader>r', function()
  --         vim.lsp.buf.rename()
  --       end, opts)
  --       -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  --     end
  --
  --     local lspconfig = require 'lspconfig'
  --     require('mason-lspconfig').setup_handlers {
  --       function(server_name)
  --         local settings
  --         if server_name == 'lua_ls' then
  --           settings = {
  --             Lua = {
  --               diagnostics = {
  --                 globals = { 'vim' },
  --               },
  --             },
  --           }
  --         end
  --
  --         lspconfig[server_name].setup {
  --           on_attach = lsp_attach,
  --           capabilities = lsp_capabilities,
  --           settings = settings,
  --         }
  --       end,
  --     }
  --
  --     vim.diagnostic.config {
  --       virtual_text = true,
  --     }
  --   end,
  -- },
  --    {
  --      'VonHeikemen/lsp-zero.nvim',
  --      lazy = false,
  --      priority = 1000,
  --      branch = 'v1.x',
  --      dependencies = {
  --        -- LSP Support
  --        {'neovim/nvim-lspconfig'},
  --        {'williamboman/mason.nvim'},
  --        {'williamboman/mason-lspconfig.nvim'},
  --
  --        -- Autocompletion
  --        {'hrsh7th/nvim-cmp'},
  --        {'hrsh7th/cmp-buffer'},
  --        {'hrsh7th/cmp-path'},
  --        {'saadparwaiz1/cmp_luasnip'},
  --        {'hrsh7th/cmp-nvim-lsp'},
  --        {'hrsh7th/cmp-nvim-lua'},
  --
  --        -- Snippets
  --        -- {'L3MON4D3/LuaSnip'},
  --        -- {'rafamadriz/friendly-snippets'},
  --      },
  --      config = function()
  --        local lsp = require("lsp-zero")
  --
  --        lsp.preset("recommended")
  --
  --        lsp.ensure_installed({
  --          'tsserver',
  --          'lua_ls'
  --        })
  --
  --        -- Fix Undefined global 'vim'
  --        lsp.configure('lua_ls', {
  --          settings = {
  --            Lua = {
  --              diagnostics = {
  --                globals = { 'vim' }
  --              }
  --            }
  --          }
  --        })
  --
  --
  --        local cmp = require('cmp')
  --        local cmp_select = {behavior = cmp.SelectBehavior.Select}
  --        -- local cmp_mappings = lsp.defaults.cmp_mappings({
  --        --   ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  --        --   ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  --        --   ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  --        --   ["<C-Space>"] = cmp.mapping.complete(),
  --        -- })
  --
  --        -- cmp_mappings['<Tab>'] = nil
  --        -- cmp_mappings['<S-Tab>'] = nil
  --
  --        lsp.setup_nvim_cmp({
  --          --  mapping = cmp_mappings
  --        })
  --
  --        lsp.set_preferences({
  --          suggest_lsp_servers = false,
  --          sign_icons = {
  --            error = 'E',
  --            warn = 'W',
  --            hint = 'H',
  --            info = 'I'
  --          }
  --        })
  --
  --        lsp.on_attach(function(client, bufnr)
  --          local opts = {buffer = bufnr, remap = false}
  --
  --          vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  --          vim.keymap.set("n", "gh", function() vim.lsp.buf.hover() end, opts)
  --          -- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  --          -- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  --          -- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  --          -- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  --          -- vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  --          vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
  --          vim.keymap.set("n", "<leader>r", function() vim.lsp.buf.rename() end, opts)
  --          -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  --        end)
  --
  --        lsp.setup()
  --
  --        vim.diagnostic.config({
  --          virtual_text = true
  --        })
  --
  --      end
  --    },
}
