-- Neovim plugin for adding "C &CE" in the banners
local function bannerColumn()
  local base = "C &CE"
  vim.fn.append(vim.fn.line('.') - 1, base)
end
vim.api.nvim_create_user_command("BannerCol", bannerColumn, {})
