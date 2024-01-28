local vim = vim

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
	set fo+=t
	set updatetime=500
	set noruler
	set noshowcmd
	set laststatus=0
	set cmdheight=0
	set updatetime=50
	set incsearch

	set backupdir=~/.cache/vim

	" Folding Configuration
	set foldcolumn=1
	set foldlevel=99
	set foldlevelstart=99
	set foldenable
	set fillchars=eob:\ ,fold:\ ,foldopen:,foldsep:\ ,foldclose:

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
	command! Cc clang -g % -std=c89<cr>

	" for NoNeckPain
	autocmd VimEnter * wincmd w

	]])

-- Enable lazy
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")

require("lazy").setup({
	-- Package manager
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "gruvbox-material",
			defaults = { version = "*" },
		},
		priority = 1000,
	},

	-- Syntax Highlighter
	{
		"nvim-treesitter/nvim-treesitter",
		event = "BufRead",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.install").update({ with_sync = true })
			require("nvim-treesitter.configs").setup({
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false
				}
			})
		end
	},

	-- Search
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = { 'nvim-lua/plenary.nvim' },
		keys = {
			{ 'ff', "<cmd>Telescope find_files<CR>" },
			{ 'FF', "<cmd>lua require('telescope').extensions.projects.projects({})<CR>" },
			{ 'fs', "<cmd>Telescope live_grep<CR>" },
			{ 'fb', "<cmd>Telescope buffers<CR>" },
			{ 'fh', "<cmd>Telescope help_tags<CR>" },
			{ 'fn', "<cmd>Telescope noice<CR>" },
		},
		opts = {
			defaults = {
				file_ignore_patterns = { "node_modules" },
			},
		},
		config = function()
			require("telescope").load_extension("projects")
		end
	},

	-- LSP, linter, formatter, and debugger
	{
		"neovim/nvim-lspconfig",
		event = "BufRead",
		config = function()
			vim.lsp.set_log_level("off")
			local capabilities = { capabilities = require("cmp_nvim_lsp").default_capabilities() }
			local lsp = require("lspconfig")
			lsp.lua_ls.setup(capabilities)     -- lua
			lsp.eslint.setup(capabilities)     -- JS
			lsp.clangd.setup(capabilities)     -- C
			lsp.tsserver.setup(capabilities)   -- TS
			lsp.stylelint_lsp.setup(capabilities) -- CSS
		end
	},
	{
		"mfussenegger/nvim-lint",
		event = "BufRead",
		config = function()
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
		end
	},
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		opts = {
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
		}
	},
	{
		"mfussenegger/nvim-dap",
		event = "BufRead",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text"
		},
		config = function()
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

			vim.cmd([[ 	" Keybindings for DAP (Debug Adapter Protocol)
				nnoremap <Leader>db :lua require'dap'.toggle_breakpoint()<CR>
				nnoremap <Leader>du :lua require'dapui'.toggle()<CR>
				nnoremap <Leader>dc :lua require'dap'.continue()<CR>
				nnoremap <Leader>ds :lua require'dap'.step_over()<CR>
				nnoremap <Leader>di :lua require'dap'.step_into()<CR>
				nnoremap <Leader>do :lua require'dap'.step_out()<CR>
				nnoremap <Leader>dd :lua require'dap'.disconnect()<CR>
				nnoremap <Leader>dr :lua require'dap'.restart()<CR>
				nnoremap <Leader>dt :lua require'dap'.close()<CR>
			]])
		end
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		ft = "javascript, typescript, javascriptreact, typescriptreact",
		opts = {
			node_path = "/opt/homebrew/bin/node",
			debugger_path = vim.fn.expand("$HOME/.config/nvim/vscode-js-debug/"),
			adapters = { "pwa-node", "pwa-chrome" },
		}
	},
	{ "microsoft/vscode-js-debug", lazy = true },

	-- Bracket pairing
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
	},

	-- AI completion
	{
		"github/copilot.vim",
		cmd = "Copilot",
		init = function()
			vim.cmd([[" Copilot Configuration
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
		]])
		end
	},
	{ "gptlang/CopilotChat.nvim",  cmd = "CopilotChat" },

	-- Other utilities
	{
		"shortcuts/no-neck-pain.nvim",
		config = function()
			local nnp = require("no-neck-pain")
			nnp.setup({
				options = {
					width = 100,
					minSideBufferWidth = 100,
				},
				buffers = {
					right = { enabled = false },
					wo = {
						fillchars = "vert: ,eob: ",
					},
				},
			})
			nnp.enable()
		end
	},
	{
		"ahmedkhalf/project.nvim",
		cmd = "Project",
		main = "project_nvim",
		opts = {
			detection_methods = { "pattern" },
			patterns = { ".git" },
		},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufRead",
		main = "ibl",
		opts = {
			indent = {
				char = "▏",
			}
		},
	},
	{
		"luukvbaal/statuscol.nvim",
		config = function()
			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = true,
				segments = { { text = { "%s" },     click = "v:lua.ScSa" },
					{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa", },
					{ text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
				}
			})
		end
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		config = function()
			require('ufo').setup()
		end
	},
	{
		'sainnhe/gruvbox-material',
		event = "VimEnter",
		init = function()
			vim.g.gruvbox_material_foreground = 'material'
			vim.g.gruvbox_material_background = 'medium'
			vim.g.gruvbox_material_better_performance = 1
		end
	},
	{
		"folke/noice.nvim",
		dependencies = "MunifTanjim/nui.nvim",
		opts = {
			presets = { command_palette = true, }, -- position the cmdline and popupmenu together
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
		}
	},
	{
		'nvimdev/lspsaga.nvim',
		event = "LspAttach",
		keys = {
			{ '<leader>a', "<cmd>Lspsaga hover_doc<CR>" },
			{ '<leader>s', "<cmd>Lspsaga peek_definition<CR>" },
			{ '<leader>d', "<cmd>Lspsaga show_line_diagnostics<CR>" },
			{ '<leader>f', "<cmd>Lspsaga code_action<CR>" },
			{ '<leader>r', "<cmd>Lspsaga rename<CR>" },
		},
		opts = {
			lightbulb = { enable = false, },
			symbol_in_winbar = { enable = false, }
		},
	},

	-- Autocomplete and snippets
	{
		'hrsh7th/nvim-cmp',
		event = "InsertEnter",
		config = function()
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
		end
	},
	{ 'hrsh7th/cmp-nvim-lsp', },
	{ 'L3MON4D3/LuaSnip', },
	{ 'saadparwaiz1/cmp_luasnip', },
	{ 'rafamadriz/friendly-snippets', event = "InsertEnter" },
	{ 'hrsh7th/cmp-buffer', },
	{ 'hrsh7th/cmp-path', },

	-- Comments
	{
		'terrortylor/nvim-comment',
		main = "nvim_comment",
		opts = {
			hook = function()
				require('ts_context_commentstring').update_commentstring()
			end,
		},
	},
	{
		'JoosepAlviste/nvim-ts-context-commentstring',
		ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
		opts = {
			enable_autocmd = false,
		}
	},
})
