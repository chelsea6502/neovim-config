require('plugins')

vim.o.background = "dark"
vim.opt.laststatus = 3
--vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.tabstop = 8
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1       
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.number = true   
vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.virtualedit = "onemore"
vim.opt.equalalways = false
vim.opt.textwidth = 80
vim.opt.guicursor = ""
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 3
vim.opt.relativenumber = true 

vim.loader.enable()
vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', {noremap = true, silent = true})

-- Custom Commands
vim.api.nvim_create_user_command('Soc', 'source  ~/.config/nvim/init.lua', {})
vim.api.nvim_create_user_command('Econf', 'edit ~/.config/nvim/init.lua', {})
vim.api.nvim_create_user_command('Eplugins', 'edit ~/.config/nvim/lua/plugins.lua', {})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

vim.g.gruvbox_dark_sidebar = false
vim.g.gruvbox_flat_style = "dark"
vim.cmd[[colorscheme gruvbox-flat]]

require('lint').linters_by_ft = {
    javascript = {'eslint'},
  -- Add other file types here if needed
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
    require("lint").try_lint()
  end,
})


require('coc')

require('file-explorer')

-- Function to close buffer without disturbing window layout
function CloseBuffer()
  local bufnr = vim.fn.bufnr()
  if vim.fn.buflisted(bufnr) == 1 then
    vim.cmd('bprevious')  -- Switch to the previous buffer
    vim.cmd('bdelete ' .. bufnr)  -- Delete the original buffer
  end
end

vim.api.nvim_set_keymap('n', '<leader><Tab>', ':lua CloseBuffer()<CR>', {noremap = true, silent = true})
require("bufferline").setup({ 
    options = { 
        diagnostics = "nvim_lsp",
        indicator = { style = "none" },
        separator_style = "thin",
        close_command = CloseBuffer,
    }
})
require("nvim-web-devicons").refresh()
require("ibl").setup({ 
    scope = {
       enabled = true,
       show_start = true,
       show_end = false,
       injected_languages = false,
       highlight = { "Function", "Label" },
       priority = 500,
   }
})
require'nvim-treesitter.configs'.setup {
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "javascript", "css", "html" },
    sync_install = true,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = vim.api.nvim_create_augroup("NvimTreeResize", { clear = true }),
    callback = function()
        local percentage = 25
        local ratio = percentage / 100
        local width = math.floor(vim.go.columns * ratio)
        vim.cmd("tabdo NvimTreeResize " .. width)
        
    end,
})


require('debugger')

require('gitsigns').setup()

require('colorizer').setup()

-- disable copilot
vim.b.copilot_enabled = 0


local wilder = require('wilder')
wilder.setup({modes = {':', '/', '?'}})

wilder.set_option('renderer', wilder.popupmenu_renderer(
  wilder.popupmenu_border_theme({
    highlights = {
      border = 'Normal',
    },
    border = 'rounded',
  })
))
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false
})

--require("lsp_lines").setup()

require('lualine').setup({
    options = { theme = 'gruvbox-flat' },
})


