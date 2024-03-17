-- Neovim plugin that formats numeric scales in Uncle
local wholeText = {}
local new_cols = nil
local input = nil
local M = {}

function M.menu()
  local choices = {
    "1. 1-10 Scale",
    "2. 0-10 Scale",
    "3. 1-100 Scale",
    "4. 0-100 Scale",
    "5. Miscellaneous",
  }
  for _, choice in ipairs(choices) do
    print(choice)
  end
  input = tonumber(vim.fn.input("Select an option: "))
  if input and input >= 1 and input <= #choices then
    return M.submenu()
  else
    print(" ")
    print("Invalid selection")
  end
end

function M.submenu()
  local choices = {
    {
      "1. 10/8-10/4-7/1-3",
      "2. 10/8-10/5-7/1-4",
    },
    {
      "1. 10/8-10/4-7/0-3",
      "2. 10/8-10/5-7/0-4",
    },
    {
      "1. 100/80-100/51-79/50/1-49",
      "2. 100/80-100/50-79/1-49",
    },
    {
      "1. 100/80-100/51-79/50/0-49",
      "2. 100/80-100/50-79/0-49",
    },
    {
      "1. ABA consumption",
    },
  }
  print(" ")
  for _, choice in ipairs(choices[input]) do
    print(choice)
  end
  input = input * 10 + tonumber(vim.fn.input("Select an option: "))
  if input % 10 >= 1 and input % 10 <= #choices[(input - (input % 10)) / 10] then
    M.scale()
  else
    print(" ")
    print("Invalid selection")
  end
end

function M.scale()
  M.getFormat()
  M.getColumnsRest()
  M.replaceOld()
end

