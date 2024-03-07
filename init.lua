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
	
	set backupdir=~/.cache/vim

	" Fixed cursor scrolling
	nnoremap <ScrollWheelUp> 1<C-u>
	nnoremap <ScrollWheelDown> 1<C-d>

	" Diagnostics
	let g:diagnostic_underline = 0
	let g:diagnostic_signs = 1
	let g:diagnostic_severity_sort = 1
	"let g:gruvbox_material_diagnostic_virtual_text = 'colored'

	" Use persistent history.
	if !isdirectory("/tmp/.vim-undo-dir")
    call mkdir("/tmp/.vim-undo-dir", "", 0700)
	endif
	set undodir=/tmp/.vim-undo-dir
	set undofile

	" Command shortcuts
	command! Ec edit ~/.config/nvim/init.lua
	command! Sc source ~/.config/nvim/init.lua
	command! Cc clang -g % -std=c89<cr>

	" for NoNeckPain
	autocmd VimEnter * wincmd w

	autocmd FocusLost * :wa

	set autoread

	" Line wrapping
	autocmd FileType * setlocal formatoptions+=t

	autocmd LspAttach * lua vim.lsp.inlay_hint.enable()

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
			vim.g.gruvbox_material_background = "medium"
			vim.g.gruvbox_material_better_performance = 1
			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				sync_install = true,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "ff", "<cmd>Telescope find_files<CR>" },
			{ "fs", "<cmd>Telescope live_grep<CR>" },
		},
		opts = { defaults = { file_ignore_patterns = { "node_modules", "dist" } } },
		config = function()
			require("telescope").load_extension("projects")
		end,
	},
	{
		"ahmedkhalf/project.nvim",
		keys = {
			{ "FF", "<cmd>lua require('telescope').extensions.projects.projects({})<CR>" },
		},
		main = "project_nvim",
		opts = { detection_methods = { "pattern" }, patterns = { ".git" } },
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		event = "BufRead",
		opts = { inlay_hints = { enabled = true } },
		config = function()
			local lsp_zero = require("lsp-zero")

			lsp_zero.on_attach(function(_, bufnr)
				lsp_zero.default_keymaps({ buffer = bufnr })
			end)

			local cmp = require("cmp")
			local cmp_action = lsp_zero.cmp_action()

			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp_action.luasnip_supertab(),
					["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				}),
			})

			require("mason").setup({})
			require("mason-lspconfig").setup({
				ensure_installed = {},
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
		config = function()
			local nnp = require("no-neck-pain")
			nnp.setup({
				options = { width = 100, minSideBufferWidth = 100 },
				buffers = { right = { enabled = false }, wo = { fillchars = "vert: ,eob: " } },
			})
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
		opts = {
			hook = function()
				require("ts_context_commentstring").update_commentstring()
			end,
		},
	},
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
		opts = { enable_autocmd = false },
	},

	{
		"luukvbaal/statuscol.nvim",
		config = function()
			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = true,
				segments = {
					{ sign = { name = { ".*" }, namespace = { "gitsigns" }, colwidth = 1 }, click = "v:lua.ScSa" },
					{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
					{ sign = { name = { ".*" }, namespace = { "diagnostic*" }, colwidth = 2 }, click = "v:lua.ScSa" },
				},
			})
		end,
	},
	{
		"folke/noice.nvim",
		dependencies = "MunifTanjim/nui.nvim",
		opts = {
			presets = { command_palette = true },
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
		},
	},
	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		keys = {
			{ "<leader>a", "<cmd>Lspsaga hover_doc<CR>" },
			{ "<leader>s", "<cmd>Lspsaga peek_definition<CR>" },
			{ "<leader>d", "<cmd>Lspsaga show_line_diagnostics<CR>" },
			{ "<leader>f", "<cmd>Lspsaga code_action<CR>" },
			{ "<leader>r", "<cmd>Lspsaga rename<CR>" },
		},
		opts = { lightbulb = { enable = false }, symbol_in_winbar = { enable = false } },
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

				map("n", "]h", gs.next_hunk, "Next Hunk")
				map("n", "[h", gs.prev_hunk, "Prev Hunk")
				map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
				map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
				map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
				map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
				map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
				map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
			end,
		},
	},
	{ "williamboman/mason.nvim" },
	{ "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/nvim-cmp" },
	{ "L3MON4D3/LuaSnip" },
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
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {
			settings = {
				expose_as_code_action = "all",
				tsserver_file_preferences = {
					includeInlayParameterNameHints = "literals",
					includeInlayFunctionParameterTypeHints = true,
					--includeInlayVariableTypeHints = true, -- this crashes
					includeCompletionsForModuleExports = true,
					quotePreference = "auto",
					includeInlayFunctionLikeReturnTypeHints = true,
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
})
