vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://github.com/echasnovski/mini.icons",
	"https://github.com/echasnovski/mini.statusline",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/rachartier/tiny-cmdline.nvim",
})

-- floating cmdline, requires the native ui2
require("vim._core.ui2").enable({})
require("tiny-cmdline").setup({
	position = { y = "20%" },
	native_types = {},
	on_reposition = require("tiny-cmdline").adapters.blink,
})

require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	float = { transparent = true },
	integrations = {
		blink_cmp = true,
		dap = true,
		mason = true,
		mini = { enabled = true },
		snacks = { enabled = true },
		which_key = true,
	},
	-- keep the statusline transparent, only the mode block is filled
	custom_highlights = function(c)
		return {
			MiniStatuslineDevinfo = { fg = c.subtext1, bg = c.none },
			MiniStatuslineFileinfo = { fg = c.subtext1, bg = c.none },
			MiniStatuslineFilename = { fg = c.text, bg = c.none },
			MiniStatuslineInactive = { fg = c.overlay1, bg = c.none },
			MiniStatuslineLocation = { fg = c.overlay1, bg = c.none },
		}
	end,
})
vim.cmd.colorscheme("catppuccin")

require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("which-key").setup({
	preset = "helix",
	delay = 300,
	spec = {
		{ "<leader>c", group = "[C]ode", mode = { "n", "x" } },
		{ "<leader>d", group = "[D]ebug", mode = { "n", "x" } },
		{ "<leader>g", group = "[G]it" },
		{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
		{ "<leader>p", group = "[P]lugins" },
		{ "<leader>s", group = "[S]earch", mode = { "n", "x" } },
		{ "<leader>t", group = "[T]oggle" },
		{ "[", group = "Prev" },
		{ "]", group = "Next" },
		{ "g", group = "Goto" },
	},
})

vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer keymaps (which-key)" })

local statusline = require("mini.statusline")

-- reuse the diagnostic sign icons
local function diagnostic_signs()
	local text = vim.tbl_get(vim.diagnostic.config() or {}, "signs", "text") or {}
	local signs = {}
	for name, severity in pairs({ ERROR = 1, WARN = 2, INFO = 3, HINT = 4 }) do
		signs[name] = text[severity]
	end
	return signs
end

-- always show the path relative to cwd
local function filename()
	if vim.bo.buftype == "terminal" then
		return "%t"
	end
	local name = vim.api.nvim_buf_get_name(0)
	local path = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":~:."):gsub("%%", "%%%%")
	return path .. "%m%r"
end

-- filetype, encoding and format, without the file size
local function fileinfo()
	local filetype = vim.bo.filetype
	if filetype ~= "" then
		filetype = MiniIcons.get("filetype", filetype) .. " " .. filetype
	end
	if statusline.is_truncated(120) or vim.bo.buftype ~= "" then
		return filetype
	end
	local encoding = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
	return string.format("%s%s%s[%s]", filetype, filetype == "" and "" or " ", encoding, vim.bo.fileformat)
end

statusline.setup({
	content = {
		active = function()
			local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
			mode = mode:upper()
			local git = statusline.section_git({ trunc_width = 40 })
			local diff = statusline.section_diff({ trunc_width = 75 })
			local diagnostics =
				statusline.section_diagnostics({ trunc_width = 75, icon = "", signs = diagnostic_signs() })
			-- line,column
			local location = "%l,%v"
			local search = statusline.section_searchcount({ trunc_width = 75 })

			return statusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineDevinfo", strings = { diagnostics } },
				"%<",
				{ hl = "MiniStatuslineFilename", strings = { filename() } },
				{ hl = "MiniStatuslineLocation", strings = { location } },
				{ hl = "MiniStatuslineFileinfo", strings = { search } },
				"%=",
				{ hl = "MiniStatuslineFileinfo", strings = { fileinfo() } },
				{ hl = "MiniStatuslineDevinfo", strings = { diff, git } },
			})
		end,
		inactive = function()
			return "%#MiniStatuslineInactive#" .. filename() .. "%="
		end,
	},
})
