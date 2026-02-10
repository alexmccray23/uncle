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
require "user.uncle.nets2"
require "user.uncle.norank"
require "user.uncle.noprint"
require "user.uncle.noweight"
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
require "user.uncle.sum_init2"
require "user.uncle.summary_setup"
require "user.uncle.sum2_setup"
require "user.uncle.t1001"
require "user.uncle.tab_columns"
require "user.uncle.titles"
require "user.uncle.titles2"
require "user.uncle.text2tab"
require "user.uncle.uncle_syntax"
require "user.uncle.underline"
require "user.uncle.weight_product"
require "user.uncle.weight_sum"
require "user.uncle.weight_tables"
require "user.uncle.teledb"
require "user.uncle.zero_pad"

local function nmap(keys, func, desc)
  vim.api.nvim_set_keymap("n", keys, func, { noremap = true, silent = true, desc = desc })
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "uncle", "text"},
  callback = function()
    nmap("<leader>a", ':lua require("user.uncle.adjust2").menu()<CR>', "Uncle: [A]djust banners")
    nmap("<leader>cc", ':lua require("user.uncle.cw_count").getColumnWidth()<CR>', "Uncle: [C]olumn [C]ount")
    nmap("<leader>vb", ':lua require("user.uncle.vbase").vBaseWrapper()<CR>', "Uncle: VBase")
    nmap("<leader>hb", ':lua require("user.uncle.hbase").hBaseWrapper()<CR>', "Uncle: HBase")
    nmap("<leader>cw", ':lua require("user.uncle.colw").colwWrapper()<CR>', "Uncle: Colw")
    nmap("<leader>ds", ":DiffScore<CR>", "Uncle: [D]ifference [S]core")
    nmap("<leader>in", ':lua require("user.uncle.indent").indent()<CR>', "Uncle: Indent")

    nmap("<leader>k", ':lua require("user.uncle.uncle_syntax2").process_uncle_syntax()<CR>', "Uncle: QX-1 syntax")
    nmap("<leader>j", ':lua require("user.uncle.uncle_syntax2").combined_fix()<CR>', "Uncle: QX:1 syntax")
    -- nmap("<leader>k", ':lua require("user.uncle.uncle_syntax").uncleSyntax()<CR>', "Uncle: QX-1 syntax")
    -- nmap("<leader>j", ':lua require("user.uncle.uncle_syntax").combFix()<CR>', "Uncle: QX:1 syntax")

    nmap("<leader>ii", ':lua require("user.uncle.in2").indent()<CR>', "Uncle: &IN2")
    nmap("<leader>bc", ':lua require("user.uncle.banner_column").bannerColumn()<CR>', "Uncle: Insert [B]anner [C]olumns")
    nmap("<leader>rr", ':lua require("user.uncle.r_row").rRow()<CR>', "Uncle: Insert R Row")
    nmap("<leader>u", ':lua require("user.uncle.underline").underline()<CR>', "Uncle: Underline")
    nmap("<leader>sp", ':lua require("user.uncle.space1").space1()<CR>', "Uncle: Space 1")
    nmap("<leader>sz", ':lua require("user.uncle.noszr").noszr()<CR>', "Uncle: Noszr")
    nmap("<leader>np", ':lua require("user.uncle.noprint").noPrint()<CR>', "Uncle: No print")
    nmap("<leader>nr", ':lua require("user.uncle.norank").noRank()<CR>', "Uncle: No rank")
    nmap("<leader>nw", ':lua require("user.uncle.noweight").noWeight()<CR>', "Uncle: No weight")
    nmap("<leader>sc", ':lua require("user.uncle.state_fips").stateFips()<CR>', "Uncle: [S]tate (FIPS) [C]ode")
    nmap("<leader>tt", ':lua require("user.uncle.t1001").testTables()<CR>', "Uncle: [T]est [T]ables")
    nmap("<leader>or", ":Rank<CR>", "Uncle: O Rank")
    nmap("<leader>sbb", ":SplitBase<CR>", "Uncle: Split Base")
    nmap("<leader>sbk", ":SplitBaseKGS<CR>", "Uncle: Split Base (KGS)")
    nmap("<leader>si", ":SumInit<CR>", "Uncle: Summmary initialize")
    nmap("<leader>br", ":BaseRow<CR>", "Uncle: Base Row")
    nmap("<leader>nn", ":Nets<CR>", "Uncle: [N]ets")
    nmap("<leader>qr", ":QualRow<CR>", "Uncle: [Q]ualifier [R]ow")
    nmap("<leader>rn", ":Renumber<CR>", "Uncle: [R]e[N]umber")
    nmap("<leader>wp", ":WeightProduct<CR>", "Uncle: Weight Product")
    nmap("<leader>ws", ":WeightSum<CR>", "Uncle: Weight Sum")
    nmap("<leader>wt", ":WeightTables<CR>", "Uncle: Weight Tables")
    nmap("<leader>x", ":T500<CR>", "Uncle: e[X]ecutable tables")
  end
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "bigfile", "text"},
  callback = function()
    nmap("<leader>bk", ':BaseCheck<CR>', "Uncle: [B]aseChec[k]")
  end
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "rfl",
  callback = function()
    nmap("<leader>sa", ':lua require("user.uncle.state_abbv").stateAbbv()<CR>', "Uncle: [State [A]bbreviation")
  end
})

nmap("<leader>ic", ":InitClean<CR>", "Uncle: Initial Cleanup")
nmap("<leader>t2t", ":Text2tab<CR>", "Uncle: Text-to-tab")
nmap("<leader>ld", ":Teledb<CR>", "Uncle: [L]ookup [D]atabase")
nmap("<leader>zp", ':lua require("user.uncle.zero_pad").wrapper()<CR>', "Uncle: [Z]ero [P]ad")
    nmap("<leader>tc", ":TabCol<CR>", "Uncle: Columnize tab-delimited text")
