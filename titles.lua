-- Neovim plugin for shifting banner titles to fit above their columns

local M = {}

function M.titleCopy()
  local titleRowPos = vim.fn.line('.')
  local text = vim.api.nvim_buf_get_lines(0, titleRowPos - 1, titleRowPos, false)
  for _, v in ipairs(text) do
    print(v)
  end
end

vim.api.nvim_create_user_command("Titles", M.titleCopy, {})

return M
