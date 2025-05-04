-- -- dealing with line wraps
-- vim.keymap.set('n', 'k', 'gk', { silent = true })
-- vim.keymap.set('n', 'j', 'gj', { silent = true })

-- -- better indenting
-- vim.keymap.set('v', '<', '<gv')
-- vim.keymap.set('v', '>', '>gv')

-- vim.keymap.set('x', '<leader>p', '"_dP', { desc = '[P]aste without overriding default register' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>y', '"*y', { desc = '[Y]ank to clipboard' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = '[D]elete without overriding default register' })

-- vim.keymap.set('n', 'n', 'nzzzv')
-- vim.keymap.set('n', 'N', 'Nzzzv')

-- -- move selected line / block of text in visual mode
-- vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
-- vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- -- diagnostic keymaps
-- -- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- -- tip: disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- -- keybinds to make split navigation easier.
-- -- use CTRL+<hjkl> to switch between windows
-- vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
