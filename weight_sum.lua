-- Neovim plugin for summing weighting table values
local function weightAdd()
  local start_line = vim.fn.getcurpos()[2]
  local end_line = vim.fn.search("^\\*", "W")
  local text = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  local sum = 0
  for _, value in ipairs(text) do
    value = string.sub(vim.split(value, ";", { plain = true })[3], 7)
    sum = sum + value
  end
  print("Weighting sum: " .. sum)
end
vim.api.nvim_create_user_command("WeightSum", weightAdd, {})
