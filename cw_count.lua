-- Neovim plugin for displaying banner column width information

local M = {}

function M.copyTable()
  local current_line = vim.fn.getcurpos()[2]
  local start_line = vim.fn.search("\\_^TABLE ", 'b')
  local end_line = vim.fn.search('^\\*\\n\\|F \\&CP', 'W')
  local wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  vim.api.nvim_win_set_cursor(0, { current_line, 0 })
  return wholeText
end

function M.getColumnWidth()
  local wholeText = M.copyTable()
  local o_colw = nil
  local colw = nil
  local sum = 0
  for _, line in ipairs(wholeText) do
    if line:match("O FORMAT") then
      o_colw = line:gsub("^(O FORMAT 27 )(%d)(.*)", "%2")
      o_colw = tonumber(o_colw)
    elseif line:match("^C %&CE") then
      local line_split = vim.split(line, ";", { plain = true })
      if #line_split > 2 and line_split[3]:match("COLW %d") then
        colw = line_split[3]:gsub("(.*)(COLW )(%d)(.*)", "%3")
        colw = tonumber(colw)
        sum = sum + colw + 1
      else
        sum = sum + o_colw + 1
      end
    end
  end
  local diff = vim.fn.abs(sum - 148)
  local char = nil
  if diff == 1 then char = "character" else char = "characters" end
  if sum > 148 then
    print(string.format("Too wide by %d %s", diff, char))
  else
    print(string.format("Fits with %d %s to spare", diff, char))
  end
end

vim.api.nvim_create_user_command("BannerWidth", M.getColumnWidth, {})

return M
