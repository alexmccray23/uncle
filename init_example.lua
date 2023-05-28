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

  4.
gou() {
  local year=${2:-2023}
  cd '/home/alex/kdata/'$year'/'$1'/uncle'
}

ghp_3r5OMvjFFa8U0***AxAdw2zgiuOMUGxGF40kwxD

local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>n', ':lua require("user.plugins.custom.indent").indent()<CR>', { noremap = true, silent = true, desc = "Uncle: Indent" })
keymap('n', '<M-d>', ':lua require("user.plugins.custom.pos_spec_conversion").posSpecConversion()<CR>', { noremap = true, silent = true })
keymap('n', '<leader>k', ':lua require("user.plugins.custom.uncle_syntax").uncleSyntax()<CR>', { noremap = true, silent = true, desc = "Uncle: QX-1 syntax" })
keymap('n', '<leader>j', ':lua require("user.plugins.custom.uncle_syntax").combFix()<CR>', { noremap = true, silent = true, desc = "Uncle: QX:1 syntax" })
keymap('n', '<leader>i', ':lua require("user.plugins.custom.in2").indent()<CR>', { noremap = true, silent = true, desc = "Uncle: &IN2" })
keymap('n', '<leader>l', ':lua require("user.plugins.custom.banner_column").bannerColumn()<CR>', { noremap = true, silent = true, desc = "Uncle: Insert banner columns" })
keymap('n', '<leader>rr', ':lua require("user.plugins.custom.r_row").rRow()<CR>', { noremap = true, silent = true, desc = "Uncle: Insert R Row" })
--]]
