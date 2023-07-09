local telescope_setup, _ = pcall(require, "telescope")
if not telescope_setup then
  return
end

local builtin = require 'telescope.builtin'
local actions = require 'telescope.actions'
local layout = require 'telescope.actions.layout'
local themes = require 'telescope.themes'

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ["<C-h>"] = actions.select_horizontal,
        ["<C-l>"] = actions.select_vertical,
        ["<C-n>"] = layout.cycle_layout_next,
      },
      n = {
        ["<C-h>"] = actions.select_horizontal,
        ["<C-l>"] = actions.select_vertical,
        ["<C-n>"] = layout.cycle_layout_next,
      },
    },
  },
  extensions = {
    file_browser = {
      theme = 'ivy',
    },
  },
}
-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Enable telescope file_browser
require("telescope").load_extension "file_browser"

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  builtin.current_buffer_fuzzy_find(themes.get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })

vim.keymap.set('n', '<leader>fb', ":Telescope file_browser path=%:p:h select_buffer=true hidden=true<cr>",
  { noremap = true, desc = '[F]ile [B]rowser' })
