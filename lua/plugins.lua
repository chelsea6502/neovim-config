return require('packer').startup(function(use)
use 'wbthomason/packer.nvim'
use { 'nvim-tree/nvim-tree.lua', requires = { 'nvim-tree/nvim-web-devicons', },}
use 'mfussenegger/nvim-lint'
use {'akinsho/bufferline.nvim', tag = "*", requires = 'nvim-tree/nvim-web-devicons'}
use { 'nvim-telescope/telescope.nvim', tag = '0.1.5', requires = { {'nvim-lua/plenary.nvim'} }}
use "lukas-reineke/indent-blankline.nvim"
use { 'nvim-treesitter/nvim-treesitter',
    run = function()
       local ts_update = require('nvim-treesitter.install').update({ with_sync = true })    
       ts_update()
        end,
    }
use 'eddyekofo94/gruvbox-flat.nvim'
use {
  'nvim-lualine/lualine.nvim',
  requires = { 'nvim-tree/nvim-web-devicons', opt = true }
}
use 'norcalli/nvim-colorizer.lua'
use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
use {'neoclide/coc.nvim', branch = 'release'}
use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'}}
use {
  'gelguy/wilder.nvim',
  config = function()
    -- config goes here
  end,
}
use {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  config = function()
    require("lsp_lines").setup()
  end,
}

use 'tpope/vim-fugitive'
use {
	"windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
}
use { "mxsdev/nvim-dap-vscode-js", requires = {"mfussenegger/nvim-dap"} }

-- Prettier
use('neovim/nvim-lspconfig')
use('jose-elias-alvarez/null-ls.nvim')
use('MunifTanjim/prettier.nvim')

end)
