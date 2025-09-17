-- Neovim plugin that formats a question series in Uncle
local count = 1
local wholeText = {}
local orig_cols = ""
local new_cols = ""

local function tableSeries()
  local totTables = tonumber(vim.fn.input "How many tables in series?: ")
  if totTables == nil then
    return
  else
    count = totTables - 1
  end

  local function getFormat()
    vim.fn.search("^TABLE", "b")
    vim.fn.search("^R &IN2BASE==", "W")
    local start_line = vim.fn.getcurpos()[2] + 1
    vim.api.nvim_win_set_cursor(0, { start_line, 0 })
    local end_line = vim.fn.search("\\*\\n", "W")
    wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
    return wholeText
  end

  local function getColumnsFirst()
    vim.fn.search("^R &IN2BASE==", "b")
    vim.fn.search("^R \\w", "W")
    local orig_line = vim.api.nvim_get_current_line()
    local pattern = [[\(.\+;\s\?\)\(R\?(\?1\?!\?\|A\?(\?1\?!\?\|PC\?(\?1\?!\?\)\(.\{-}\)\(,\|-\|=\)\(.\+\)]]
    orig_cols = vim.fn.substitute(orig_line, pattern, "\\3", "")
    return orig_cols
  end

  local function getColumnsRest()
    vim.fn.search("^R &IN2BASE==", "W")
    vim.fn.search("^R \\w", "W")
    local new_line = vim.api.nvim_get_current_line()
    local pattern = [[\(.\+;\s\?\)\(R\?(\?1\?!\?\|A\?(\?1\?!\?\|PC\?(\?1\?!\?\)\(.\{-}\)\(,\|-\|=\)\(.\+\)]]
    new_cols = vim.fn.substitute(new_line, pattern, "\\3", "")
    return new_cols
  end

  local function replaceOld()
    local new_lines = {}
    vim.fn.search("^TABLE", "b")
    vim.fn.search("^R &IN2BASE==", "W")
    local nline = vim.fn.getcurpos()[2] + 1
    vim.api.nvim_win_set_cursor(0, { nline, 0 })
    local eline = vim.fn.search("\\*\\n", "W")
    for index, line in ipairs(wholeText) do
      new_lines[index] = vim.fn.substitute(line, orig_cols, new_cols, "g")
    end
    vim.api.nvim_buf_set_lines(0, nline - 1, eline - 1, false, new_lines)
  end

  getFormat()
  getColumnsFirst()

  for _ = 1, count do
    getColumnsRest()
    replaceOld()
  end
end
vim.api.nvim_create_user_command("Series", tableSeries, {})
