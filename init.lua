-- General nvim settings
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

	" Fixed cursor scrolling
	nnoremap <ScrollWheelUp> 1<C-u>
	nnoremap <ScrollWheelDown> 1<C-d>

	" Diagnostics
	let g:diagnostic_underline = 0
	let g:diagnostic_signs = 1
	let g:diagnostic_severity_sort = 1

	" Use persistent history.
	if !isdirectory("/tmp/.vim-undo-dir")
    call mkdir("/tmp/.vim-undo-dir", "", 0700)
	endif
	set undodir=/tmp/.vim-undo-dir
	set undofile

	" Command shortcuts
	command! Ec edit ~/.config/nvim/init.lua

	autocmd VimEnter * wincmd w  " for NoNeckPain
	
	autocmd FileType * setlocal formatoptions+=t 	" Line wrapping
	autocmd LspAttach * lua vim.lsp.inlay_hint.enable() -- Inlay hints

	" Highlight on yank
	autocmd TextYankPost * silent! 	lua vim.highlight.on_yank {higroup=(vim.fn['hlexists']('HighlightedyankRegion') > 0 and 'HighlightedyankRegion' or 'IncSearch'), timeout=300}	

	]])

vim.diagnostic.config({
	underline = false,
	severity_sort = true,
	virtual_text = false, -- Disable builtin virtual text diagnostic.
	virtual_improved = {
		current_line = "only",
	},
})

vim.keymap.set("n", "<leader>a", vim.lsp.buf.hover, {})
vim.keymap.set("n", "<leader>s", vim.lsp.buf.type_definition, {})
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, {})
vim.keymap.set("n", "<leader>f", vim.lsp.buf.code_action, {})

vim.loader.enable()

-- Enable lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		init = function()
			vim.g.gruvbox_material_foreground = "material"
			vim.g.gruvbox_material_background = "medium"
			vim.g.gruvbox_material_better_performance = 1
			vim.cmd.colorscheme("gruvbox-material")
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
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"jonarrien/telescope-cmdline.nvim",
			{
				"ahmedkhalf/project.nvim",
				main = "project_nvim",
				opts = { detection_methods = { "pattern" }, patterns = { ".git" } },
			},
		},
		keys = {
			{ "fa", "<cmd>Telescope lsp_references<CR>" },
			{ "fs", "<cmd>Telescope live_grep<CR>" },
			{ "fd", "<cmd>Telescope diagnostics<CR>" },
			{ "ff", "<cmd>Telescope git_files<CR>" },
			{ "FF", "<cmd>lua require('telescope').extensions.projects.projects({})<CR>" },
			{ ":", "<cmd>Telescope cmdline<CR>" },
			{ "/", "<cmd>Telescope current_buffer_fuzzy_find<CR>" },
		},
		opts = {
			defaults = { file_ignore_patterns = { "node_modules", "dist" } },
			extensions = {
				cmdline = {
					picker = {
						layout_config = {
							width = 120,
							height = 25,
						},
					},
					mappings = {
						complete = "<Tab>",
						run_selection = "<C-CR>",
						run_input = "<CR>",
					},
				},
			},
		},
		config = function()
			require("telescope").load_extension("projects")
			require("telescope").load_extension("cmdline")
		end,
	},
	{
		"ahmedkhalf/project.nvim",
		main = "project_nvim",
		opts = { detection_methods = { "pattern" }, patterns = { ".git" } },
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		event = "BufRead",
		opts = { inlay_hints = { enabled = true } },
		config = function()
			local lsp_zero = require("lsp-zero")
			lsp_zero.extend_lspconfig()

			lsp_zero.on_attach(function(_, bufnr)
				lsp_zero.default_keymaps({ buffer = bufnr })
			end)

			require("mason").setup()
			require("mason-lspconfig").setup({
				automatic_installation = true,
				handlers = {
					lsp_zero.default_setup,
					tailwindcss = function()
						require("lspconfig").tailwindcss.setup({
							settings = {
								tailwindCSS = {
									experimental = {
										classRegex = { "tw`([^`]*)", "tw\\.[^`]+`([^`]*)`", "tw\\(.*?\\).*?`([^`]*)" },
									},
								},
							},
						})
					end,
				},
			})
			vim.lsp.set_log_level("off")
		end,
	},
	{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },
	{
		"shortcuts/no-neck-pain.nvim",
		opts = {
			options = { width = 100, minSideBufferWidth = 100 },
			buffers = { right = { enabled = false }, wo = { fillchars = "vert: ,eob: " } },
		},
		config = function(_, opts)
			local nnp = require("no-neck-pain")
			nnp.setup(opts)
			nnp.enable()
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufRead",
		main = "ibl",
		opts = { indent = { char = "▏" } },
	},
	{
		"terrortylor/nvim-comment",
		main = "nvim_comment",
		keys = "gc",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
			ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
			keys = "gc",
			opts = { enable_autocmd = false },
		},
		opts = {
			hook = function()
				require("ts_context_commentstring").update_commentstring()
			end,
		},
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

				map("n", "<leader>gp", gs.preview_hunk_inline, "Preview Hunk Inline")
				map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
				map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
			end,
		},
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
		},
		event = "InsertEnter",
		config = function()
			local cmp = require("cmp")
			cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
			local cmp_action = require("lsp-zero").cmp_action()

			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp_action.luasnip_supertab(),
					["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				}),
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvimtools/none-ls-extras.nvim" },
		config = function()
			local null_ls = require("null-ls")

			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.prettierd,
					null_ls.builtins.code_actions.gitsigns,
					require("none-ls.diagnostics.eslint_d"),
					require("none-ls.code_actions.eslint_d"),
				},
			})

			-- Variable highlighting on cursor
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method("textDocument/documentHighlight") then
						vim.cmd([[
							autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
							autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
						]])
					end
				end,
			})

			-- Format on save
			vim.api.nvim_create_autocmd("BufWritePre", {
				callback = function()
					vim.lsp.buf.format({
						async = false,
						filter = function(client)
							return client.name == "null-ls"
						end,
					})
				end,
			})
		end,
	},
	{
		"pmizio/typescript-tools.nvim",
		ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {
			settings = {
				expose_as_code_action = "all",
				tsserver_file_preferences = {
					includeInlayParameterNameHints = "literals",
					includeInlayFunctionParameterTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					-- includeInlayPropertyDeclarationTypeHints = true, -- this crashes
					-- includeInlayVariableTypeHints = true, -- this sucks
				},
			},
		},
	},
	{
		"luozhiya/lsp-virtual-improved.nvim",
		event = { "LspAttach" },
		config = function()
			require("lsp-virtual-improved").setup()
		end,
	},
	{ "windwp/nvim-ts-autotag", opts = { filetypes = { "html", "xml", "javascriptreact", "typescriptreact" } } },
	{
		"akinsho/toggleterm.nvim",
		keys = { { "tt", "<cmd>ToggleTerm<CR>" } },
		version = "*",
		opts = { direction = "float", autochdir = true, persist_mode = false, persist_size = false },
		config = function(_, opts)
			require("toggleterm").setup(opts)

			vim.cmd(
				'autocmd! TermOpen term://*toggleterm#* lua vim.keymap.set("t", "<esc>", [[<C-\\><C-n><cmd>ToggleTerm<CR>]], {buffer = 0})'
			)
		end,
	},
})
