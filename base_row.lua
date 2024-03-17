-- Neovim plugin for adding the 'TOTAL BASE' row in Uncle tables
local function baseRow()
  local base = "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP"
  vim.fn.append(vim.fn.line('.') - 1, base)
end
vim.api.nvim_create_user_command("BaseRow", baseRow, {})
