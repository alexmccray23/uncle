-- Neovim plugin for adding excecutable tables (500-1000+) to the Uncle E file

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
  local footer = nil
  if arg == 1 then
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
  vim.api.nvim_win_set_cursor(0, { nline + 4, 0 })
end

function M.stubExec()
  local tableNum = {}
  local title = vim.fn.input("\nHeader title\n")
  local date = vim.fn.input("\nField dates (year will be included)\n")
  --TODO: source year from filepath
  local year = "2023"
  local project = vim.fn.input("\nProject number\n")
  if title == "" or date == "" or year == "" or project == "" then
    return
  end
  local eFile = vim.fn.readfile(vim.fn.expand("%:p"))

  local index = 1
  for _, value in ipairs(eFile) do
    if value:match("^TABLE %d+") then
      tableNum[index] = value:gsub("^TABLE (%d+)", "%1")
      tableNum[index] = vim.fn.str2nr(tableNum[index])
      index = index + 1
    end
  end
  local end1 = nil
  local start2 = nil
  local end2 = nil
  local range
  for i, value in ipairs(tableNum) do
    if value == 100 or value == 101 then
      if tableNum[i - 1] < value - 1 then
        end1 = tableNum[i - 1]
        start2 = value
      end
    end
    if value > 100 and end1 == nil then
      if tableNum[i] - tableNum[i - 1] > 1 then
        end1 = tableNum[i - 1]
      end
    end
    if value == 500 then
      for j = i - 1, 1, -1 do
        if tableNum[j] < 200 then
          end2 = tableNum[j]
          break
        end
      end
    end
  end
  if start2 == nil then
    range = end1
  else
    range = end1 .. " " .. start2 .. " TH " .. end2
  end

  local text = {
    "TABLE 1000",
    "X ENTER NOADD",
    "X SET PLINE 175",
    "X SET PAGE 82",
    "X WEIGHT UNWEIGHT",
    "X JOBT '&CP " .. title .. " // " .. project .. " // " .. date .. ", " .. year .. " &RJ PAGE &PS  '",
    "X SET TITLE '&CP STUB TABLES'",
    "X SET OUT FILE '" .. project .. ".STB' OFF",
    "X RUN 1 TH " .. range .. " B 900 PAGE 1 OFF",
    "X SET TITLE OFF",
    "X SET OUT FILE '" .. project .. ".STB' CLOSE ",
    "*" }
  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + 12, 0 })
end

function M.testExec()
  local text = {}
  local count = vim.fn.input("\nHow many banner tables?\n")

  local end_line = vim.fn.getcurpos()[2] + 1
  local start_line = vim.fn.search('^TABLE 1000', 'b')
  local wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  vim.api.nvim_win_set_cursor(0, { end_line - 1, 0 })
  for _, line in ipairs(wholeText) do
    line = line:gsub("TABLE 1000", "TABLE 1001")
    line = line:gsub("STUB", "TEST")
    line = line:gsub(".STB", ".TST")
    line = line:gsub("X RUN 1.*", "X RUN  B 901 PAGE 1 OFF")
    table.insert(text, line)
    if line:match("X RUN") then
      for i = 2, count do
        table.insert(text, "X RUN  B " .. 900 + i .. " OFF")
      end
    end
  end
  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + 9, 6 })
end

function M.checkExec()
  local text = {}

  local test_end = vim.fn.getcurpos()[2] + 1
  local stub_start = vim.fn.search('^TABLE 1000', 'b')
  local stub_end = vim.fn.search('^TABLE 1001', 'W')
  local stubText = vim.api.nvim_buf_get_lines(0, stub_start - 1, stub_end - 1, false)

  local testText = vim.api.nvim_buf_get_lines(0, stub_end, test_end - 1, false)
  vim.fn.search('^X WEIGHT \\d\\{3\\}', 'w')
  local wt_line = vim.api.nvim_get_current_line()
  vim.api.nvim_win_set_cursor(0, { test_end - 1, 0 })
  local bans = {}
  wt_line = wt_line:match("1!%d+:%d+")
  for _, line in ipairs(stubText) do
    if not line:match("X SET TITLE '&CP STUB TABLES'") then
      line = line:gsub("TABLE 1000", "TABLE 1002")
      line = line:gsub(".STB", ".CHK")
      line = line:gsub("X WEIGHT UNWEIGHT", "X IF(ALL) CWEIGHT(F" .. wt_line .. ")")
      if line:match("900 PAGE 1") then
        for _, v in ipairs(testText) do
          if v:match("X RUN") then
            v = v:gsub(".-(9%d%d ).*", "%1")
            table.insert(bans, v)
          end
        end
        table.insert(text, "X RUN 1 B " .. bans[1] .. "TH " .. bans[#bans] .. "PAGE 1 OFF")
      end
      line = line:gsub("X RUN 1", "X RUN 2")
      line = line:gsub("900", "901")
      line = line:gsub("PAGE 1 ", "")
      table.insert(text, line)
    end
  end
  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + 12, 0 })
end

function M.finalExec()
  local text = {}
  local end_line = vim.fn.getcurpos()[2] + 1
  local start_line = vim.fn.search('^TABLE 1002', 'b')
  local wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  local bans = ""
  vim.api.nvim_win_set_cursor(0, { end_line - 1, 0 })
  for _, line in ipairs(wholeText) do
    line = line:gsub("TABLE 1002", "TABLE 1003")
    line = line:gsub("CHK", "FIN")
    line = line:gsub("X RUN 2", "X RUN 1")
    if line:match(".*(B 901 TH.*)") then
      bans = line:gsub(".*(B 901 TH.*)", "%1")
    else
      line = line:gsub("(X RUN 1 TH %d+ ).*", "%1" .. bans)
      table.insert(text, line)
    end
  end
  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + 11, 0 })
end

function M.excelExec()
  local text = {}
  local tableNum = vim.fn.input({ prompt = "\nTable number: ", default = "1006" })
  local cursor_start = vim.fn.getcurpos()[2] + 1
  local start_line = vim.fn.search('^TABLE 1003', 'b')
  vim.fn.search('.F[IN]\\(N\\|\\d\\)', 'W')
  local end_line = vim.fn.search('.F[IN]\\(N\\|\\d\\)', 'W')
  local wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  vim.api.nvim_win_set_cursor(0, { cursor_start - 1, 0 })
  local label = ""
  for i, line in ipairs(wholeText) do
    line = line:gsub("TABLE 1003", "TABLE " .. tableNum)
    if vim.fn.match(line, "\\.F[IN]\\(N\\|\\d\\)") >= 0 then
      label = vim.fn.substitute(line, ".* '\\(\\d\\+\\)\\.F[IN]\\(N\\|\\d\\).*", "\\1", "")
      goto continue
    end
    line = line:gsub("PAGE 1 OFF", "EXC(NAME '" .. label .. "_Banners' SHEET 'Data' TC COMB REP FIT 7) TCONE")
    if i < 3 or i > 4 then
      table.insert(text, line)
    end
    ::continue::
  end
  table.insert(text, "*")
  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + 7, 0 })
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
  local input = tonumber(vim.fn.input("Select a banner footer option: "))
  if input and input >= 1 and input <= #sub_choices then
    sub_choices[input].func(input)
  else
    print("Invalid selection")
  end
end

vim.api.nvim_create_user_command("T500", M.menu, {})

return M
