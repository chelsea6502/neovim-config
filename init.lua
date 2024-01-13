vim.cmd([[
	set background=dark
	set laststatus=3
	set tabstop=2
	set shiftwidth=2
	set softtabstop=2
	set number
	set colorcolumn=80
	set cursorline
	set termguicolors
	set virtualedit=onemore
	set textwidth=80
	set guicursor=
	set relativenumber
	set clipboard=unnamedplus
	set list
	set lcs=trail:·,tab:\|\ "
	let g:netrw_winsize = 20
	let g:netrw_banner = 0
	let g:netrw_altv=1
	autocmd VimEnter * :silent! Lexplore
	let g:coq_settings = { 'auto_start': v:true }
	
	" Key mappings
	nnoremap <Tab> :bnext<CR>
	nnoremap <S-Tab> :bprevious<CR>
	nnoremap <Leader>b :set nomore <Bar> :ls <Bar> :set more <CR>:b<Space>

	" Custom Commands
	command! Sc source ~/.config/nvim/init.lua
	command! Ec edit ~/.config/nvim/init.lua
	command! Ep edit ~/.config/nvim/lua/plugins.lua

	" Theme
	let g:gruvbox_material_foreground = 'material'
	let g:gruvbox_material_background = 'medium'
	let g:gruvbox_material_better_performance = 1
	colorscheme gruvbox-material

	au BufWritePost * lua require('lint').try_lint()

	nnoremap <leader>ff <cmd>Telescope find_files<cr>
	nnoremap <leader>fg <cmd>Telescope live_grep<cr>
	nnoremap <leader>fb <cmd>Telescope buffers<cr>
	nnoremap <leader>fh <cmd>Telescope help_tags<cr>
	
	nnoremap <leader>c <cmd>:!clang -g % -std=c89<cr>


]])

-- Move to /pack/ when all set up
require("packer").startup({
	function(use)
		use("wbthomason/packer.nvim") -- Package manager
		use("sainnhe/gruvbox-material") -- Theme
		use("nvim-treesitter/nvim-treesitter") -- Syntax Highlighter
		use({ "nvim-telescope/telescope.nvim", tag = "0.1.5", requires = { { "nvim-lua/plenary.nvim" } } }) -- Search
		use("neovim/nvim-lspconfig")
		use("ms-jpq/coq_nvim") -- Autocomplete
		use("ms-jpq/coq.artifacts") -- Autocomplete snippets
		use("mfussenegger/nvim-lint") -- Linter
		use({ "quick-lint/quick-lint-js", rtp = "plugin/vim/quick-lint-js.vim", tag = "3.1.0", opt = true })
		use("stevearc/conform.nvim") -- Formatter
		use("mfussenegger/nvim-dap") -- Debugger
		use("mxsdev/nvim-dap-vscode-js") -- JavaScript debugger
		use({ "microsoft/vscode-js-debug", opt = true })
		use("windwp/nvim-autopairs") -- Bracket pairing
		-- Debugger UI (dap-ui or dap-inline)
		use("theHamsta/nvim-dap-virtual-text")
		-- C/C++ debugger (vscode-cpptools)
		-- Copilot
	end,
	config = { compile_path = vim.fn.stdpath("config") .. "/init_compiled.lua" },
})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		c = { "clang_format" },
		cpp = { "clang_format" },
	},
	format_on_save = { timeout_ms = 500, lsp_fallback = true },
})

require("nvim-autopairs").setup()
require("lspconfig/quick_lint_js").setup({})
local lsp = require("lspconfig")
local coq = require("coq")
lsp.lua_ls.setup(coq.lsp_ensure_capabilities({})) -- lua
lsp.eslint.setup(coq.lsp_ensure_capabilities({})) -- JS
lsp.clangd.setup(coq.lsp_ensure_capabilities({})) -- C

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
}

------- Debugger ------
local dap = require("dap")
vim.lsp.set_log_level("DEBUG") -- Sets the logging level. 'DEBUG' is the most verbose.
dap.adapters.lldb = {
	type = "executable",
	command = "/opt/homebrew/opt/llvm/bin/lldb-vscode", -- adjust as needed
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

-- Keybindings
vim.api.nvim_set_keymap(
	"n",
	"<Leader>db",
	'<Cmd>lua require"dap".toggle_breakpoint()<CR>',
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<Leader>dc", '<Cmd>lua require"dap".continue()<CR>', { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "<Leader>ds", '<Cmd>lua require"dap".step_over()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>di", '<Cmd>lua require"dap".step_into()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>do", '<Cmd>lua require"dap".step_out()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dd", '<Cmd>lua require"dap".disconnect()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dr", '<Cmd>lua require"dap".restart()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dt", '<Cmd>lua require"dap".close()<CR>', { noremap = true, silent = true })
