-- Neovim plugin for indenting an R row in Uncle
local function indent()
  local line = vim.split(vim.api.nvim_get_current_line(), ' ', { plain = true })
  if line[1]:match('^R') then line[1] = line[1] .. "  " end
  local new_line = table.concat(line, " ")
  vim.api.nvim_set_current_line(new_line)
  local linenum = vim.fn.getcurpos()[2] + 1
  vim.api.nvim_win_set_cursor(0, { linenum, 0 })
end
vim.api.nvim_create_user_command("IndentRow", indent, {})
vim.keymap.set('n', '<M-z>', indent, {desc = "IndentRow", silent = true})
