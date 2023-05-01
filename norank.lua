-- Neovim plugin for adding the NORANK command to Uncle tables
local function noRank()
  local line = vim.api.nvim_get_current_line()
  local array = vim.split(vim.api.nvim_get_current_line(), ';', { plain = true })
  local new_line = ""
  if #array == 2 then
    new_line = line..";NORANK"
  elseif #array > 2 then
    new_line = line.." NORANK"
  end
  vim.api.nvim_set_current_line(new_line)
  local linenum = vim.fn.getcurpos()[2] + 1
  vim.api.nvim_win_set_cursor(0, { linenum, 0 })
end
vim.api.nvim_create_user_command("NoRank", noRank, {})
