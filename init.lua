local vim = vim

-- Vanilla Neovim settings
vim.cmd([[
	let g:mapleader = " "

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
	set fillchars=vert:\
	set fo+=t
	set updatetime=500
	set noruler
	set noshowcmd
	set laststatus=0
	set cmdheight=0
	set updatetime=500

	" Theme
	let g:gruvbox_material_foreground = 'material'
	let g:gruvbox_material_background = 'medium'
	let g:gruvbox_material_better_performance = 1
	colorscheme gruvbox-material

	" Folding Configuration
	set foldcolumn=1
	set foldlevel=99
	set foldlevelstart=99
	set foldenable
	set fillchars=eob:\ ,fold:\ ,foldopen:,foldsep:\ ,foldclose:

	" Use persistent history.
	if !isdirectory("/tmp/.vim-undo-dir")
    call mkdir("/tmp/.vim-undo-dir", "", 0700)
	endif
	set undodir=/tmp/.vim-undo-dir
	set undofile

	" Key mappings
	nnoremap <Leader>n :bnext<CR>
	nnoremap <Leader>p :bprevious<CR>
	nnoremap <Leader>b :set nomore <Bar>
	nnoremap <Leader>cd :cd %:p:h<CR>:pwd<CR>

	" Diagnostic Configuration
	let g:diagnostic_underline = 0
	let g:diagnostic_signs = 1
	let g:diagnostic_severity_sort = 1

	" Custom Commands
	command! Sc source ~/.config/nvim/init.lua
	command! Ec edit ~/.config/nvim/init.lua
	command! Ep edit ~/.config/nvim/lua/plugins.lua

	autocmd VimEnter * wincmd w


]])

-- Plugin-specific settings
vim.cmd([[

	lua vim.lsp.set_log_level("off")
	
	nnoremap ff <cmd>Telescope find_files<cr>
	nnoremap fs <cmd>Telescope live_grep<cr>
	nnoremap fb <cmd>Telescope buffers<cr>
	nnoremap fh <cmd>Telescope help_tags<cr>
	nnoremap fn <cmd>Telescope noice<cr>
	nnoremap <leader>cc <cmd>:!clang -g % -std=c89<cr>
	

	" Copilot Configuration
	let g:copilot_no_tab_map = 1
	inoremap <C-J> <cmd>copilot#Accept("<CR>")<CR>

	" Copilot Filetypes Configuration
	let g:copilot_filetypes = {}
	let g:copilot_filetypes['*'] = v:false
	let g:copilot_filetypes['css'] = v:true
	let g:copilot_filetypes['html'] = v:true
	let g:copilot_filetypes['lua'] = v:true
	let g:copilot_filetypes['json'] = v:true
	let g:copilot_filetypes['asm'] = v:true

	" Keybindings for DAP (Debug Adapter Protocol)
	nnoremap <Leader>db :lua require'dap'.toggle_breakpoint()<CR>
	nnoremap <Leader>du :lua require'dapui'.toggle()<CR>
	nnoremap <Leader>dc :lua require'dap'.continue()<CR>
	nnoremap <Leader>ds :lua require'dap'.step_over()<CR>
	nnoremap <Leader>di :lua require'dap'.step_into()<CR>
	nnoremap <Leader>do :lua require'dap'.step_out()<CR>
	nnoremap <Leader>dd :lua require'dap'.disconnect()<CR>
	nnoremap <Leader>dr :lua require'dap'.restart()<CR>
	nnoremap <Leader>dt :lua require'dap'.close()<CR>

	" Keybinding for Telescope projects
	nnoremap <Leader>ff :lua require("telescope").extensions.projects.projects({})<CR>

	" LSP Saga Keybindings
	nnoremap <leader>a :Lspsaga hover_doc<CR>
	nnoremap <leader>s :Lspsaga peek_definition<CR>
	nnoremap <leader>d :Lspsaga show_line_diagnostics<CR>
	nnoremap <leader>f :Lspsaga code_action<CR>
	nnoremap <leader>r :Lspsaga rename<CR>

]])

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

		-- Autocomplete
		use('hrsh7th/nvim-cmp')
		use('hrsh7th/cmp-nvim-lsp')
		use('L3MON4D3/LuaSnip')
		use('saadparwaiz1/cmp_luasnip')
		use('rafamadriz/friendly-snippets')
		use('hrsh7th/cmp-buffer')
		use('hrsh7th/cmp-path')

		use('terrortylor/nvim-comment')
		use('JoosepAlviste/nvim-ts-context-commentstring')
	end,
	config = { compile_path = vim.fn.stdpath("config") .. "/init_compiled.lua" },
})

-- Basics
require('ufo').setup()
require("ibl").setup({
	indent = {
		char = "▏",
	}
})
local builtin = require("statuscol.builtin")
require("statuscol").setup({
	relculright = true,
	segments = { { text = { "%s" },     click = "v:lua.ScSa" },
		{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa", },
		{ text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
	}
})
require('nvim_comment').setup({
	hook = function()
		require('ts_context_commentstring').update_commentstring()
	end,
})
require('ts_context_commentstring').setup {
	enable_autocmd = false,
}
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

-- Telescope --
require('telescope').setup({
	defaults = {
		file_ignore_patterns = { "node_modules" },
	},
})
require("project_nvim").setup({
	detection_methods = { "pattern" },
	patterns = { ".git" },
})
require("telescope").load_extension("projects")

-- Noice --
require("noice").setup({
	presets = { command_palette = true, }, -- position the cmdline and popupmenu together
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
})

-- LSP --
require("nvim-autopairs").setup()
local capabilities = { capabilities = require("cmp_nvim_lsp").default_capabilities() }
local lsp = require("lspconfig")
lsp.lua_ls.setup(capabilities)        -- lua
lsp.eslint.setup(capabilities)        -- JS
lsp.clangd.setup(capabilities)        -- C
lsp.tsserver.setup(capabilities)      -- TS
lsp.stylelint_lsp.setup(capabilities) -- CSS
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


-- LSP Saga (for type definitions) --
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

-- Autocomplete --
local cmp = require('cmp')

require("luasnip/loaders/from_vscode").load()

cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	}, {
		{ name = 'buffer' },
		{ name = 'path' },
	}),

	mapping = cmp.mapping.preset.insert({
		["<Tab>"] = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end,
		["<S-Tab>"] = function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end,
		["<CR>"] = cmp.mapping.confirm({ select = true }),

	}),
	window = {
		completion = {
			border = 'rounded',
		},
		documentation = {
			border = 'rounded',
		},
	},
})

------- Debugger (from here to the end) ------
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

-- Debugger UI --
require("nvim-dap-virtual-text").setup()
local dapui = require("dapui")

dapui.setup()

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
