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

local function node_maker(num)
  num = tonumber(num)
  num = 5
  if num == nil then
    return {}      -- return an empty table if the input is not a number
  end
  local nodes = {} -- this table will store all the dynamic nodes
  for x = 1, num do
    -- create a snippet node for each line and append it to the nodes table
    --nodes[x] = 'i(' .. x .. ', X RUN {} B ' .. (900 + x) .. ' OFF),'
    --nodes[x] = t('X RUN {} B ' .. (900 + x) .. ' OFF')
    nodes[x] = t "testing"
  end
  return sn(nil, nodes)
end

ls.add_snippets("all", {
  s("nodes", {
    d(1, node_maker(5)[1])
  })
})


local rec_ls
rec_ls = function()
  return sn(
    nil,
    c(1, {
      -- Order is important, sn(...) first would cause infinite loop of expansion.
      t(""),
      sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
    })
  )
end


ls.add_snippets("all", {
  -- rec_ls is self-referencing. That makes this snippet 'infinite' eg. have as many
  -- \item as necessary by utilizing a choiceNode.
  s("ls", {
    t({ "\\begin{itemize}", "\t\\item " }),
    i(1),
    d(2, rec_ls, {}),
    t({ "", "\\end{itemize}" }),
  }),
}, {
  key = "tex",
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
