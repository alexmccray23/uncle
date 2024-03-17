-- Shortcut regex to convert VD text files to tab delimited ones.

local function text2tab()
  vim.cmd([[%s/\s*\(\d\+\) \(\S\+\)\s\+\(.*\)/\1\t\2\t\3]])
end
vim.api.nvim_create_user_command("Text2tab", text2tab, {})
