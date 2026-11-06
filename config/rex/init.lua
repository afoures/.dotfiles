-- Rex configuration. Reload with `rex config reload`, validate with `rex config check`.
-- Docs: https://www.superlogical.com/rex/docs

local TERMINAL = "com.superlogical.terminal"
local SHELL = "com.superlogical.terminal.shell"

-- Finds the window holding `block_id`, falling back to the active window.
local function current_window(view, block_id)
  for _, win in ipairs(view.windows or {}) do
    for _, layer in ipairs(win.layers or {}) do
      for _, b in ipairs(layer.blocks or {}) do
        if b.block_id == block_id then return win end
      end
    end
  end
  for _, win in ipairs(view.windows or {}) do
    if win.window_id == view.active_window_id then return win end
  end
end

-- Finds the floating layer whose block carries `label`.
local function find_floating(win, label)
  for _, layer in ipairs(win.layers or {}) do
    if layer.kind == "floating" then
      for _, b in ipairs(layer.blocks or {}) do
        if b.label == label then return layer end
      end
    end
  end
end

local function layer_has(layer, block_id)
  for _, b in ipairs(layer.blocks or {}) do
    if b.block_id == block_id then return true end
  end
  return false
end

local function url_decode(s)
  return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

-- Working directory of the program in the focused terminal.
local function cwd_of(block_id)
  if not block_id then return nil end
  local p = rex.block.call(TERMINAL, "process", { block_id = block_id })
  if p and p.foreground and p.foreground.cwd then return p.foreground.cwd end
  local r = rex.block.call(TERMINAL, "pwd", { block_id = block_id })
  if r and r.pwd then return url_decode((r.pwd:gsub("^file://[^/]*", ""))) end
end

local function window_has(win, block_id)
  if not block_id then return false end
  for _, layer in ipairs(win.layers or {}) do
    if layer_has(layer, block_id) then return true end
  end
  return false
end

-- Block focused before each floating layer took focus, keyed by layer_id.
local previous_focus = {}

-- Toggles a floating terminal running `command`, one per tab:
--   none yet        -> open it (in the focused pane's directory) and focus it
--   minimized       -> restore and focus it
--   visible, focused -> minimize it and refocus the pane focused before it
--   visible, behind  -> bring it to the front and focus it
-- Quitting the program closes the floating pane.
local function toggle_floating(ctx, label, command)
  local view, err = rex.session.view{}
  if not view then error(err, 0) end

  local win = current_window(view, ctx.block_id)
  if not win then error("no window to open " .. label .. " in", 0) end

  local layer = find_floating(win, label)
  if layer then
    local focused = layer.state ~= "minimized" and layer_has(layer, win.focused_block_id)
    local _, e
    if focused then
      _, e = rex.session.set_layer_state{ layer_id = layer.layer_id, state = "minimized" }
      if e then error(e, 0) end
      local prev = previous_focus[layer.layer_id]
      if prev and not layer_has(layer, prev) and window_has(win, prev) then
        _, e = rex.session.focus_block{ block_id = prev }
      end
    else
      if not layer_has(layer, win.focused_block_id) then
        previous_focus[layer.layer_id] = win.focused_block_id
      end
      _, e = rex.session.set_layer_state{ layer_id = layer.layer_id, state = "normal", focus = true }
    end
    if e then error(e, 0) end
    return
  end

  local prev = win.focused_block_id

  local res, e = rex.session.new_layer{
    window_id = win.window_id,
    bounds = { 0.05, 0.05, 0.9, 0.9 },
    layout = {
      block = {
        flavor = SHELL,
        label = label,
        options = { command = command, cwd = cwd_of(ctx.block_id) },
      },
    },
    focus = true,
  }
  if e then error(e, 0) end
  if res and res.layer_id then previous_focus[res.layer_id] = prev end
end

rex.action{
  name = "toggle_lazygit",
  title = "Toggle Lazygit",
  description = "Open lazygit in a floating pane, or minimize/restore it",
  keywords = "git lazygit floating popup",
  run = function(ctx) toggle_floating(ctx, "lazygit", { "mise", "exec", "--", "lazygit" }) end,
}

rex.bind("cmd+l", "toggle_lazygit")
