-- Neovim plugin for adding the O RANK RANKPCT row in Uncle tables
local function rankRow()
  local line = vim.fn.line "."
  vim.fn.search("^R &IN2BASE==", "bc")
  local base = "O RANK RANKPCT"
  vim.fn.append(vim.fn.line "." - 1, base)
  vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
end
vim.api.nvim_create_user_command("Rank", rankRow, {})
