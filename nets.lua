-- Neovim plugin for adding nets to Uncle tables

local M = {}

function M.one()
  vim.cmd("normal ds")
end

function M.two()
  local punches = {}
  local start_line = vim.fn.getcurpos()[2] - 1
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  local end_line = start_line + 2
  local text = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  for index,line in ipairs(text) do
    punches[index] = vim.split(line, ';', { plain = true })
    punches[index][1] = vim.fn.substitute(punches[index][1], "^R\\s\\+\\(TOTAL \\)\\?", "", "")
    punches[index][1] = vim.fn.substitute(punches[index][1], "&IN2\\|&UT-", "", "")
  end
  local new_line = "R &IN2**D//S (" .. punches[1][1] .. " - " .. punches[2][1] .. ");NONE;EX(RD1-RD2) NOSZR"
  vim.fn.append(vim.fn.line('.'), new_line)
  vim.api.nvim_win_set_cursor(0, { start_line + 2, 0 })
end

function M.three()
end

function M.four()
end

function M.five()
end

function M.six_one()
end

function M.six_two()
end

function M.seven()
end

-- ...and so on for the rest of your functions
function M.menu()
  local choices = {
    { label = "1. Generic 2-Way D/S", func = M.one },
    { label = "2. 2-Way D/S",         func = M.two },
    { label = "3. Generic Net",       func = M.three },
    { label = "4. 4-Way D/S",         func = M.four },
    { label = "5. 1-2 MINUS 4-5",     func = M.five },
    { label = "6. 6-Way D/S",         func = M.six_one },
    --{ label = "61. Leaners w/ Total", func = M.six_one },
    --{ label = "62. Leaner w/ Indep/Undecided", func = M.six_two },
    { label = "7. Education",         func = M.seven },
    -- ...and so on for the rest of your functions
  }
  local choice_num = 1
  for _, choice in ipairs(choices) do
    print(choice.label)
  end
  local input = tonumber(vim.fn.input("Select an option: "))
  if input and input >= 1 and input <= #choices then
    choices[input].func()
  else
    print(" Invalid selection")
  end
end

vim.api.nvim_create_user_command("Nets", M.menu, {})

return M
