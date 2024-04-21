-- Neovim plugin for adding and removing zero-padding

local M = {}

function M.menu()
  local choices = {
    { label = "1. Add Zero-Padding", func = M.add },
    { label = "2. Remove Zero-Padding", func = M.remove },
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

-- Only adding for case IDs for now
function M.add()
    vim.cmd([[%s/\(\s*\)\(\d\+\)/\=printf('%09d', submatch(2))]])
end


-- Only removing for case IDs for now
function M.remove()
    vim.cmd([[%s/\(0*\)\([1-9][0-9]*\)/\=printf("%9d", submatch(2))]])
end

vim.api.nvim_create_user_command("ZeroPad", M.menu, {})

return M
