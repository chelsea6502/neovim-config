vim.cmd[[
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
	set lcs=trail:·,tab:\|\ 
	let g:netrw_winsize = 20
	let g:netrw_banner = 0
	let g:netrw_altv=1
	autocmd VimEnter * :silent! Lexplore

	" Key mappings
	nnoremap <Tab> :bnext<CR>
	nnoremap <S-Tab> :bprevious<CR>
	nnoremap <Leader>b :set nomore <Bar> :ls <Bar> :set more <CR>:b<Space>

	" Autopairing
	inoremap " ""<left>
	inoremap ' ''<left>
	inoremap ( ()<left>
	inoremap [ []<left>
	inoremap { {}<left>
	inoremap < <><left>
	inoremap {<CR> {<CR>}<ESC>O

	" Custom Commands
	command! Sc source ~/.config/nvim/init.lua
	command! Ec edit ~/.config/nvim/init.lua
	command! Ep edit ~/.config/nvim/lua/plugins.lua

	" Theme
	let g:gruvbox_dark_sidebar = 0
	let g:gruvbox_flat_style = "dark"
	colorscheme gruvbox-flat

	autocmd BufWritePost *.c call s:CompileAndFormatCFile()
	function! s:CompileAndFormatCFile()
		let l:filenameNoExtension = expand('%:t:r')
		let l:filename = expand('%')
		silent !clang-format -i l:filename
		edit!
		silent !clang -g -std=c89 l:filename -o l:filenameNoExtension
	endfunction

	au BufWritePost * lua require('lint').try_lint()

]]

-- Move to /pack/ when all set up
require('packer').startup({function(use)
	use 'wbthomason/packer.nvim' -- Package manager
	use 'eddyekofo94/gruvbox-flat.nvim' -- Theme
	use 'nvim-treesitter/nvim-treesitter' -- Syntax Highlighter
	-- Search (fzf.vim)
	-- Autocomplete (nvim-cmp?)
	use 'mfussenegger/nvim-lint' -- Linter
	-- Prettier (nvim/prettier?)
	use "mfussenegger/nvim-dap" -- Debugger
	use "mxsdev/nvim-dap-vscode-js" -- JavaScript debugger
  -- Debugger UI (dap-ui or dap-inline)
	-- C/C++ debugger (vscode-cpptools)
	-- Copilot
end, 
config = { compile_path = vim.fn.stdpath('config') .. '/init_compiled.lua'}
})

require('nvim-treesitter.install').update({ with_sync = true })
require('nvim-treesitter.configs').setup({ highlight = { enable = true, additional_vim_regex_highlighting = false } })

-- Linter --
local linter = require("lint")
linter.linters.clangtidy.args = { "-std=c89" }
linter.linters_by_ft = { 
	javascript = {'eslint'}, 
	typescript = {'eslint'}, 
	javascriptreact = {'eslint'}, 
	typescriptreact = {'eslint'}, 
	json = {'eslint'},
	c = {'clangtidy'},
	cpp = {'clangtidy'},
	-- html
	-- css
	-- lua
}

