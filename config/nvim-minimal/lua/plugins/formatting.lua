vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

-- oxfmt when the project has an oxfmt config, prettier otherwise
local prettier = { "oxfmt", "prettierd", "prettier", stop_after_first = true }

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    json = prettier,
    jsonc = prettier,
    yaml = prettier,
    css = prettier,
    html = prettier,
    markdown = prettier,
    sh = { "shfmt" },
    bash = { "shfmt" },
  },
  formatters = {
    -- only run in projects with an oxfmt or vite config
    oxfmt = { require_cwd = true },
  },
  format_on_save = function(bufnr)
    -- apply linter fixes before formatting
    if #vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" }) > 0 then
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("LspEslintFixAll")
      end)
    end
    -- LspOxlintFixAll is async, so it would race with the formatter
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "oxlint" })) do
      client:request_sync("workspace/executeCommand", {
        command = "oxc.fixAll",
        arguments = { { uri = vim.uri_from_bufnr(bufnr) } },
      }, 1000, bufnr)
    end
    return { timeout_ms = 500, lsp_format = "fallback" }
  end,
  notify_on_error = false,
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set("", "<leader>f", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })
