-- Neovim plugin for adding split sample qualifiers and base labels

local M = {}

function M.splitBase()
  local sample = vim.fn.input("Which split sample? (A, B, C, 'D,F', etc) "):upper():gsub(",", "//")
  local choices = {
    { case = "A",    question = "VERSION",  code = "1" },
    { case = "B",    question = "VERSION",  code = "2" },
    { case = "C",    question = "VERSION2", code = "3" },
    { case = "D",    question = "VERSION2", code = "4" },
    { case = "E",    question = "VERSION2", code = "5" },
    { case = "F",    question = "VERSION2", code = "6" },
    { case = "C//E", question = "VERSION2", code = "3,5" },
    { case = "D//F", question = "VERSION2", code = "4,6" },
    { case = "G",    question = "VERSION3", code = "7" },
    { case = "H",    question = "VERSION3", code = "8" },
    { case = "I",    question = "VERSION3", code = "9" },
  }
  for i, _ in ipairs(choices) do
    if sample == choices[i]['case'] then
      local case = choices[i]['case']
      local question = choices[i]['question']
      local code = choices[i]['code']
      local column = M.getColumns(question)
      M.replaceText(column, code, case)
      break
    end
  end
end

function M.getColumns(question)
  local column = nil
  local layDir = vim.split(vim.fn.expand("%:p"), "/", { plain = true })
  table.remove(layDir, #layDir)
  local fullPath = table.concat(layDir, "/") .. "/*.[Ll][Aa][Yy]"
  local temp = vim.fn.glob(fullPath, false, true)
  local layout = vim.fn.readfile(temp[#temp])
  for _, value in ipairs(layout) do
    if value:match(question) then
      column = vim.split(value, ' +', { plain = false, trimempty = true })[2]
      break
    end
  end
  return column
end

function M.replaceText(column, code, case)
  local start_line = vim.fn.getcurpos()[2]
  local sample = ""
  if #case > 1 then sample = "SAMPLES" else sample = "SAMPLE" end
  local text = {
    string.format("Q 1!%s-%s", column, code),
    string.format("R &IN2BASE==%s %s;ALL;HP NOVP", sample, case)
  }
  vim.api.nvim_buf_set_lines(0, start_line - 1, start_line + 1, false, text)
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
end

vim.api.nvim_create_user_command("SplitBase", M.splitBase, {})

return M
