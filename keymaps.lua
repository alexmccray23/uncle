require "user.uncle.adjust"
require "user.uncle.banner_column"
require "user.uncle.base_check"
require "user.uncle.base_row"
require "user.uncle.combine"
require "user.uncle.cw_count"
require "user.uncle.diff_score"
require "user.uncle.executables"
require "user.uncle.generation"
require "user.uncle.in2"
require "user.uncle.indent"
require "user.uncle.init_clean"
require "user.uncle.layout"
require "user.uncle.nets"
require "user.uncle.norank"
require "user.uncle.number"
require "user.uncle.pos_spec_conversion"
require "user.uncle.qualifier_row"
require "user.uncle.r_row"
require "user.uncle.rank_table"
require "user.uncle.region"
require "user.uncle.rfl"
require "user.uncle.series"
require "user.uncle.scale"
require "user.uncle.skip"
require "user.uncle.split_base"
require "user.uncle.state_abbv"
require "user.uncle.state_fips"
require "user.uncle.sum_init"
require "user.uncle.summary_setup"
require "user.uncle.t1001"
require "user.uncle.titles"
require "user.uncle.text2tab"
require "user.uncle.uncle_syntax"
require "user.uncle.underline"
require "user.uncle.weight_product"
require "user.uncle.weight_sum"
require "user.uncle.weight_tables"
require "user.uncle.teledb"

local keymap = vim.api.nvim_set_keymap
keymap("n", "<leader>cc", ':lua require("user.uncle.cw_count").getColumnWidth()<CR>', { noremap = true, silent = true, desc = "Uncle: [C]olumns [C]ount" })
keymap("n", "<leader>vb", ':lua require("user.uncle.vbase").vBaseWrapper()<CR>', { noremap = true, silent = true, desc = "Uncle: VBase" })
keymap("n", "<leader>hb", ':lua require("user.uncle.hbase").hBaseWrapper()<CR>', { noremap = true, silent = true, desc = "Uncle: HBase" })
keymap("n", "<leader>cw", ':lua require("user.uncle.colw").colwWrapper()<CR>', { noremap = true, silent = true, desc = "Uncle: Colw" })
keymap("n", "<leader>ds", ":DiffScore<CR>", { noremap = true, silent = true, desc = "Uncle: [D]ifference [S]core" })
keymap("n", "<leader>in", ':lua require("user.uncle.indent").indent()<CR>', { noremap = true, silent = true, desc = "Uncle: Indent" })
keymap("n", "<leader>k", ':lua require("user.uncle.uncle_syntax").uncleSyntax()<CR>', { noremap = true, silent = true, desc = "Uncle: QX-1 syntax" })
keymap("n", "<leader>j", ':lua require("user.uncle.uncle_syntax").combFix()<CR>', { noremap = true, silent = true, desc = "Uncle: QX:1 syntax" })
keymap("n", "<leader>ii", ':lua require("user.uncle.in2").indent()<CR>', { noremap = true, silent = true, desc = "Uncle: &IN2" })
keymap("n", "<leader>bc", ':lua require("user.uncle.banner_column").bannerColumn()<CR>', { noremap = true, silent = true, desc = "Uncle: Insert [B]anner [C]olumns" })
keymap("n", "<leader>rr", ':lua require("user.uncle.r_row").rRow()<CR>', { noremap = true, silent = true, desc = "Uncle: Insert R Row" })
keymap("n", "<leader>u", ':lua require("user.uncle.underline").underline()<CR>', { noremap = true, silent = true, desc = "Uncle: Underline" })
keymap("n", "<leader>sp", ':lua require("user.uncle.space1").space1()<CR>', { noremap = true, silent = true, desc = "Uncle: Space 1" })
keymap("n", "<leader>sz", ':lua require("user.uncle.noszr").noszr()<CR>', { noremap = true, silent = true, desc = "Uncle: Noszr" })
keymap("n", "<leader>p", ':lua require("user.uncle.norank").noRank()<CR>', { noremap = true, silent = true, desc = "Uncle: No rank" })
keymap("n", "<leader>vb", ':lua require("user.uncle.vbase").vBaseWrapper()<CR>', { noremap = true, silent = true, desc = "Uncle: No rank" })
keymap("n", "<leader>sa", ':lua require("user.uncle.state_abbv").stateAbbv()<CR>', { noremap = true, silent = true, desc = "Uncle: [State [A]bbreviation" })
keymap("n", "<leader>sc", ':lua require("user.uncle.state_fips").stateFips()<CR>', { noremap = true, silent = true, desc = "Uncle: [S]tate (FIPS) [C]ode" })
keymap("n", "<leader>tt", ':lua require("user.uncle.t1001").testTables()<CR>', { noremap = true, silent = true, desc = "Uncle: [T]est [T]ables" })
keymap("n", "<leader>or", ":Rank<CR>", { noremap = true, silent = true, desc = "Uncle: O Rank" })
keymap("n", "<leader>sb", ":SplitBase<CR>", { noremap = true, silent = true, desc = "Uncle: Split Base" })
keymap("n", "<leader>si", ":SumInit<CR>", { noremap = true, silent = true, desc = "Uncle: Summmary initialize" })
keymap("n", "<leader>br", ":BaseRow<CR>", { noremap = true, silent = true, desc = "Uncle: Base Row" })
keymap("n", "<leader>ic", ":InitClean<CR>", { noremap = true, silent = true, desc = "Uncle: Initial Cleanup" })
keymap("n", "<leader>n", ":Nets<CR>", { noremap = true, silent = true, desc = "Uncle: [N]ets" })
keymap("n", "<leader>qr", ":QualRow<CR>", { noremap = true, silent = true, desc = "Uncle: [Q]ualifier [R]ow" })
keymap("n", "<leader>rn", ":Renumber<CR>", { noremap = true, silent = true, desc = "Uncle: [R]e[N]umber" })
keymap("n", "<leader>t2t", ":Text2tab<CR>", { noremap = true, silent = true, desc = "Uncle: Text-to-tab" })
keymap("n", "<leader>wp", ":WeightProduct<CR>", { noremap = true, silent = true, desc = "Uncle: Weight Product" })
keymap("n", "<leader>ws", ":WeightSum<CR>", { noremap = true, silent = true, desc = "Uncle: Weight Sum" })
keymap("n", "<leader>wt", ":WeightTables<CR>", { noremap = true, silent = true, desc = "Uncle: Weight Tables" })
keymap("n", "<leader>ld", ':Teledb<CR>', { noremap = true, silent = true, desc = "Uncle: [L]ookup [D]atabase" })
