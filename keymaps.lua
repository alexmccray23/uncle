
local keymap = vim.api.nvim_set_keymap
keymap('n', '<leader>in', ':lua require("user.uncle.indent").indent()<CR>', { noremap = true, silent = true, desc = "Uncle: Indent" })
keymap('n', '<leader>ds', ':DiffScore<CR>', { noremap = true, silent = true, desc = "Uncle: [D]ifference [S]core" })
keymap('n', '<leader>k', ':lua require("user.uncle.uncle_syntax").uncleSyntax()<CR>', { noremap = true, silent = true, desc = "Uncle: QX-1 syntax" })
keymap('n', '<leader>j', ':lua require("user.uncle.uncle_syntax").combFix()<CR>', { noremap = true, silent = true, desc = "Uncle: QX:1 syntax" })
keymap('n', '<leader>ii', ':lua require("user.uncle.in2").indent()<CR>', { noremap = true, silent = true, desc = "Uncle: &IN2" })
keymap('n', '<leader>bc', ':lua require("user.uncle.banner_column").bannerColumn()<CR>', { noremap = true, silent = true, desc = "Uncle: Insert [B]anner [C]olumns" })
keymap('n', '<leader>rr', ':lua require("user.uncle.r_row").rRow()<CR>', { noremap = true, silent = true, desc = "Uncle: Insert R Row" })
keymap('n', '<leader>u', ':lua require("user.uncle.underline").underline()<CR>', { noremap = true, silent = true, desc = "Uncle: Underline" })
keymap('n', '<leader>p', ':lua require("user.uncle.norank").noRank()<CR>', { noremap = true, silent = true, desc = "Uncle: No rank" })
keymap('n', '<leader>vb', ':lua require("user.uncle.vbase").vBaseWrapper()<CR>', { noremap = true, silent = true, desc = "Uncle: VBase" })
keymap('n', '<leader>hb', ':lua require("user.uncle.hbase").hBaseWrapper()<CR>', { noremap = true, silent = true, desc = "Uncle: HBase" })
keymap('n', '<leader>vb', ':lua require("user.uncle.vbase").vBaseWrapper()<CR>', { noremap = true, silent = true, desc = "Uncle: VBase" })
keymap('n', '<leader>hb', ':lua require("user.uncle.hbase").hBaseWrapper()<CR>', { noremap = true, silent = true, desc = "Uncle: HBase" })
keymap('n', '<leader>sa', ':lua require("user.uncle.state_abbv").stateAbbv()<CR>', { noremap = true, silent = true, desc = "Uncle: [State [A]bbreviation" })
keymap('n', '<leader>sc', ':lua require("user.uncle.state_fips").stateFips()<CR>', { noremap = true, silent = true, desc = "Uncle: [S]tate (FIPS) [C]ode" })
keymap('n', '<leader>tt', ':lua require("user.uncle.t1001").testTables()<CR>', { noremap = true, silent = true, desc = "Uncle: [T]est [T]ables" })
keymap('n', '<leader>or', ':Rank<CR>', { noremap = true, silent = true, desc = "Uncle: O Rank" })
keymap('n', '<leader>sb', ':SplitBase<CR>', { noremap = true, silent = true, desc = "Uncle: Split Base" })
keymap('n', '<leader>si', ':SumInit<CR>', { noremap = true, silent = true, desc = "Uncle: Summmary initialize" })
keymap('n', '<leader>br', ':BaseRow<CR>', { noremap = true, silent = true, desc = "Uncle: Base Row" })
keymap('n', '<leader>ic', ':InitClean<CR>', { noremap = true, silent = true, desc = "Uncle: Initial Cleanup" })
keymap('n', '<leader>n', ':Nets<CR>', { noremap = true, silent = true, desc = "Uncle: [N]ets" })
keymap('n', '<leader>qr', ':QualRow<CR>', { noremap = true, silent = true, desc = "Uncle: [Q]ualifier [R]ow" })
keymap('n', '<leader>t2t', ':Text2tab<CR>', { noremap = true, silent = true, desc = "Uncle: Text-to-tab" })
keymap('n', '<leader>wp', ':WeightProduct<CR>', { noremap = true, silent = true, desc = "Uncle: Weight Product" })
keymap('n', '<leader>ws', ':WeightSum<CR>', { noremap = true, silent = true, desc = "Uncle: Weight Sum" })
keymap('n', '<leader>wt', ':WeightTables<CR>', { noremap = true, silent = true, desc = "Uncle: Weight Tables" })
