-- Neovim plugin for adding a qualifier (Q) row and renamed base row in Uncle
local function qualifierRow()
  local input = vim.fn.input "Question skip logic?: "
  if input == "" then return end
  print " "
  local label = vim.fn.input("New base row label?: "):upper()
  if label == "" then return end
  local line = vim.fn.line "."
  vim.fn.append(vim.fn.line "." - 1, "R ;" .. input)
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  vim.cmd [[USyntax
            normal k]]
  local qualifier = vim.split(vim.api.nvim_get_current_line(), ";")[2]
  vim.cmd [[normal dd]]
  local text = {
    "Q " .. qualifier,
    "R &IN2BASE==" .. label .. ";ALL;HP NOVP",
  }

  vim.fn.search("^R &IN2BASE==", "bc")
  local line_num = vim.fn.line "."

  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, text)
  vim.api.nvim_win_set_cursor(0, { line_num, 0 })
end
vim.api.nvim_create_user_command("QualRow", qualifierRow, {})
