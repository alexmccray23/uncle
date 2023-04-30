-- Neovim plugin for numbering Uncle tables
local function numberTables()

  local start = vim.fn.input("Enter the number to count from: [PRESS ENTER TO START AT 1]\n")
  local last = vim.fn.input("\nEnter the number to count to: [PRESS ENTER FOR INDEFINITE]\n")

  local count = 1
  local cutoff = 2
  if start ~= "" then
    count = vim.fn.str2nr(start)
  end
  if last ~= "" then
    cutoff = vim.fn.str2nr(last)
  end

  while true do
    local flag = vim.fn.search('^TABLE.\\+', 'W')
    if flag == 0 then
      break
    end
    local line = vim.api.nvim_get_current_line()
    local new_line = vim.fn.substitute(line, '.*', 'TABLE ' .. count, "")
    vim.api.nvim_set_current_line(new_line)
    local linenum = vim.fn.getcurpos()[2]
    vim.api.nvim_win_set_cursor(0, { linenum, 6 })
    count = count + 1
    if count > cutoff and last ~= "" then
      break
    end
  end
end
vim.api.nvim_create_user_command("Renumber", numberTables, {})
