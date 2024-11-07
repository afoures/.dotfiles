return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- ensure other tools can install linters
      lint.linters_by_ft = lint.linters_by_ft or {}

      -- reset default linters
      lint.linters_by_ft['clojure'] = nil
      lint.linters_by_ft['dockerfile'] = nil
      lint.linters_by_ft['inko'] = nil
      lint.linters_by_ft['janet'] = nil
      lint.linters_by_ft['json'] = nil
      lint.linters_by_ft['rst'] = nil
      lint.linters_by_ft['ruby'] = nil
      lint.linters_by_ft['terraform'] = nil
      lint.linters_by_ft['text'] = nil

      lint.linters_by_ft['markdown'] = { 'markdownlint' }

      lint.linters_by_ft['javascript'] = { 'eslint_d' }
      lint.linters_by_ft['javascriptreact'] = { 'eslint_d' }
      lint.linters_by_ft['typescript'] = { 'eslint_d' }
      lint.linters_by_ft['typescriptreact'] = { 'eslint_d' }

      -- setup autocmd to perform the actual linting
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
