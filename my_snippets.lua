local ls = require("luasnip")
local snip = ls.snippet
local sn = ls.snippet_node
local insert = ls.insert_node
local text = ls.text_node
local choice = ls.choice_node

ls.add_snippets("all", {
  snip("ds", {
    text "R &IN2**D//S (",
    insert(1, "PUNCH1"),
    text " - ",
    insert(2, "PUNCH1"),
    text ");NONE;EX(RD",
    insert(3, "1"),
    text "-RD",
    insert(0, "2"),
    text { ") NOSZR", "R" }
  }),
  snip("select case", {
    text "SELECT CASE ",
    choice(1, {
      text "VAL(MID$(A$, ",
      sn(nil, {insert(1, "COL"), text "MID$(A$, " }),
    })
  })
})

local function parseLayout()
  Data = {}
  local layDir = vim.split(vim.fn.expand("%:p"), "/", { plain = true })
  table.remove(layDir, #layDir)
  local fullPath = table.concat(layDir, "/") .. "/*.[Ll][Aa][Yy]"
  local temp = vim.fn.glob(fullPath, false, true)
  local layout = vim.fn.readfile(temp[#temp])
  for _, value in ipairs(layout) do
    local column = vim.split(value, ' +', { plain = false, trimempty = true })
    Data[column[1]] = {
      startCol = tonumber(column[2]),
      endCol = tonumber(column[3]),
      nfield = tonumber(column[5]),
      wfield = tonumber(column[6])
    }
  end
end
