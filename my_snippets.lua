local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local parse = require("luasnip.util.parser").parse_snippet
local extras = require("luasnip.extras")
local l = extras.lambda


local function same(index)
  return f(function(arg)
    return arg[1]
  end, { index })
end

ls.add_snippets("uncle", {
  s("ds", {
    t "R &IN2**D//S (",
    i(1, "PUNCH1"),
    t " - ",
    i(2, "PUNCH1"),
    t ");NONE;EX(RD",
    i(3, "1"),
    t "-RD",
    i(4, "2"),
    t { ") NOSZR", "R" }
  }),
  s("a(1",
      fmt([[A(1!{}), R(1!{},{});FDP {}]],
        {
          i(1), same(1), i(2), i(3)
        })
    ),
  s("pc(1",
    fmt([[PC(1!{}, 50), R(1!{},{});FDP {}]],
      {
        i(1), same(1), i(2), i(3)
      })
    ),
})

ls.add_snippets("basic", {
  s("select case",
    c(1, {
      fmt([[
          SELECT CASE {}
            CASE {}: MID$(A$, {}, {}) = "{}"
          END SELECT
        ]],
        {
          i(1), i(2), i(3), i(4), i(5)
        }),
      fmt([[
          SELECT CASE VAL(MID$(A$, 1, 9))
            CASE {}
              PRINTCASE = 0
          END SELECT
        ]],
        {
          i(1)
        }),
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
  ),
  s("val",
    fmt([[VAL(MID$({}$, {}, {})) {}]],
      {
        i(1, "A"), i(2), i(3), i(0)
      })
  ),
  s("mid",
    c(1, {
      fmt([[MID$({}$, {}, {}) {}]],
        {
          i(1, "A"), i(2), i(3), i(0)
        }),
      fmt([[MID$({}$, {}, {}) = LEFT$("{}", {} - LEN(LTRIM$(MID$({}$, {}, {})))) + LTRIM$(MID$({}$, {}, {})) {}]],
        {
          i(1, "A"), i(2), i(3), i(4, "00"), same(3), same(1), same(2), same(3), same(1), same(2), same(3), i(0)
        })
    })
  ),
  s("open",
    fmt([[OPEN "{}" FOR {} AS {}]],
      {
        i(1), i(2, "OUTPUT"), i(3)
      })
  ),
})
