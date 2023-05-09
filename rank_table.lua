-- Neovim plugin for adding the O RANK RANKPCT row in Uncle tables
local function rankRow()
  local base = "O RANK RANKPCT"
  vim.fn.append(vim.fn.line('.') - 1, base)
end
vim.api.nvim_create_user_command("Rank", rankRow, {})
