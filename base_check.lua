-- Neovim plugin for checking if any base rows exceed 100%.

local function base_check()
  vim.fn.search([[\(\d\{2\}[1-9]\|\d[1-9]\d\|[2-9]\d\{2\}\)%]], 'w')
end
vim.api.nvim_create_user_command("BaseCheck", base_check, {})
