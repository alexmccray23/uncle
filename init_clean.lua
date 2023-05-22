-- Neovim plugin for initial cleaning of Uncle .E file

local function init_clean()
  vim.cmd([[sil! %s/\(^R \)\(.\+\)/\U\1\2\E/g
        sil! %s/’/'/g
        sil! %s/–\|—\|–/-/g
        sil! %s/…/.../g
        sil! %s/“\|”/"/g
        normal gg
  ]])
end
vim.api.nvim_create_user_command("InitClean", init_clean, {})
