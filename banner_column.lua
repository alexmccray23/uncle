-- Neovim plugin for adding "C &CE" in the banners

local M = {}

function M.bannerColumn()
  local count = vim.v.count ~= 0 and vim.v.count or 1
  local line = vim.fn.line('.')
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for _ = 1, count do
    local line = vim.api.nvim_get_current_line()
    line = vim.fn.substitute(line, [[^\s\{2,}\|^\t\+]], "", "")
    line = vim.fn.substitute(line, [[\s\{2,}\|\t\+]], ";", ""):upper()
    line = line:gsub("/", "//")
    local new_line = line
    if not line:match("C &CE") then new_line = "C &CE" .. line end
    vim.api.nvim_set_current_line(new_line)
    local next_line = current_line + 1
    vim.api.nvim_win_set_cursor(0, { next_line, 0 })

    current_line = next_line
  end
  vim.api.nvim_win_set_cursor(0, { line, 0 })
end

vim.api.nvim_create_user_command("BannerCol", M.bannerColumn, {})

return M
