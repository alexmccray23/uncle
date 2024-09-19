-- Neovim plugin for adding and removing zero-padding

-- NOTE: Generic command if zero-padding quotas (if last column...)
-- '<,'>s/\d\+$/\=printf('%03d', submatch(0))

local M = {}

function M.menu()
  local choices = {
    { label = "1. Add Zero-Padding (caseid)", func = M.add },
    { label = "2. Remove Zero-Padding (caseid)", func = M.remove },
    { label = "3. Add Zero-Padding (first occurence)", func = M.wrapper },
  }
  for _, choice in ipairs(choices) do
    print(choice.label)
  end
  local input = tonumber(vim.fn.input "Select an option: ")
  if input and input >= 1 and input <= #choices then
    choices[input].func()
  else
    print " Invalid selection"
  end
end

-- wrapper function for generic zero-padding
function M.wrapper()
  local value = vim.fn.input "How many zeros? "
  if value ~= "" then
    M.add_generic(value)
  end
end

function M.add_generic(value)
  local count = vim.v.count ~= 0 and vim.v.count or 1
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for _ = 1, count do
    local sort_cmd = string.format("s/\\d\\+$/\\=printf('%%0%dd', submatch(0))", value)
    vim.api.nvim_exec2(sort_cmd, {})

    --vim.api.nvim_set_current_line(new_line)
    local next_line = current_line + 1
    vim.api.nvim_win_set_cursor(0, { next_line, 0 })

    current_line = next_line
  end
end

-- Only adding for case IDs for now
function M.add()
  vim.cmd [[%s/\(\s*\)\(\d\+\)/\=printf('%09d', submatch(2))]]
end

-- Only removing for case IDs for now
function M.remove()
  vim.cmd [[%s/\(0*\)\([1-9][0-9]*\)/\=printf("%9d", submatch(2))]]
end

vim.api.nvim_create_user_command("ZeroPad", M.wrapper, {})

return M
