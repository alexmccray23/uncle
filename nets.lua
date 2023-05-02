-- Neovim plugin for adding nets to Uncle tables

local M = {}

function M.one()
  local ls = require("luasnip")
  local s = ls.snippet
  local i = ls.insert_node
  local t = ls.text_node
  --local snippets = {
  --  s("punch_code", {
  --    t("R &IN2**D//S ("),
  --    t({ "" }, { name = "punch_1" }),
  --    t(" - "),
  --    t({ "" }, { name = "punch_2" }),
  --    t(");NONE;EX(RD1-RD2) NOSZR"),
  --  }),
  --}
  ls.snippets = {
    all = {
      ls.parser.parse_snippet("ds", "R &IN2**D//S ($1 - $2);NONE;EX(RD$3-RD$0) NOSZR"),
    },
  }
  --return snippets
end
  
function M.two()
end

function M.three()
end

function M.four()
end

function M.five()
end

function M.six_one()
end

function M.six_two()
end

function M.seven()
end

-- ...and so on for the rest of your functions
function M.menu()
  local choices = {
    { label = "1. Generic 2-Way D/S", func = M.one },
    { label = "2. 2-Way D/S",         func = M.two },
    { label = "3. Generic Net",       func = M.three },
    { label = "4. 4-Way D/S",         func = M.four },
    { label = "5. 1-2 MINUS 4-5",     func = M.five },
    { label = "6. 6-Way D/S",         func = M.six_one },
    --{ label = "61. Leaners w/ Total", func = M.six_one },
    --{ label = "62. Leaner w/ Indep/Undecided", func = M.six_two },
    { label = "7. Education",         func = M.seven },
    -- ...and so on for the rest of your functions
  }
  local choice_num = 1
  for _, choice in ipairs(choices) do
    print(choice.label)
  end
  local input = tonumber(vim.fn.input("Select an option: "))
  if input and input >= 1 and input <= #choices then
    choices[input].func()
  else
    print(" Invalid selection")
  end
end

vim.api.nvim_create_user_command("Nets", M.menu, {})

return M
