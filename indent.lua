-- Neovim plugin for indenting an R row in Uncle
--local function indent()
--  local line = vim.split(vim.api.nvim_get_current_line(), ' ', { plain = true })
--  if line[1]:match('^R') then line[1] = line[1] .. "  " end
--  local new_line = table.concat(line, " ")
--  vim.api.nvim_set_current_line(new_line)
--  local linenum = vim.fn.getcurpos()[2] + 1
--  vim.api.nvim_win_set_cursor(0, { linenum, 0 })
--end
--vim.api.nvim_create_user_command("IndentRow", indent, {})
--vim.keymap.set('n', '<M-z>', indent, {desc = "IndentRow", silent = true})

local M = {}

function M.indent()
  -- Set the count to 1 if there is no count given.
  local count = vim.v.count ~= 0 and vim.v.count or 1
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for _ = 1, count do
    local line = vim.split(vim.api.nvim_get_current_line(), ' ', { plain = true })
    if line[1]:match('^R') then line[1] = line[1] .. "  " end
    local new_line = table.concat(line, " ")
    vim.api.nvim_set_current_line(new_line)
    local next_line = current_line + 1
    vim.api.nvim_win_set_cursor(0, { next_line, 0 })

    -- Go to the next line
    current_line = next_line
  end
end

vim.api.nvim_create_user_command("IndentRow", M.indent, {})
--vim.api.nvim_set_keymap('n', '<M-z>', ':lua indent()<CR>', { noremap = true, silent = true })

return M
