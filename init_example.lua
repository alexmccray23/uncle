-- Splitting a window vertically will put the new window right of the current one
vim.o.splitright = true

-- Splitting a window horizontally put the new window below the current one
vim.o.splitbelow = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Remove ~ from the line number column
vim.o.fillchars = "eob: "

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'


-- NOTE: THESE WERE ADDED DIRECTLY TO ~/.local/share/nvim/lazy/nvim-tree/lua/keymap.lua
vim.keymap.set('n', '<C-h>', api.node.open.horizontal, opts('Open: Horizonal Split'))
vim.keymap.set('n', '<C-l>', api.node.open.vertical, opts('Open: Vertical Split'))

-- Telescope setup for similar horizontal and vertical file openning options
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ["<C-h>"] = actions.select_horizontal,
        ["<C-l>"] = actions.select_vertical,
      },
      n = {
        ["<C-h>"] = actions.select_horizontal,
        ["<C-l>"] = actions.select_vertical,
      },
    },
  },
}
