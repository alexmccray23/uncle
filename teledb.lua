-- Neovim plugin for fuzzy searching a local project database by client id or project name.

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local previewers = require "telescope.previewers"
local utils = require "telescope.previewers.utils"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local log = require("plenary.log"):new()
log.level = "debug"
require("telescope").load_extension "file_browser"

local M = {}

local path = "/home/alexm/rust/vd/xl2json/projects.json"

-- Function to read and parse the JSON file
M.read_and_parse_json = function(file_path)
  local file = io.open(file_path, "r")
  if not file then
    log.error("Failed to open file: " .. file_path)
    return {}
  end
  local content = file:read "*a"
  file:close()
  local data = vim.json.decode(content)
  if not data or not data.items then
    log.error "Failed to parse JSON or 'items' not found"
    return {}
  end
  return data.items
end

M.studies_prompt = function(opts)
  opts = opts or {}
  local items = M.read_and_parse_json(path)

  pickers
    .new(opts, {
      prompt_title = "🚀 Projects 🚀",
      finder = finders.new_table {
        results = items,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.label,
            ordinal = entry.label .. " " .. entry.year,
          }
        end,
      },
      sorter = conf.generic_sorter(opts),
      previewer = previewers.new_buffer_previewer {
        title = "Project Details",
        define_preview = function(self, entry)
          local content = {}
          table.insert(content, "Project     " .. entry.value.label)
          table.insert(content, "Year        " .. entry.value.year)
          table.insert(content, "VD ID       " .. entry.value.vd_id)
          table.insert(content, "Client ID   " .. entry.value.client_id)
          table.insert(content, "Path        " .. entry.value.path)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)
          utils.highlighter(self.state.bufnr, "man")
        end,
      },
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local command = ":Telescope file_browser path=" .. selection.value.path .. "/uncle select_buffer=true hidden=true<cr>"
          vim.cmd(command)
        end)
        return true
      end,
    })
    :find()
end

function M.study_selector()
  M.studies_prompt(require("telescope.themes").get_dropdown {
    layout_config = {
      center = {
        height = 0.65,
        preview_height = 10,
        width = 0.65,
      },
    },
  })
end

vim.api.nvim_create_user_command("Teledb", M.study_selector, {})

return M
