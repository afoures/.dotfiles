vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/folke/ts-comments.nvim",
  "https://github.com/echasnovski/mini.pairs",
  "https://github.com/echasnovski/mini.surround",
  "https://github.com/echasnovski/mini.ai",
})

-- lazy load lazydev when opening a lua file
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("minimal_lazydev", { clear = true }),
  pattern = "lua",
  once = true,
  callback = function()
    vim.pack.add({ "https://github.com/folke/lazydev.nvim" })
    require("lazydev").setup({
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    })
  end,
})

require("blink.cmp").setup({
  keymap = { preset = "default" },
  completion = {
    keyword = { range = "full" },
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },
  appearance = { nerd_font_variant = "mono" },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      lua = { inherit_defaults = true, "lazydev" },
    },
    providers = {
      lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
    },
  },
})

require("ts-comments").setup()

require("mini.pairs").setup()

-- sa: add, sd: delete, sr: replace, sf/sF: find, sh: highlight
require("mini.surround").setup()

-- extended a/i textobjects (quotes, brackets, function args, ...)
local ai = require("mini.ai")
ai.setup({
  n_lines = 500,
  custom_textobjects = {
    -- treesitter queries from nvim-treesitter-textobjects
    o = ai.gen_spec.treesitter({
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
    -- function call (mini.ai default for f)
    u = ai.gen_spec.function_call(),
    -- digits
    d = { "%f[%d]%d+" },
    -- whole buffer
    g = function()
      local from = { line = 1, col = 1 }
      local to = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) }
      return { from = from, to = to }
    end,
  },
})
