-- disable netrw at the very start of your init.lua (strongly advised)
--
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup({
        respect_buf_cwd = true,
        update_cwd = false,
        view = {
            width = "25%",
            side = "left"
        },
        update_focused_file = {
            enable = true,
            update_cwd = true,
            update_root = true
        },
        git = {
            enable = true,
          ignore = false,
          timeout = 500,
        },
})

require("nvim-tree.api").tree.toggle({
    update_cwd = true,
    update_root = true
})

vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
      vim.cmd "quit"
    end
  end
})
