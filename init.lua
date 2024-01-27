vim.cmd([[
	set background=dark
	set tabstop=2
	set shiftwidth=2
	set softtabstop=2
	set number
	set colorcolumn=80
	set cursorline
	set termguicolors
	set virtualedit=onemore
	set textwidth=80
	set relativenumber
	set clipboard=unnamedplus
	let g:coq_settings = { 'auto_start': v:true }
	set fillchars=vert:\
	set fo+=t
	set updatetime=500

	let g:mapleader = " "

	set noruler
	set noshowcmd
	set laststatus=0
	set cmdheight=0

	" Key mappings
	nnoremap <Leader>n :bnext<CR>
	nnoremap <Leader>p :bprevious<CR>
	nnoremap <Leader>b :set nomore <Bar>
	nnoremap <Leader>cd :cd %:p:h<CR>:pwd<CR>

	" Custom Commands
	command! Sc source ~/.config/nvim/init.lua
	command! Ec edit ~/.config/nvim/init.lua
	command! Ep edit ~/.config/nvim/lua/plugins.lua

	" Theme
	let g:gruvbox_material_foreground = 'material'
	let g:gruvbox_material_background = 'medium'
	let g:gruvbox_material_better_performance = 1
	colorscheme gruvbox-material

	nnoremap ff <cmd>Telescope find_files<cr>
	nnoremap fs <cmd>Telescope live_grep<cr>
	nnoremap fb <cmd>Telescope buffers<cr>
	nnoremap fh <cmd>Telescope help_tags<cr>
	nnoremap fn <cmd>Telescope noice<cr>
	nnoremap <leader>cc <cmd>:!clang -g % -std=c89<cr>
	
	set updatetime=500

	let g:coq_settings = { 'auto_start': 'shut-up' }

]])

-- Move to /pack/ when all set up
require("packer").startup({
	function(use)
		use("wbthomason/packer.nvim")        -- Package manager
		use("nvim-treesitter/nvim-treesitter") -- Syntax Highlighter
		use({
			"nvim-telescope/telescope.nvim",
			tag = "0.1.5",
			requires = { { "nvim-lua/plenary.nvim" } }
		})                             -- Search
		use("neovim/nvim-lspconfig")   -- Needed for everything below
		use("ms-jpq/coq_nvim")         -- Autocomplete
		use("ms-jpq/coq.artifacts")    -- Autocomplete snippets
		use("mfussenegger/nvim-lint")  -- Linter
		use("stevearc/conform.nvim")   -- Formatter
		use("mfussenegger/nvim-dap")   -- Debugger
		use("mxsdev/nvim-dap-vscode-js") -- JavaScript debugger
		use({ "microsoft/vscode-js-debug", opt = true })
		use("windwp/nvim-autopairs")   -- Bracket pairing
		use({
			"rcarriga/nvim-dap-ui",
			requires = { "mfussenegger/nvim-dap" }
		})                                   -- Debugger UI
		use("theHamsta/nvim-dap-virtual-text") -- Debugger inline text
		use("github/copilot.vim")            -- AI completion
		use("gptlang/CopilotChat.nvim")      -- AI completion chat
		use({ "shortcuts/no-neck-pain.nvim", tag = "*" })
		use("ahmedkhalf/project.nvim")       -- Jump between github projects
		use("lukas-reineke/indent-blankline.nvim")
		use("luukvbaal/statuscol.nvim")
		use { 'kevinhwang91/nvim-ufo',
			requires = 'kevinhwang91/promise-async' }
		use { 'sainnhe/gruvbox-material' }
		use({
			"folke/noice.nvim",
			requires = "MunifTanjim/nui.nvim"
		})
		use({
			'nvimdev/lspsaga.nvim',
			requires = "rcarriga/nvim-notify"
		})
	end,
	config = { compile_path = vim.fn.stdpath("config") .. "/init_compiled.lua" },
})

vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc')

vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.g.copilot_filetypes = {
	["*"] = false,
	["css"] = true,
	["html"] = true,
	["lua"] = true,
	["json"] = true,
	["asm"] = true,
}

-- Formatter --

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },

		typescriptreact = { "prettier" },
		json = { "prettier" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		css = { "prettier" },
	},
	format_on_save = { timeout_ms = 500, lsp_fallback = true },
})


require("nvim-autopairs").setup()
local lsp = require("lspconfig")
local coq = require("coq")

lsp.lua_ls.setup(coq.lsp_ensure_capabilities({}))        -- lua
lsp.eslint.setup(coq.lsp_ensure_capabilities({}))        -- JS
lsp.clangd.setup(coq.lsp_ensure_capabilities({}))        -- C
lsp.tsserver.setup(coq.lsp_ensure_capabilities({}))      -- TS
lsp.stylelint_lsp.setup(coq.lsp_ensure_capabilities({})) -- CSS

