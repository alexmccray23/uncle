-- Neovim plugin for adding the indent "&IN2" command on long labels in Uncle


local function indent()
  local copy = vim.api.nvim_get_current_line()
  local string = vim.split(copy, ";", { plain = true })[1]
  string = vim.fn.substitute(string, "^R\\s\\+\\|\\&&UT-", "", "g")
  string = vim.fn.substitute(string, "\\/\\/", "/", "g")
  if #string > 26 then
    if copy:match("%&UT-") then
      if string:gmatch("%(D/S") and #string % 26 > 0 and #string % 26 < 4 then
        copy = copy:gsub(" %(D//S", "/(D//S")
      elseif string:gmatch("D/S") and #string % 26 > 0 and #string % 26 < 3 then
        copy = copy:gsub(" D//S", "/D//S")
      end
    elseif #string > 27 and string:sub(1,4) ~= "&IN2" then
      local pattern = "^(R%s+)(.*)"
      if string:match("^%d") then
        copy = copy:gsub(pattern, "%1&IN2 %2", 1)
      else
        copy = copy:gsub(pattern, "%1&IN2%2", 1)
      end
    end
  end
  vim.api.nvim_set_current_line(copy)
  local nline = vim.fn.line('.')
  vim.api.nvim_win_set_cursor(0, { nline + 1, 0 })
end
vim.api.nvim_create_user_command("In2", indent, {})
