-- Neovim plugin for adding excecutable tablew (900-1000+) to Uncle tables

local M = {}


function M.loadExec()
  local fullPath = vim.split(vim.fn.expand("%:p"), "/", { plain = true })
  local projNumber = fullPath[6]
  local input = vim.fn.input("Combined data? [y] or [n]")
  local file = nil
  if input:match("[yY]") then
    file = "COMB.FIN"
  elseif input:match("[nN]") then
    file = "P" .. projNumber .. ".FIN"
  end
  local text = { "*",
    "********************************************************************************",
    "*",
    "TABLE 500",
    "X ENTER 500 NOADD",
    "X SH 'MD C:\\TEMP'",
    "X SH 'COPY ..\\DATA\\" .. file .. " C:\\TEMP'",
    "X LOAD CHAR REP FROM 'C:\\TEMP\\" .. file .. ".FIN'",
    "X SH 'DEL C:\\TEMP\\" .. file .. "'",
    "*",
    "********************************************************************************",
    "*" }
  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + 11, 0 })
end

function M.weightExec()
  local fullPath = vim.split(vim.fn.expand("%:p"), "/", { plain = true })
  local projName = vim.split(fullPath[#fullPath], ".", { plain = true })
  Data = {}
  table.remove(fullPath, #fullPath)
  local layFile = vim.fn.glob(table.concat(fullPath, "/") .. "/*.[Ll][Aa][Yy]")
  local layout = vim.fn.readfile(layFile)
  local lastCol = vim.split(layout[#layout], " +", { plain = false, trimempty = true })[3]
  local layName = vim.split(layFile, "/", { plain = true })
  local input = vim.fn.input("Starting column? (Last column in " .. layName[#layName] .. " is " .. lastCol .. ")")
  local proj = projName[1]
  local text = {
    "*************************           WEIGHTING           ************************",
    "*",
    "TABLE 600",
    "X ENTER NOADD",
    "X SH 'DEL " .. proj .. ".C'",
    "X WEIGHT UNWEIGHT",
    "X SET OUT FILE '" .. proj .. ".WT' OFF",
    "X WEIGHT 601 TO 1!" .. input .. ":" .. input + 6 .. " 4 OFF",
    "X SET OUT FILE '" .. proj .. ".WT' CLOSE",
    "X PUNCH CHAR",
    "*",
    "********************************************************************************",
    "*" }
  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + 11, 0 })
end

function M.banner(arg)
  --local footer = ""
  local footer = "F &CP P U B L I C   O P I N I O N   S T R A T E G I E S"
  if arg == nil then
    return
  elseif arg == 1 then
    footer = "F &CP P U B L I C   O P I N I O N   S T R A T E G I E S"
  elseif arg == 2 then
    footer = "F &CP HART RESEARCH ASSOCIATES//PUBLIC OPINION STRATEGIES"
  elseif arg == 3 then
    footer = "F &CP N M B   R E S E A R C H"
  elseif arg == 4 then
    footer = "F &CP N E W   B R I D G E   S T R A T E G Y"
  elseif arg == 5 then
    footer = "F &CP B U R T O N   R E S E A R C H   A N D   S T R A T E G I E S"
  else
    return
  end

  local input = vim.fn.input("Banner number?")
  local text = { "TABLE " .. vim.fn.str2nr(input) + 900 .. "",
    "T /BANNER " .. input .. "",
    "O FORMAT 27 6 1 0 PDP 0 PCTS ZCELL '-' ZPACELL '-' SZR",
    "C &CETOTAL;ALL;COLW 5",
    footer,
    "*" }
  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + 5, 0 })
end

function M.stubExec()
end

function M.testExec()
end

function M.checkExec()
end

function M.finalExec()
end

function M.excelExec()
end

-- ...and so on for the rest of your functions
function M.menu()
  local choices = {
    { label = "1. Table 500",    func = M.loadExec },
    { label = "2. Weight Table", func = M.weightExec },
    { label = "3. Banner",       func = M.submenu },
    { label = "4. Stub Ex",      func = M.stubExec },
    { label = "5. Test Ex",      func = M.testExec },
    { label = "6. Check Ex",     func = M.checkExec },
    { label = "7. Final Ex",     func = M.finalExec },
    { label = "8. Excel Tables", func = M.excelExec },
    -- ...and so on for the rest of your functions
  }
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

function M.submenu(arg)
  local sub_choices = {
    { label = "3.1. POS Footer",    args = arg, func = M.banner },
    { label = "3.2. NBC Footer",    args = arg, func = M.banner },
    { label = "3.3. NMB Footer",    args = arg, func = M.banner },
    { label = "3.4. NBS Footer",    args = arg, func = M.banner },
    { label = "3.5. Burton Footer", args = arg, func = M.banner },
  }

  print(" ")
  print(" ")
  for _, choice in ipairs(sub_choices) do
    print(choice.label)
  end
  local input = tonumber(vim.fn.input("Select a submenu option: "))
  if input and input >= 1 and input <= #sub_choices then
    sub_choices[input].func()
  else
    print("Invalid selection")
  end
end

vim.api.nvim_create_user_command("T500", M.menu, {})

return M