require("nvim-treesitter.install").update({ with_sync = true })
require("nvim-treesitter.configs").setup({ highlight = { enable = true, additional_vim_regex_highlighting = false } })

-- Linter --
local linter = require("lint")
linter.linters.clangtidy.args = { "-std=c89" }
linter.linters_by_ft = {
	javascript = { "eslint" },
	javascriptreact = { "eslint" },
	typescript = { "eslint" },
	typescriptreact = { "eslint" },
	json = { "eslint" },
	c = { "clangtidy" },
	cpp = { "clangtidy" },
	css = { "stylelint" },
}

------- Debugger ------
local dap = require("dap")
vim.lsp.set_log_level("DEBUG")
dap.adapters.lldb = {
	type = "executable",
	command = "/opt/homebrew/opt/llvm/bin/lldb-vscode",
	name = "lldb",
}
dap.configurations.c = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = vim.fn.getcwd() .. "/a.out",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}

require("dap-vscode-js").setup({
	node_path = "/opt/homebrew/bin/node",
	debugger_path = vim.fn.expand("$HOME/.config/nvim/vscode-js-debug/"),
	adapters = { "pwa-node", "pwa-chrome" },
})

for _, language in ipairs({ "typescript", "javascript" }) do
	dap.configurations[language] = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
			skipFiles = { "<node_internals>/**", "**/node_modules/**" },
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
			skipFiles = { "<node_internals>/**", "**/node_modules/**" },
		},
	}
end

for _, language in ipairs({ "typescriptreact", "javascriptreact" }) do
	dap.configurations[language] = {
		{
			type = "pwa-chrome",
			request = "launch",
			name = "Launch file",
			url = "http://localhost:5173",
			webRoot = vim.fn.getcwd() .. "/src",
			protocol = "inspector",
			sourceMaps = true,
			userDataDir = false,
			skipFiles = { "<node_internals>/**", "**/node_modules/**" },
		},
	}
end
require("nvim-dap-virtual-text").setup()

local dapui = require("dapui")

dapui.setup()

-- Keybindings
vim.api.nvim_set_keymap(
	"n",
	"<Leader>db",
	'<Cmd>lua require"dap".toggle_breakpoint()<CR>',
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<Leader>du", '<Cmd>lua require"dapui".toggle()<CR>', { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "<Leader>dc", '<Cmd>lua require"dap".continue()<CR>', { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "<Leader>ds", '<Cmd>lua require"dap".step_over()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>di", '<Cmd>lua require"dap".step_into()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>do", '<Cmd>lua require"dap".step_out()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dd", '<Cmd>lua require"dap".disconnect()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dr", '<Cmd>lua require"dap".restart()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dt", '<Cmd>lua require"dap".close()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap(
	"n",
	"<Leader>ff",
	'<Cmd>lua require("telescope").extensions.projects.projects({})<CR>',
	{ noremap = true, silent = true }
)

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

require("project_nvim").setup({
	detection_methods = { "pattern" },
	patterns = { ".git" },
})

local nnp = require("no-neck-pain")
nnp.setup({
	options = {
		width = 100,
		minSideBufferWidth = 100,
		autocmds = { enableOnVimEnter = true },
	},
	buffers = {
		right = { enabled = false },
		wo = {
			fillchars = "vert: ,eob: ",
		},
	},
})
nnp.enable()
vim.api.nvim_set_keymap("n", "<Leader>np", "<Cmd>NoNeckPain<CR>", { noremap = true, silent = true })

require('telescope').setup({
	defaults = {
		file_ignore_patterns = { "node_modules" },
	},
})

require("telescope").load_extension("projects")

vim.diagnostic.config({
	underline = false,
	signs = true,
	severity_sort = true, -- Show signs
})

vim.lsp.set_log_level("off")

vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
require("ibl").setup {}

vim.api.nvim_create_autocmd('LspAttach', {
	require('lspsaga').setup({
		lightbulb = { enable = false, },
		symbol_in_winbar = { enable = false, }
	}),
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
	end,
})

local builtin = require("statuscol.builtin")
require("statuscol").setup({
	relculright = true,
	segments = { { text = { "%s" },     click = "v:lua.ScSa" },
		{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa", },
		{ text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
	}
})

require('ufo').setup()

require("ibl").setup({
	indent = {
		char = "▏",
	}
})

require("noice").setup({
	presets = { command_palette = true, }, -- position the cmdline and popupmenu together
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
})

local opts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>Lspsaga hover_doc<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>s', '<cmd>Lspsaga peek_definition<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>d', '<cmd>Lspsaga show_line_diagnostics<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>f', '<cmd>Lspsaga code_action<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>r', '<cmd>Lspsaga rename<CR>', opts)
