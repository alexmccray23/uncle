-- Neovim plugin for converting POS specs to the format used by other Uncle plugins

local function posSpecConversion()
  local line = vim.split(vim.api.nvim_get_current_line(), ';', { plain = true })
  local revised = vim.fn.substitute(line[2], "\\s*$\\|\\<Q\\|& \\|AND ", "", "g")
  if revised:sub(1,1) == "(" and revised:sub(#revised) == ")" then
    revised = vim.fn.substitute(revised, "^(\\|)$", "", "g")
  end
  revised = vim.fn.substitute(revised, ":", "#", "g")
  revised = vim.fn.substitute(revised, "-", ":", "g")
  revised = vim.fn.substitute(revised, "#", "-", "g")
  line[2] = revised
  local new_line = table.concat(line, ";")
  vim.api.nvim_set_current_line(new_line)
  local linenum = vim.fn.getcurpos()[2] + 1
  vim.api.nvim_win_set_cursor(0, { linenum, 0 })
end
vim.api.nvim_create_user_command("SpecFix", posSpecConversion, {})
vim.keymap.set('n', '<M-d>', posSpecConversion, { desc = "SpecFix" })
