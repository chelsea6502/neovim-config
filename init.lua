vim.cmd([[
	let g:mapleader = " "
	nnoremap <Space> <Nop>

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
	set updatetime=500
	set noruler
	set noshowcmd
	set laststatus=0
	set cmdheight=1
	set updatetime=50
	set incsearch
	set ignorecase
	set smartcase
	set scrolloff=10
	set cmdheight=0
	set backupdir=~/.cache/vim
	set autoread
	set undodir=/tmp/.vim-undo-dir
	set undofile
	if !isdirectory("/tmp/.vim-undo-dir")
    call mkdir("/tmp/.vim-undo-dir", "", 0700)
	endif

	" Fixed cursor scrolling
	nnoremap <ScrollWheelUp> 1<C-u>
	nnoremap <ScrollWheelDown> 1<C-d>

	" Diagnostics
	let g:diagnostic_underline = 0
	let g:diagnostic_signs = 1
	let g:diagnostic_severity_sort = 1

	" Command shortcuts
	command! Ec edit ~/.config/nvim/init.lua

	nnoremap <leader>a <cmd>lua vim.lsp.buf.hover()<CR>
	nnoremap <leader>s <cmd>lua vim.lsp.buf.type_definition()<CR>
	nnoremap <leader>d <cmd>lua vim.diagnostic.open_float()<CR>
	nnoremap <leader>f <cmd>lua vim.lsp.buf.code_action()<CR>

	" Highlight on yank
	autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup=(vim.fn['hlexists']('HighlightedyankRegion') > 0 and 'HighlightedyankRegion' or 'IncSearch'), timeout=300}	

	]])

-- Enable lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
-- 	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
-- end
vim.opt.rtp:prepend(lazypath)

local REACT = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
local HTML = { "html", "xml", "typescriptreact", "javascriptreact" }

require("lazy").setup({
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[
				let g:gruvbox_material_foreground = "material"
				let g:gruvbox_material_background = "medium"
				let g:gruvbox_material_better_performance = 1
				colorscheme gruvbox-material
			]])
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"jonarrien/telescope-cmdline.nvim",
			{
				"ahmedkhalf/project.nvim",
				event = "BufRead",
				main = "project_nvim",
				opts = { detection_methods = { "pattern" } },
			},
			"nvim-telescope/telescope-ui-select.nvim",
		},
		keys = {
			{ "fa", "<cmd>Telescope lsp_references theme=cursor<CR>" },
			{ "fs", "<cmd>Telescope live_grep theme=dropdown<CR>" },
			{ "fd", "<cmd>Telescope diagnostics theme=dropdown<CR>" },
			{ "ff", "<cmd>Telescope git_files<CR>" },
			{ "fF", "<cmd>Telescope oldfiles<CR>" },
			{ "FF", "<cmd>Telescope projects theme=dropdown<CR>" },
			{ ":",  "<cmd>Telescope cmdline<CR>" },
			{ "/",  "<cmd>Telescope current_buffer_fuzzy_find theme=dropdown<CR>" },
		},
		opts = function()
			return {
				defaults = {
					file_ignore_patterns = { "node_modules", "dist" },
					mappings = { i = { ["<esc>"] = require("telescope.actions").close } },
				},
				extensions = { ["ui-select"] = { require("telescope.themes").get_cursor() } },
				cmdline = { mappings = { run_selection = "<CR>", run_input = "<C-CR>" } },
			}
		end,
		config = function(_, opts)
			require("telescope").setup(opts)
			require("telescope").load_extension("projects")
			require("telescope").load_extension("cmdline")
			require("telescope").load_extension("ui-select")
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = "nvimtools/none-ls-extras.nvim",
		opts = function()
			return {
				sources = {
					require("null-ls").builtins.formatting.stylua,
					require("null-ls").builtins.formatting.prettierd,
					require("none-ls.diagnostics.eslint"),
					require("none-ls.code_actions.eslint"),
				},
			}
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			{ "folke/neodev.nvim",         config = true },
		},
		event = "BufRead",
		config = function()
			local lsp_zero = require("lsp-zero")

			require("neodev").setup()

			-- LSP-specific features
			lsp_zero.on_attach(function(client, bufnr)
				lsp_zero.highlight_symbol(client, bufnr)
				lsp_zero.buffer_autoformat()
			end)

			lsp_zero.set_sign_icons({ error = "✘", warn = "▲", hint = "⚑", info = "»" })

			lsp_zero.extend_lspconfig()
			require("mason").setup()
			require("mason-lspconfig").setup({
				automatic_installation = true,
				handlers = {
					lsp_zero.default_setup,
					lua_ls = function()
						require("lspconfig").lua_ls.setup(lsp_zero.nvim_lua_ls())
					end,
					tailwindcss = function()
						local twRegex = { "tw`([^`]*)", "tw\\.[^`]+`([^`]*)`", "tw\\(.*?\\).*?`([^`]*)" }
						require("lspconfig").tailwindcss.setup({
							settings = { tailwindCSS = { experimental = { classRegex = twRegex } } },
						})
					end,
				},
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
		},
		event = "InsertEnter",
		opts = function()
			require("lsp-zero").extend_cmp()
			local cmp = require("cmp")
			cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
			local cmp_action = require("lsp-zero").cmp_action()

			return {
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp_action.luasnip_supertab(),
					["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
			}
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			auto_install = true,
			sync_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{ "windwp/nvim-autopairs",  event = "InsertEnter", opts = { check_ts = true } },
	{ "windwp/nvim-ts-autotag", ft = HTML,             opts = { filetypes = HTML } },
	{
		"shortcuts/no-neck-pain.nvim",
		opts = {
			autocmds = { enableOnVimEnter = true, skipEnteringNoNeckPainBuffer = true },
			options = { width = 100, minSideBufferWidth = 100 },
			buffers = { right = { enabled = false }, wo = { fillchars = "vert: ,eob: " } },
		},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufRead",
		main = "ibl",
		opts = { indent = { char = "▏" } },
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "LspAttach",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			on_attach = function(buffer)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

				map("n", "<leader>gp", gs.preview_hunk_inline)
				map("n", "<leader>gr", gs.reset_hunk)
				map("n", "<leader>gR", gs.reset_buffer)
			end,
		},
	},
	{
		"pmizio/typescript-tools.nvim",
		ft = REACT,
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = { settings = { complete_function_calls = true, expose_as_code_action = "all" } },
	},
	{
		"luozhiya/lsp-virtual-improved.nvim",
		event = "LspAttach",
		config = function()
			require("lsp-virtual-improved").setup()

			vim.diagnostic.config({
				underline = false,
				virtual_text = false,
				virtual_improved = { current_line = "only" },
			})
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		keys = { { "tt", "<cmd>ToggleTerm<CR>" } },
		version = "*",
		opts = { direction = "float", autochdir = true, persist_mode = false, persist_size = false },
		init = function()
			vim.cmd("autocmd! TermOpen term://*toggleterm#* tnoremap <buffer> <esc> <cmd>close<CR>")
		end,
	},
})
