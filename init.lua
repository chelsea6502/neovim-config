require('plugins')

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

	" Key mappings
	nnoremap <Tab> :bnext<CR>
	nnoremap <S-Tab> :bprevious<CR>
	nnoremap <leader><Tab> :lua CloseBuffer()<CR>

	" Custom Commands
	command! Sc source ~/.config/nvim/init.lua
	command! Ec edit ~/.config/nvim/init.lua
	command! Ep edit ~/.config/nvim/lua/plugins.lua

	let g:gruvbox_dark_sidebar = 0
	let g:gruvbox_flat_style = "dark"
	colorscheme gruvbox-flat

	function! CloseBuffer()
		let bufnr = bufnr('%')
		if buflisted(bufnr)
			bprevious
			execute 'bdelete ' . bufnr
		endif
	endfunction

	" Create an autocommand group and clear it
	augroup NvimTreeResize
		autocmd!
	augroup END

	" Define the autocmd within the group
	autocmd VimResized * if exists(":NvimTreeResize") | exe "tabdo NvimTreeResize " . float2nr(&columns * 1/4) | endif

	autocmd BufWritePost *.c call s:CompileAndFormatCFile()

	function! s:CompileAndFormatCFile()
    let l:filenameNoExtension = expand('%:t:r')
    let l:filename = expand('%')
    silent !clang-format -i l:filename
    edit!
    silent !clang -g -std=c89 l:filename -o l:filenameNoExtension
	endfunction

	let g:loaded_netrw = 1
	let g:loaded_netrwPlugin = 1

	au BufWritePost * lua require('lint').try_lint()

]]

require('gitsigns').setup()
require('colorizer').setup()
require("nvim-web-devicons").refresh()
require("lsp_lines").setup()
require('lualine').setup({ options = { theme = 'gruvbox-flat' } })
require("nvim-autopairs").setup()
require("ibl").setup()
require('wilder').setup({modes = {':', '/', '?'}})
require("bufferline").setup({ options = { diagnostics = "nvim_lsp", close_command = CloseBuffer }})
require("nvim-tree").setup()
require("nvim-tree.api").tree.toggle({ update_cwd = true, update_root = true })

-- Error lines/text -- 
vim.diagnostic.config({
  virtual_text = false,
	virtual_lines = { only_current_line = true },
	severity_sort = true
})

-- Linter --
local linter = require("lint")
linter.linters.clangtidy.args = { "-std=c89" }
linter.linters_by_ft = {
    javascript = {'eslint'},
    c = {'clangtidy'}
}

-- Syntax Highlighting  --
require("nvim-treesitter.configs").setup {
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "javascript", "css", "html" },
    sync_install = true,
    auto_install = true,
    highlight = { enable = true, additional_vim_regex_highlighting = false },
}
