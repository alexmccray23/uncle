-- Neovim plugin for recalculating partial weighting table values

local function weight_product()
  local product = tonumber(vim.fn.input("Multiply values by what?\n"))
  local start_line = vim.fn.getcurpos()[2]
  local end_line = vim.fn.search('^\\*', 'W')
  local text = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  local sum = 0
  local new_text = {}
  for _, line in ipairs(text) do
    local value = string.sub(vim.split(line, ";", { plain = true })[3], 6)
    local new_value = value * product
    line = line:gsub(value, new_value):gsub("0%.", " .")
    table.insert(new_text, line)
    sum = sum + new_value
  end
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line + -1, false, new_text)
  vim.api.nvim_win_set_cursor(0, { end_line, 0 })
  print("", "\nNew weighting sum: " .. sum)
end
vim.api.nvim_create_user_command("WeightProduct", weight_product, {})
