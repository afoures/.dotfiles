vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/b0o/SchemaStore.nvim",
})

-- external tools, installed through mason
local tools = {
  -- lsp
  "lua-language-server",
  "vtsls",
  "eslint-lsp",
  "oxlint",
  "json-lsp",
  "yaml-language-server",
  "bash-language-server",
  "css-lsp",
  "html-lsp",
  "tailwindcss-language-server",
  -- linters / formatters
  "shellcheck",
  "shfmt",
  "stylua",
  "prettierd",
  "oxfmt",
  -- debug adapters
  "js-debug-adapter",
}

-- eslint / oxlint only attach in projects that have their config
local servers = { "lua_ls", "vtsls", "eslint", "oxlint", "jsonls", "yamlls", "bashls", "cssls", "html", "tailwindcss" }

require("mason").setup()

local registry = require("mason-registry")
registry.refresh(function()
  for _, name in ipairs(tools) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and not pkg:is_installed() then
      pkg:install()
    end
  end
end)

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      completion = { callSnippet = "Replace" },
    },
  },
})

-- shared between typescript and javascript files
local ts_settings = {
  updateImportsOnFileMove = { enabled = "always" },
  suggest = { completeFunctionCalls = true },
  inlayHints = {
    enumMemberValues = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    parameterNames = { enabled = "literals" },
    parameterTypes = { enabled = false },
    propertyDeclarationTypes = { enabled = true },
    variableTypes = { enabled = true },
  },
}

vim.lsp.config("vtsls", {
  settings = {
    complete_function_calls = true,
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = { enableServerSideFuzzyMatch = true },
      },
    },
    typescript = ts_settings,
    javascript = ts_settings,
  },
})

-- lspconfig starts oxlint even when no root is found, only attach in oxlint projects
local oxlint_root_dir = vim.lsp.config.oxlint.root_dir
vim.lsp.config("oxlint", {
  root_dir = function(bufnr, on_dir)
    oxlint_root_dir(bufnr, function(dir)
      if dir then
        on_dir(dir)
      end
    end)
  end,
})

vim.lsp.config("jsonls", {
  settings = { json = { validate = { enable = true } } },
  before_init = function(_, config)
    config.settings.json.schemas = require("schemastore").json.schemas()
  end,
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      keyOrdering = false,
      schemaStore = { enable = false, url = "" },
    },
  },
  before_init = function(_, config)
    config.settings.yaml.schemas = require("schemastore").yaml.schemas()
  end,
})

vim.lsp.enable(servers)

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, source = "if_many" },
  float = { source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("minimal_lsp_attach", { clear = true }),
  callback = function(event)
    local buf = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, { buffer = buf, desc = "LSP: " .. desc, nowait = true })
    end

    map("gd", function() Snacks.picker.lsp_definitions() end, "[G]oto [D]efinition")
    map("gD", function() Snacks.picker.lsp_declarations() end, "[G]oto [D]eclaration")
    map("gr", function() Snacks.picker.lsp_references() end, "[G]oto [R]eferences")
    map("gI", function() Snacks.picker.lsp_implementations() end, "[G]oto [I]mplementation")
    map("gT", function() Snacks.picker.lsp_type_definitions() end, "[G]oto [T]ype definition")
    map("<leader>sds", function() Snacks.picker.lsp_symbols() end, "[S]earch [D]ocument [S]ymbols")
    map("<leader>sws", function() Snacks.picker.lsp_workspace_symbols() end, "[S]earch [W]orkspace [S]ymbols")
    map("<leader>cr", vim.lsp.buf.rename, "[R]ename")
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

    if client and client:supports_method("textDocument/inlayHint", buf) then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
      end, "[T]oggle Inlay [H]ints")
    end
  end,
})
