
local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>n', ':lua require("user.uncle.indent").indent()<CR>', { noremap = true, silent = true, desc = "Uncle: Indent" })
keymap('n', '<leader>ds', ':DiffScore<CR>', { noremap = true, silent = true, desc = "Uncle: Difference score" })
keymap('n', '<leader>k', ':lua require("user.uncle.uncle_syntax").uncleSyntax()<CR>', { noremap = true, silent = true, desc = "Uncle: QX-1 syntax" })
keymap('n', '<leader>j', ':lua require("user.uncle.uncle_syntax").combFix()<CR>', { noremap = true, silent = true, desc = "Uncle: QX:1 syntax" })
keymap('n', '<leader>i', ':lua require("user.uncle.in2").indent()<CR>', { noremap = true, silent = true, desc = "Uncle: &IN2" })
keymap('n', '<leader>bc', ':lua require("user.uncle.banner_column").bannerColumn()<CR>', { noremap = true, silent = true, desc = "Uncle: Insert banner columns" })
keymap('n', '<leader>rr', ':lua require("user.uncle.r_row").rRow()<CR>', { noremap = true, silent = true, desc = "Uncle: Insert R Row" })
keymap('n', '<leader>u', ':lua require("user.uncle.underline").underline()<CR>', { noremap = true, silent = true, desc = "Uncle: Underline" })
keymap('n', '<leader>p', ':lua require("user.uncle.norank").noRank()<CR>', { noremap = true, silent = true, desc = "Uncle: No rank" })
keymap('n', '<leader>si', ':SumInit<CR>', { noremap = true, silent = true, desc = "Uncle: Summmary initialize" })
