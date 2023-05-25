-- Neovim plugin for converting POS specs to the format used by other Uncle plugins

M = {}

function M.posSpecConversion()
  local count = vim.v.count ~= 0 and vim.v.count or 1
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for _ = 1, count do
    local line = vim.split(vim.api.nvim_get_current_line(), ';', { plain = true })
    local revised = vim.fn.substitute(line[2], "\\s*$\\|\\<Q\\|& \\|AND ", "", "g")
    if revised:sub(1, 1) == "(" and revised:sub(#revised) == ")" then
      revised = vim.fn.substitute(revised, "^(\\|)$", "", "g")
    end
    revised = vim.fn.substitute(revised, ":", "#", "g")
    revised = vim.fn.substitute(revised, "-", ":", "g")
    revised = vim.fn.substitute(revised, "#", "-", "g")
    line[2] = revised
    local new_line = table.concat(line, ";")
    vim.api.nvim_set_current_line(new_line)

    local next_line = current_line + 1
    vim.api.nvim_win_set_cursor(0, { next_line, 0 })

    current_line = next_line
  end
end

vim.api.nvim_create_user_command("SpecFix", M.posSpecConversion, {})

return M
