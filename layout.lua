-- Layout reformatting plugin
function LayoutReformat()
  vim.cmd [[sil normal gg5dd
            sil %s/^\s\+\(\S\+\s\+\)\(sys var\|select\|num\|variable\)\(\s\+\S\+\s\+\S\+\s\+\)\(\S\+\s\+\)\?\(\S\+\s\+\)\(\d\+\s\+\)\(\d\+\)/ \1\6\7 \2\3\4\5/g
            sil normal gg]]
end
vim.api.nvim_create_user_command("Layout", LayoutReformat, {})
