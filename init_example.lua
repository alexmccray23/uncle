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


luasnip.config.setup {
  history = true,
  updateevents = "TextChanged, TextChangedI"
}
require("user.plugins.custom.my_snippets")
vim.keymap.set("i", "<c-l>", function()
  if luasnip.choice_active() then
    luasnip.change_choice(1)
  end
end)
--[[
  .bashrc stuff (bat command and man page update)
  1. Install bat: `sudo apt install bat`
  2. Symlink batcat to bat `sudo ln -s /usr/bin/batcat /usr/bin/bat`
  3. Add to .bashrc export `MANPAGER="sh -c 'col -bx | bat -l man -p'"`
--]]
