local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt

local function node_maker(num)
  num = tonumber(num)
  if num == nil then
    return {}      -- return an empty table if the input is not a number
  end
  local nodes = {} -- this table will store all the dynamic nodes
  for x = 1, num do
    -- create a snippet node for each line and append it to the nodes table
    nodes[x] = i(x, 'X RUN {} B ' .. (900 + x) .. ' OFF')
  end
  return nodes
end

ls.add_snippets("all", {
  ls.parser.parse_snippet({ trig = "dynamicLines" }, "{${1:8}}", node_maker(4))
})

ls.add_snippets("eiffel", {
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
})

local function same(index)
  return f(function(arg)
    return arg[1]
  end, { index })
end

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
