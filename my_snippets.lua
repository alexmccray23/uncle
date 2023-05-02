local ls = require("luasnip")
local snip = ls.snippet
local insert = ls.insert_node
local text = ls.text_node
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
    text {") NOSZR", "R"},
  }),
})

