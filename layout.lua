-- Layout reformatting plugin 
function LayoutReformat()
  vim.cmd([[normal gg5dd
            %s/^\s\+\(\S\+\s\+\)\(SYS VAR\|SELECT\|NUM\|VARIABLE\)\(\s\+\)\(\S\+\s\+\)\(\S\+\s\+\)\(\S\+\s\+\)\?\(\S\+\s\+\)\(\d\+\s\+\)\(\d\+\)/ \1\8\9 \2\3\4\5\6\7/g
            normal gg]])
end
vim.api.nvim_create_user_command("Layout", LayoutReformat, {})

