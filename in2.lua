-- Neovim plugin for adding the indent "&IN2" command on long labels in Uncle

local M = {}

function M.indent()
  -- Set the count to 1 if there is no count given.
  local count = vim.v.count ~= 0 and vim.v.count or 1
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for _ = 1, count do
    local copy = vim.api.nvim_get_current_line()
    local string = vim.split(copy, ";", { plain = true })[1]
    string = vim.fn.substitute(string, "^R \\|\\&&UT-", "", "g")
    string = vim.fn.substitute(string, "\\/\\/", "/", "g")
    if #string > 26 then
      if copy:match("%&UT-") then
        if string:match("%(D/S") and #string % 26 > 0 and #string % 26 < 4 then
          copy = copy:gsub(" %(D//S", "/(D//S")
        elseif string:match("D/S") and #string % 26 > 0 and #string % 26 < 3 then
          copy = copy:gsub(" D//S", "/D//S")
        end
      elseif #string > 27 and not string:match("&IN2") then
        local pattern = "^(R%s+)(.*)"
        if string:match("^(%s*)%d") then
          copy = copy:gsub(pattern, "%1&IN2 %2", 1)
        else
          copy = copy:gsub(pattern, "%1&IN2%2", 1)
        end
      end
    end
    vim.api.nvim_set_current_line(copy)
    local next_line = current_line + 1
    vim.api.nvim_win_set_cursor(0, { next_line, 0 })

    -- Go to the next line
    current_line = next_line
  end
end

vim.api.nvim_create_user_command("In2", M.indent, {})

return M
