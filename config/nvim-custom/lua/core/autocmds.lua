local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- tmux setup
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = augroup("auto_reload_tmux"),
  pattern = { "*tmux.conf" },
  command = "execute 'silent !tmux source <afile> --silent'",
})
vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = { "*tmux.conf" },
  callback = function()
    vim.cmd([[set filetype=sh]])
  end,
})

-- reload file if changed outside neovim
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- highlight on yank
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
