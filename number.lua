-- Neovim plugin for numbering Uncle tables
local function numberTables()

  local start = vim.fn.input("Number to count from? [PRESS ENTER TO START AT 1]: ")
  local last = vim.fn.input("\nNumber to stop at? [PRESS ENTER FOR INDEFINITE]: ")

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
    if last ~= "" and line:match("TABLE " .. cutoff) then
<<<<<<< HEAD
<<<<<<< HEAD
=======
      vim.fn.search('^TABLE.\\+', 'b')
>>>>>>> 961d716 (Adding vbase.lua, hbase.lua and noszr.lua)
=======
      vim.fn.search('^TABLE.\\+', 'b')
>>>>>>> 961d716 (Adding vbase.lua, hbase.lua and noszr.lua)
      break
    end
    local new_line = vim.fn.substitute(line, '.*', 'TABLE ' .. count, "")
    vim.api.nvim_set_current_line(new_line)
    local linenum = vim.fn.getcurpos()[2]
    vim.api.nvim_win_set_cursor(0, { linenum, 6 })
    count = count + 1
  end
end
vim.api.nvim_create_user_command("Renumber", numberTables, {})
