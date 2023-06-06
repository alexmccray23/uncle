-- Neovim plugin for adding the underline formatting option

M = {}

function M.underline()
  local count = vim.v.count ~= 0 and vim.v.count or 1
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for _ = 1, count do
    local line = vim.split(vim.api.nvim_get_current_line(), ';', { plain = true })
    if not line[1]:match('%&UT-') then line[1] = line[1] .. "&UT-" end
    local new_line = table.concat(line, ";")
    vim.api.nvim_set_current_line(new_line)

    local next_line = current_line + 1
    vim.api.nvim_win_set_cursor(0, { next_line, 0 })

    current_line = next_line
  end
end

vim.api.nvim_create_user_command("Underline", M.underline, {})

return M
