local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt


ls.add_snippets("eiffel", {
  s("ds", {
    t "R &IN2**D//S (",
    i(1, "PUNCH1"),
    t " - ",
    i(2, "PUNCH1"),
    t ");NONE;EX(RD",
    i(3, "1"),
    t "-RD",
    i(0, "2"),
    t { ") NOSZR", "R" }
  }),
})


ls.add_snippets("basic", {
  s("select case",
    c(1, {
      fmt([[
          SELECT CASE VAL(MID$(A$, {}, {}))
            CASE {}: MID$(A$, {}, {}) = "{}"
          END SELECT
        ]],
        {
          i(1), i(2), i(3), i(4), i(5), i(6)
        }),
      fmt([[
          SELECT CASE MID$(A$, {}, {})
            CASE "{}": MID$(A$, {}, {}) = "{}"
          END SELECT
        ]],
        {
          i(1), i(2), i(3), i(4), i(5), i(6)
        }),
    })
  )
})

