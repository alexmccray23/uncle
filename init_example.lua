  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup {
        style = "storm",
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      }
      vim.cmd.colorscheme 'tokyonight'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        --theme = 'onedark',
        theme = 'tokyonight',
        component_separators = '|',
        section_separators = '',
      },
    },
  },


  {
    -- lean.nivm
    'ggandor/leap.nvim',
    config = function()
      require('leap').add_default_mappings()
    end
  },

  {
  -- Telescope File Browser
  'nvim-telescope/telescope-file-browser.nvim',
  --   config = function()
  --     require('telescope-file-browser').setup({
  --     })
  --   end
  },

  {
    -- Clipboard manager (especially macros)
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      { 'kkharji/sqlite.lua', build = 'sqlite' },
      -- you'll need at least one of these
      -- {'nvim-telescope/telescope.nvim'},
      -- {'ibhagwan/fzf-lua'},
    },
    config = function()
      require('neoclip').setup({
        enable_persistent_history = true,
      })
    end,
  },


--Separate config file settings.
vim.cmd([[lua require('telescope').load_extension('neoclip')]])

-- Enable telescope file_browser
require("telescope").load_extension "file_browser"

vim.keymap.set('n', '<leader>fb', ":Telescope file_browser path=%:p:h select_buffer=true hidden=true<cr>", { noremap = true, desc = '[F]ile [B]rowser' })
