vim.g.have_nerd_font = true

local opt = vim.opt

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.guicursor = "c-n:hor50-Cursor,i:ver50-Cursor,a:blinkwait700-blinkoff400-blinkon250-Cursor"
opt.showmode = false
opt.winborder = "rounded"
opt.cmdheight = 0

opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

opt.undofile = true
opt.swapfile = false
opt.updatetime = 250

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.completeopt = { "menu", "menuone", "noselect" }

-- ghostty config syntax
local ghostty = "/Applications/Ghostty.app/Contents/Resources/vim/vimfiles"
if vim.uv.fs_stat(ghostty) then
  opt.rtp:append(ghostty)
end
