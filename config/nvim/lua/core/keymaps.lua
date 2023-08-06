-- fast saving
vim.keymap.set("n", "<leader>w", ":write!<CR>", { noremap = true, silent = true })
-- map("n", "<Leader>q", ":q!<CR>", { noremap = true, silent = true })

-- dealing with line wraps
vim.keymap.set("n", "k", "gk", { silent = true })
vim.keymap.set("n", "j", "gj", { silent = true })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("x", "<leader>p", '"_dP')
vim.keymap.set({"n", "v"}, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')
vim.keymap.set({"n", "v"}, "<leader>d", '"_d')

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- move selected line / block of text in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
