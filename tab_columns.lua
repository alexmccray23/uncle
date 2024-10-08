-- Convert tab-delimited text to a fixed-width columnized format

local function text2tab()
  vim.cmd [[sil %s/\t/|/g
    sil normal gg
    set nowrap]]
  vim.api.nvim_exec2(".,$!column -s '|' -t", {})
end
vim.api.nvim_create_user_command("TabCol", text2tab, {})
