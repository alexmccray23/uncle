-- Neovim plugin for adding the underline command
local function underline()
  local line = vim.split(vim.api.nvim_get_current_line(), ';', { plain = true })
  if not line[1]:match('%&UT-') then line[1] = line[1] .. "&UT" end
  local new_line = table.concat(line, ";")
  vim.api.nvim_set_current_line(new_line)
  local linenum = vim.fn.getcurpos()[2] + 1
  vim.api.nvim_win_set_cursor(0, { linenum, 0 })
end
vim.api.nvim_create_user_command("Underline", underline, {})
vim.keymap.set('n', '<M-u>', underline, {desc = "Underline"})
