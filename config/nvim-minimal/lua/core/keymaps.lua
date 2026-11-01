local map = vim.keymap.set

-- also close the lsp hover / diagnostic float without having to focus it
map("n", "<Esc>", function()
  vim.cmd.nohlsearch()
  local win = vim.b.lsp_floating_preview
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end)

map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })

map("x", "<leader>p", '"_dP', { desc = "[P]aste without overriding register" })

map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic [Q]uickfix list" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line [D]iagnostics" })

map("n", "<leader>pu", function()
  vim.pack.update()
end, { desc = "[P]lugins [U]pdate" })