function M.getFormat()
  if input == 11 then
    wholeText = {
      "R 10&UT-;R(1!X:Y,10)",
      "R 8-10&UT-;R(1!X:Y,8:10)",
      "R 4-7&UT-;R(1!X:Y,4:7)",
      "R 1-3&UT-;R(1!X:Y,1:3)",
      "R   9;R(1!X:Y,9)",
      "R   8;R(1!X:Y,8)",
      "R   7;R(1!X:Y,7)",
      "R   6;R(1!X:Y,6)",
      "R   5;R(1!X:Y,5)",
      "R   4;R(1!X:Y,4)",
      "R   3;R(1!X:Y,3)",
      "R   2;R(1!X:Y,2)",
      "R   1;R(1!X:Y,1)",
      "R DON'T KNOW//REFUSED;R(1!X:Y,99)",
      "R /&DFMEAN;A(X:Y), R(1!X:Y,1:10);FDP 1",
      "R MEDIAN;PC(X:Y, 50), R(1!X:Y,1:10);FDP 1",
    }
  elseif input == 12 then
    wholeText = {
      "R 10&UT-;R(1!X:Y,10)",
      "R 8-10&UT-;R(1!X:Y,8:10)",
      "R 5-7&UT-;R(1!X:Y,5:7)",
      "R 1-4&UT-;R(1!X:Y,1:4)",
      "R   9;R(1!X:Y,9)",
      "R   8;R(1!X:Y,8)",
      "R   7;R(1!X:Y,7)",
      "R   6;R(1!X:Y,6)",
      "R   5;R(1!X:Y,5)",
      "R   4;R(1!X:Y,4)",
      "R   3;R(1!X:Y,3)",
      "R   2;R(1!X:Y,2)",
      "R   1;R(1!X:Y,1)",
      "R DON'T KNOW//REFUSED;R(1!X:Y,99)",
      "R /&DFMEAN;A(X:Y), R(1!X:Y,1:10);FDP 1",
      "R MEDIAN;PC(X:Y, 50), R(1!X:Y,1:10);FDP 1",
    }
  elseif input == 21 then
    wholeText = {
      "R 10&UT-;R(1!X:Y,10)",
      "R 8-10&UT-;R(1!X:Y,8:10)",
      "R 4-7&UT-;R(1!X:Y,4:7)",
      "R 0-3&UT-;R(1!X:Y,0:3)",
      "R   9;R(1!X:Y,9)",
      "R   8;R(1!X:Y,8)",
      "R   7;R(1!X:Y,7)",
      "R   6;R(1!X:Y,6)",
      "R   5;R(1!X:Y,5)",
      "R   4;R(1!X:Y,4)",
      "R   3;R(1!X:Y,3)",
      "R   2;R(1!X:Y,2)",
      "R   1;R(1!X:Y,1)",
      "R   0;R(1!X:Y,0)",
      "R DON'T KNOW//REFUSED;R(1!X:Y,99)",
      "R /&DFMEAN;A(X:Y), R(1!X:Y,0:10);FDP 1",
      "R MEDIAN;PC(X:Y, 50), R(1!X:Y,0:10);FDP 1",
    }
  elseif input == 22 then
    wholeText = {
      "R 10&UT-;R(1!X:Y,10)",
      "R 8-10&UT-;R(1!X:Y,8:10)",
      "R 5-7&UT-;R(1!X:Y,5:7)",
      "R 0-4&UT-;R(1!X:Y,0:4)",
      "R   9;R(1!X:Y,9)",
      "R   8;R(1!X:Y,8)",
      "R   7;R(1!X:Y,7)",
      "R   6;R(1!X:Y,6)",
      "R   5;R(1!X:Y,5)",
      "R   4;R(1!X:Y,4)",
      "R   3;R(1!X:Y,3)",
      "R   2;R(1!X:Y,2)",
      "R   1;R(1!X:Y,1)",
      "R   0;R(1!X:Y,0)",
      "R DON'T KNOW//REFUSED;R(1!X:Y,99)",
      "R /&DFMEAN;A(X:Y), R(1!X:Y,0:10);FDP 1",
      "R MEDIAN;PC(X:Y, 50), R(1!X:Y,0:10);FDP 1",
    }
  elseif input == 31 then
    wholeText = {
      "R 100;R(1!X:Y,100)",
      "R 80-100;R(1!X:Y,80:100)",
      "R 51-79;R(1!X:Y,51:79)",
      "R 50;R(1!X:Y,50)",
      "R 1-49;R(1!X:Y,1:49)",
      "R DON'T KNOW//REFUSED;R(1!X:Y,99)",
      "R /&DFMEAN;A(X:Y), R(1!X:Y,0:10);FDP 1",
      "R MEDIAN;PC(X:Y, 50), R(1!X:Y,0:10);FDP 1",
    }
  elseif input == 32 then
    wholeText = {
      "R 100;R(1!X:Y,100)",
      "R 80-100;R(1!X:Y,80:100)",
      "R 50-79;R(1!X:Y,50:79)",
      "R 1-49;R(1!X:Y,1:49)",
      "R DON'T KNOW//REFUSED;R(1!X:Y,99)",
      "R /&DFMEAN;A(X:Y), R(1!X:Y,0:10);FDP 1",
      "R MEDIAN;PC(X:Y, 50), R(1!X:Y,0:10);FDP 1",
    }
  elseif input == 41 then
    wholeText = {
      "R 100;R(1!X:Y,100)",
      "R 80-100;R(1!X:Y,80:100)",
      "R 51-79;R(1!X:Y,51:79)",
      "R 50;R(1!X:Y,50)",
      "R 0-49;R(1!X:Y,0:49)",
      "R DON'T KNOW//REFUSED;R(1!X:Y,99)",
      "R /&DFMEAN;A(X:Y), R(1!X:Y,0:10);FDP 1",
      "R MEDIAN;PC(X:Y, 50), R(1!X:Y,0:10);FDP 1",
    }
  elseif input == 42 then
    wholeText = {
      "R 100;R(1!X:Y,100)",
      "R 80-100;R(1!X:Y,80:100)",
      "R 50-79;R(1!X:Y,50:79)",
      "R 0-49;R(1!X:Y,0:49)",
      "R DON'T KNOW//REFUSED;R(1!X:Y,99)",
      "R /&DFMEAN;A(X:Y), R(1!X:Y,0:10);FDP 1",
      "R MEDIAN;PC(X:Y, 50), R(1!X:Y,0:10);FDP 1",
    }
  elseif input == 51 then
    wholeText = {
      "R 1-2;R(1!X:Y,0:2);VBASE 1",
      "R 3-6;R(1!X:Y,3:6);VBASE 1",
      "R 7-10;R(1!X:Y,7:10);VBASE 1",
      "R 11+&UT-;R(1!X:Y,11:500);VBASE 1",
      "R   11-14;R(1!X:Y,11:14);VBASE 1",
      "R   15+;R(1!X:Y,15:500);VBASE 1",
      "R DON'T KNOW//REFUSED;R(1!X:Y,999);VBASE 1",
      "R -------------;NULL",
      "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP",
      "R 1-2;R(1!X:Y,0:2)",
      "R 3-6;R(1!X:Y,3:6)",
      "R 7-10;R(1!X:Y,7:10)",
      "R 11+&UT-;R(1!X:Y,11:500)",
      "R   11-14;R(1!X:Y,11:14)",
      "R   15+;R(1!X:Y,15:500)",
      "R DON'T KNOW//REFUSED;R(1!X:Y,999)",
      "*",
      "R / /&DFMEAN;A(1!X:Y), R(1!X:Y,0:150) NOT(R(1!1:9,0));FDP 1",
      "R MEDIAN;PC(1!X:Y, 50), R(1!X:Y,0:150) NOT(R(1!1:9,0));FDP 1 SPACE 1",
    }
  end
  return wholeText
end

function M.getColumnsRest()
  vim.fn.search('^R &IN2BASE==', 'b')
  vim.fn.search('^R \\w', 'W')
  local new_line = vim.api.nvim_get_current_line()
  local pattern =
  "\\(.\\+;\\)\\(R\\?(\\?1\\?!\\?\\|A\\?(\\?1\\?!\\?\\|PC\\?(\\?1\\?!\\?\\)\\(.\\{-}\\)\\(,\\|-\\)\\(.\\+\\)"
  new_cols = vim.fn.substitute(new_line, pattern, "\\3", "")
  return new_cols
end

function M.replaceOld()
  local new_lines = {}
  vim.fn.search('^TABLE', 'b')
  vim.fn.search('^R &IN2BASE==', 'W')
  local nline = vim.fn.getcurpos()[2] + 1
  vim.api.nvim_win_set_cursor(0, { nline, 0 })
  local eline = vim.fn.search('\\*\\n', 'W')
  for index, line in ipairs(wholeText) do
    new_lines[index] = vim.fn.substitute(line, "X:Y", new_cols, "g")
  end
  vim.api.nvim_buf_set_lines(0, nline - 1, eline - 1, false, new_lines)
end

vim.api.nvim_create_user_command("Scale", M.menu, {})

return M
