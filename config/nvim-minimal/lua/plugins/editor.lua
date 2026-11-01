vim.pack.add({
  "https://github.com/folke/snacks.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/folke/todo-comments.nvim",
})

require("snacks").setup({
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    width = 40,
    preset = {
      header = table.concat({
        "┏┓╻┏━╸┏━┓╻ ╻╻┏┳┓",
        "┃┗┫┣╸ ┃ ┃┃┏┛┃┃┃┃",
        "╹ ╹┗━╸┗━┛┗┛ ╹╹ ╹",
      }, "\n"),
      keys = {
        { icon = " ", key = "e", desc = "File Explorer", action = function() Snacks.explorer() end },
        { icon = " ", key = "r", desc = "Recent Files", action = function() Snacks.picker.recent() end },
        { icon = " ", key = "f", desc = "Find File", action = function() Snacks.picker.files() end },
        { icon = " ", key = "g", desc = "Find Text", action = function() Snacks.picker.grep() end },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = "header", padding = 1 },
      function()
        return { text = { vim.fn.fnamemodify(vim.fn.getcwd(), ":~"), hl = "Comment" }, align = "center", padding = 2 }
      end,
      { section = "keys" },
    },
  },
  input = { enabled = true },
  statuscolumn = { enabled = true },
  picker = {
    enabled = true,
    layout = { preset = "telescope_top" },
    layouts = {
      -- telescope-like layout with the input at the top
      telescope_top = {
        layout = {
          box = "horizontal",
          backdrop = false,
          width = 0.8,
          height = 0.9,
          border = "none",
          {
            box = "vertical",
            { win = "input", height = 1, border = true, title = "{title} {live} {flags}", title_pos = "center" },
            { win = "list", title = " Results ", title_pos = "center", border = true },
          },
          { win = "preview", title = "{preview:Preview}", width = 0.45, border = true, title_pos = "center" },
        },
      },
    },
    formatters = { file = { filename_first = true } },
    sources = {
      -- only show recent files under the current directory
      recent = { filter = { cwd = true } },
      -- floating explorer that closes after opening a file
      explorer = {
        layout = { preset = "telescope_top", preview = true },
        auto_close = true,
        jump = { close = true },
        -- show dotfiles (e.g. config/zsh only contains dotfiles)
        hidden = true,
      },
    },
  },
  explorer = { enabled = true, replace_netrw = true },
  lazygit = { enabled = true },
  words = { enabled = true },
  scroll = {
    enabled = true,
    -- default is 10ms per step, 200ms total
    animate = { duration = { step = 5, total = 100 } },
  },
  indent = {
    enabled = true,
    -- default is 20ms per step, 500ms total
    animate = { duration = { step = 10, total = 150 } },
  },
})

local map = function(keys, func, desc, mode)
  vim.keymap.set(mode or "n", keys, func, { desc = desc })
end

-- picker
map("<leader><leader>", function() Snacks.picker.buffers() end, "[ ] Find buffers")
map("<leader>/", function() Snacks.picker.lines() end, "[/] Search in buffer")
map("<leader>sf", function() Snacks.picker.files() end, "[S]earch [F]iles")
map("<leader>sg", function() Snacks.picker.grep() end, "[S]earch by [G]rep")
map("<leader>sw", function() Snacks.picker.grep_word() end, "[S]earch current [W]ord", { "n", "x" })
map("<leader>sh", function() Snacks.picker.help() end, "[S]earch [H]elp")
map("<leader>sk", function() Snacks.picker.keymaps() end, "[S]earch [K]eymaps")
map("<leader>sd", function() Snacks.picker.diagnostics() end, "[S]earch [D]iagnostics")
map("<leader>sr", function() Snacks.picker.resume() end, "[S]earch [R]esume")
map("<leader>s.", function() Snacks.picker.recent() end, "[S]earch Recent Files")
map("<leader>ss", function() Snacks.picker.pickers() end, "[S]earch [S]nacks pickers")
map("<leader>sn", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, "[S]earch [N]eovim files")

-- explorer
map("<leader>e", function() Snacks.explorer() end, "File [E]xplorer")

-- rename file, updating imports through the lsp (also used by the explorer)
map("<leader>cR", function() Snacks.rename.rename_file() end, "[R]ename file")

-- lazygit
-- open lazygit above any open float (e.g. the explorer)
local on_top = function()
  return { win = { zindex = Snacks.win.zindex() } }
end
map("<leader>gg", function() Snacks.lazygit(on_top()) end, "Lazy[G]it")
map("<leader>gl", function() Snacks.lazygit.log_file(on_top()) end, "Lazy[G]it [L]og (file)")

-- words (lsp references under cursor)
map("]]", function() Snacks.words.jump(vim.v.count1) end, "Next reference", { "n", "t" })
map("[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev reference", { "n", "t" })

-- todo comments
require("todo-comments").setup()

map("]t", function() require("todo-comments").jump_next() end, "Next [T]odo comment")
map("[t", function() require("todo-comments").jump_prev() end, "Prev [T]odo comment")
map("<leader>st", function() Snacks.picker.todo_comments() end, "[S]earch [T]odo comments")
map("<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, "[S]earch [T]odo/Fix/Fixme")

-- git signs are rendered by snacks statuscolumn
require("gitsigns").setup({
  on_attach = function(buf)
    local gs = require("gitsigns")
    local bmap = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, { buffer = buf, desc = desc })
    end

    bmap("]h", function() gs.nav_hunk("next") end, "Next [H]unk")
    bmap("[h", function() gs.nav_hunk("prev") end, "Prev [H]unk")
    bmap("<leader>hs", gs.stage_hunk, "[H]unk [S]tage")
    bmap("<leader>hr", gs.reset_hunk, "[H]unk [R]eset")
    bmap("<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "[H]unk [S]tage", "v")
    bmap("<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "[H]unk [R]eset", "v")
    bmap("<leader>hS", gs.stage_buffer, "[H]unk [S]tage buffer")
    bmap("<leader>hR", gs.reset_buffer, "[H]unk [R]eset buffer")
    bmap("<leader>hp", gs.preview_hunk_inline, "[H]unk [P]review")
    bmap("<leader>hb", function() gs.blame_line({ full = true }) end, "[H]unk [B]lame line")
    bmap("<leader>hd", gs.diffthis, "[H]unk [D]iff this")
    bmap("ih", gs.select_hunk, "Inner hunk", { "o", "x" })
  end,
})
