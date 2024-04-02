-- Neovim plugin for adding the SPACE 1 option to Uncle tables

local M = {}

function M.space1()
  local count = vim.v.count ~= 0 and vim.v.count or 1
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for _ = 1, count do
    local line = vim.api.nvim_get_current_line()
    local array = vim.split(vim.api.nvim_get_current_line(), ';', { plain = true })
    local new_line = ""
    if #array == 2 then
      new_line = line .. ";SPACE 1"
    elseif #array > 2 then
      new_line = line .. " SPACE 1"
    end
    vim.api.nvim_set_current_line(new_line)
    local next_line = current_line + 1
    vim.api.nvim_win_set_cursor(0, { next_line, 0 })

    current_line = next_line
  end
end

vim.api.nvim_create_user_command("Space1", M.space1, {})

return M

