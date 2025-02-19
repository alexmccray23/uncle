-- Neovim plugin for adding a total base table below the skip base stub

local M = {}

function M.copyTable()
  vim.fn.search("^Q ", "b")
  local start_line = vim.fn.getcurpos()[2]
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  local end_line = vim.fn.search("\\*\\n", "W")
  local text = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  return { text, start_line, end_line }
end

function M.parseTable()
  local text = M.copyTable()[1]
  local skip = {}
  local qual = ""
  for _, line in ipairs(text) do
    if line:match "^Q ." then
      qual = line:gsub("^Q (.*)", "%1")
    elseif line:match "R &IN2BASE==" then
      line = line:gsub(";ALL;", ";" .. qual .. ";")
      table.insert(skip, line)
    else
      local array = vim.split(line, ";", { plain = true })
      if #array == 2 then
        line = line .. ";VBASE 1"
      elseif #array > 2 then
        line = line .. " VBASE 1"
      end
      table.insert(skip, line)
    end
  end
  table.insert(skip, "R -------------;NULL")
  table.insert(skip, "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP")
  for _, line in ipairs(text) do
    if line:match "^R " and not line:match "^R &IN2BASE==" then
      table.insert(skip, line)
    end
  end
  return skip
end

function M.skipBase()
  local text = M.parseTable()
  local start_line = tonumber(M.copyTable()[2])
  local end_line = tonumber(M.copyTable()[3])
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line - 1, false, text)
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
end

vim.api.nvim_create_user_command("Skip", M.skipBase, {})

return M
