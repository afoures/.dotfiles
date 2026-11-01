vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
})

local dap = require("dap")
local dap_view = require("dap-view")

-- js-debug-adapter is installed through mason (see plugins/lsp.lua)
for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
  dap.adapters[adapter] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = { command = "js-debug-adapter", args = { "${port}" } },
  }
end

-- .vscode/launch.json uses "node" / "chrome", which js-debug only knows as "pwa-node" / "pwa-chrome"
for _, adapter in ipairs({ "node", "chrome" }) do
  dap.adapters[adapter] = function(callback, config)
    config.type = "pwa-" .. adapter
    callback(dap.adapters[config.type])
  end
end

-- prompt for a config value when the session starts (vim.ui.input is rendered by snacks.input)
-- cancelling aborts the session
local function ask(prompt, default, parse)
  return function()
    return coroutine.create(function(dap_run_co)
      vim.ui.input({ prompt = prompt, default = default }, function(input)
        local value = input and input ~= "" and (parse or tostring)(input) or nil
        coroutine.resume(dap_run_co, value or dap.ABORT)
      end)
    end)
  end
end

local function ask_port(default)
  return ask("Inspector port: ", tostring(default), tonumber)
end

local js_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

for _, ft in ipairs(js_filetypes) do
  dap.configurations[ft] = {
    -- client code served by a running dev server (vite, next, ...), in a fresh chrome window
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Chrome: dev server",
      url = ask("URL: ", "http://localhost:5173"),
      webRoot = "${workspaceFolder}",
    },
    -- worker running in workerd (cloudflare vite plugin or `wrangler dev`)
    {
      type = "pwa-node",
      request = "attach",
      name = "Workers: attach",
      port = ask_port(9229),
      cwd = "/",
      -- accept the worker's source maps from any path
      resolveSourceMapLocations = vim.NIL,
      attachExistingChildren = false,
      autoAttachChildProcesses = false,
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Node: launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    -- server code of a running process (e.g. vite ssr, plugins, middlewares)
    {
      type = "pwa-node",
      request = "attach",
      name = "Node: attach to process",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
    -- process started with `node --inspect`
    {
      type = "pwa-node",
      request = "attach",
      name = "Node: attach to port",
      port = ask_port(9229),
      cwd = "${workspaceFolder}",
    },
  }
end

-- open the view when a session starts, close it when it ends
dap_view.setup({ auto_toggle = true })

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected" })
vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DapLogPoint" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "Visual" })

local map = function(keys, func, desc, mode)
  vim.keymap.set(mode or "n", keys, func, { desc = desc })
end

map("<leader>db", dap.toggle_breakpoint, "[D]ebug toggle [B]reakpoint")
map("<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Condition: "))
end, "[D]ebug conditional [B]reakpoint")
map("<leader>dl", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
end, "[D]ebug [L]og point")
map("<leader>dc", dap.continue, "[D]ebug [C]ontinue / start")
map("<leader>dC", dap.run_to_cursor, "[D]ebug run to [C]ursor")
map("<leader>dr", dap.run_last, "[D]ebug [R]un last")
map("<leader>di", dap.step_into, "[D]ebug step [I]nto")
map("<leader>do", dap.step_out, "[D]ebug step [O]ut")
map("<leader>dO", dap.step_over, "[D]ebug step [O]ver")
map("<leader>dp", dap.pause, "[D]ebug [P]ause")
map("<leader>dt", dap.terminate, "[D]ebug [T]erminate")
map("<leader>du", dap_view.toggle, "[D]ebug toggle [U]I")
map("<leader>dw", function() dap_view.add_expr() end, "[D]ebug add [W]atch", { "n", "x" })
map("<leader>de", function() require("dap.ui.widgets").hover() end, "[D]ebug [E]val", { "n", "x" })
