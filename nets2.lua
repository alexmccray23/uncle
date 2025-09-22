-- Refactored Neovim plugin for adding nets to Uncle tables

local M = {}

-- Global variables for commonly used patterns and regex
local PATTERNS = {
  punch_extract = [[\(.*\)\(-\|,\|=\)\(\d\+\)\()\?\)]],
  r_prefix_clean = [[^R\s\+\(\S\+\s\)\?]],
  r_prefix_clean_word = [[^R\s\+\(\w\+\s\)\?]],
  formatting_clean = [[&IN2\|&UT-]],
}

-- Global substitution mappings for label transformations
local LABEL_SUBSTITUTIONS = {
  four_way = {
    positive = {
      { [[^ALWAYS]], [[ALWAYS//SOMETIMES]] },
      { [[^GREAT DEAL]], [[GREAT DEAL//SOME]] },
      { [[^LOT]], [[A LOT//SOME]] },
    },
    negative = {
      { [[^RARELY]], [[RARELY//NEVER]] },
      { [[^TOO\|^VERY]], [[NOT]] },
      { [[^MUCH\|NOT MUCH]], [[NOT MUCH//NOTHING]] },
      { [[^THAT]], [[NOT]] },
      { [[^LITTLE]], [[LITTLE//NOT AT ALL]] },
    },
    special = {
      condition = [[NOT DESCRIBE WELL]],
      positive_sub = { [[^VERY]], [[DESCRIBES]] },
      negative_sub = { [[^NOT]], [[DOESN'T]] },
    },
  },
  income = {
    low = {
      { [[^POOR]], [[POOR//WORKING]] },
      { [[^INCOME]], [[LOW INCOME//WORKING]] },
      { [[^LOW-INCOME]], [[LOW-INCOME//WORKING]] },
    },
    high = {
      { [[^MIDDLE CLASS]], [[UPPER//WELL-TO-DO]] },
      { [[^UPPER-MIDDLE CLASS]], [[UPPER//WELL-TO-DO]] },
    },
  },
}

-- Global education matching patterns
local EDUCATION_PATTERNS = {
  high_school = [[\(GRADUATED HIGH SCHOOL\)\|\(HIGH SCHOOL GRADUATE\)]],
  college = [[\(COLLEGE GRADUATE\)\|\(GRADUATED COLLEGE\)\|\(BACHELOR\)]],
  post_grad = [[\(POST\(-\| \)GRADUATE\)\|\(DOCTOR\)\|\(PROFESSIONAL\)]],
}

-- Helper function: Display menu and get user selection
local function display_menu(choices, prompt, callback)
  local items = {}
  for _, choice in ipairs(choices) do
    table.insert(items, choice.label)
  end

  vim.ui.select(items, {
    prompt = prompt or "Select an option:",
  }, function(choice, idx)
    if choice and idx then
      callback(choices[idx].func, idx)
    end
  end)
end

-- Helper function: Get buffer lines and cursor position
local function get_buffer_context(line_count)
  local start_line = vim.fn.getcurpos()[2] - 1
  vim.api.nvim_win_set_cursor(0, { start_line + 1, 0 })
  local end_line = start_line + line_count
  local text = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  return text, start_line
end

-- Helper function: Process lines and extract punch data
local function process_lines(text, options)
  options = options or {}
  local r_row = {}
  local punches = {}
  local newText = {}

  for i, line in ipairs(text) do
    -- Apply line formatting based on options
    if options.skip_line and i == options.skip_line then
      newText[i] = line
    elseif options.indent_r then
      newText[i] = vim.fn.substitute(line, [[^R ]], [[R   \&IN2]], "")
    else
      newText[i] = vim.fn.substitute(line, [[^R ]], [[R   ]], "")
    end

    -- Split and clean line data
    r_row[i] = vim.split(line, ";", { plain = true })
    local clean_pattern = options.use_word_clean and PATTERNS.r_prefix_clean_word or PATTERNS.r_prefix_clean
    r_row[i][1] = vim.fn.substitute(r_row[i][1], clean_pattern, "", "")
    r_row[i][1] = vim.fn.substitute(r_row[i][1], PATTERNS.formatting_clean, "", "")
    punches[i] = vim.fn.substitute(r_row[i][2], PATTERNS.punch_extract, "\\3", "")
  end

  return r_row, punches, newText
end

-- Helper function: Apply label substitutions
local function apply_label_substitutions(label, substitution_set)
  for _, sub in ipairs(substitution_set) do
    label = vim.fn.substitute(label, sub[1], sub[2], "")
  end
  return label
end

-- Helper function: replace '=' with '-' for nets for when an Uncle e file is generated from an spss .sav file.
local function convert_spss_format(value)
  return value:gsub("=", "-")
end

-- Helper function: Create punch value with range
local function create_punch_value(base_value, start_punch, end_punch)
  local result = vim.fn.substitute(base_value, PATTERNS.punch_extract, string.format([[\1\2%s:%s\4]], start_punch, end_punch), "")
  return convert_spss_format(result)
end

-- Helper function: Create single punch value
local function create_single_punch_value(base_value, punch)
  local result = vim.fn.substitute(base_value, PATTERNS.punch_extract, string.format([[\1\2%s\4]], punch), "")
  return convert_spss_format(result)
end

-- Helper function: Update buffer with new lines
local function update_buffer(newText, start_line, original_count)
  local nline = vim.fn.line "."
  vim.api.nvim_buf_set_lines(0, nline - 1, nline + original_count, false, newText)
  vim.api.nvim_win_set_cursor(0, { nline + 1, 0 })
end

function M.menu()
  local choices = {
    { label = "1. Generic 2-Way D/S", func = M.one },
    { label = "2. 2-Way D/S", func = M.two },
    { label = "3. Generic Net", func = M.three },
    { label = "4. 4-Way D/S", func = M.four },
    { label = "5. 1-2 MINUS 4-5", func = M.five },
    { label = "6. Party D/S", func = M.submenu },
    { label = "7. Education", func = M.seven },
  }
  display_menu(choices, nil, function(func)
    if func then
      func()
    end
  end)
end

function M.submenu()
  local sub_choices = {
    { label = "6.1. Leaners w/ Total", func = M.six_one },
    { label = "6.2. Leaner w/ Indep/Undecided", func = M.six_two },
  }

  display_menu(sub_choices, "Select a submenu option:", function(func)
    if func then
      func()
    end
  end)
end

function M.one()
  local ls = require "luasnip"
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, { cursor[1], 0 })
  local line = vim.api.nvim_get_current_line()
  line = "ds" .. line:sub(2)
  vim.api.nvim_set_current_line(line)
  vim.api.nvim_win_set_cursor(0, { cursor[1], 2 })
  ls.expand "ds"
end

function M.two()
  local text, start_line = get_buffer_context(2)
  local r_row, punches = process_lines(text)

  local new_line = string.format([[R &IN2**D//S (%s - %s);NONE;EX(RD1-RD2) NOSZR]], r_row[1][1], r_row[2][1])
  vim.fn.append(vim.fn.line "." - 1, new_line)
  vim.api.nvim_win_set_cursor(0, { start_line + 2, 0 })
end

function M.three()
  vim.ui.input({
    prompt = "How many rows?: ",
    default = "",
  }, function(rows_input)
    if rows_input == nil then
      return -- User cancelled
    end
    local totRows = tonumber(rows_input)
    if totRows == nil then
      print " Invalid number"
      return
    end

    vim.ui.input({
      prompt = "Row label?: ",
      default = "",
    }, function(label_input)
      if label_input == nil then
        return -- User cancelled
      end
      local label = label_input:upper()
      if label == "" then
        print " Label cannot be empty"
        return
      end

      local start_line = vim.fn.line "."
      local text = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line + totRows - 1, false)
      local r_row, punches, newText = process_lines(text)

      local pValue1 = create_punch_value(r_row[1][2], punches[1], punches[#text])
      table.insert(newText, 1, string.format([[R TOTAL %s&UT-;%s]], label, pValue1))

      local nline = vim.fn.line "."
      vim.api.nvim_buf_set_lines(0, nline - 1, nline + totRows - 1, false, newText)
      vim.api.nvim_win_set_cursor(0, { nline + 1, 0 })
    end)
  end)
end

function M.four()
  local text, start_line = get_buffer_context(4)
  local r_row, punches, newText = process_lines(text)

  local pValue1 = create_punch_value(r_row[1][2], punches[1], punches[2])
  local pValue2 = create_punch_value(r_row[3][2], punches[3], punches[4])

  local pLabel1 = apply_label_substitutions(r_row[1][1], LABEL_SUBSTITUTIONS.four_way.positive)
  local pLabel2 = apply_label_substitutions(r_row[3][1], LABEL_SUBSTITUTIONS.four_way.negative)

  -- Handle special case
  if pLabel2 == LABEL_SUBSTITUTIONS.four_way.special.condition then
    pLabel1 = vim.fn.substitute(pLabel1, LABEL_SUBSTITUTIONS.four_way.special.positive_sub[1], LABEL_SUBSTITUTIONS.four_way.special.positive_sub[2], "")
    pLabel2 = vim.fn.substitute(pLabel2, LABEL_SUBSTITUTIONS.four_way.special.negative_sub[1], LABEL_SUBSTITUTIONS.four_way.special.negative_sub[2], "")
  end

  table.insert(newText, 1, string.format([[R &IN2**D//S (%s - %s);NONE;EX(RD1-RD2) NOSZR]], pLabel1, pLabel2))
  table.insert(newText, 2, string.format([[R TOTAL %s&UT-;%s]], pLabel1, pValue1))
  table.insert(newText, 3, string.format([[R TOTAL %s&UT-;%s]], pLabel2, pValue2))

  update_buffer(newText, start_line, 3)
end

function M.five()
  local text, start_line = get_buffer_context(5)
  local r_row, punches, newText = process_lines(text, { skip_line = 3, use_word_clean = true })

  local pValue1 = create_punch_value(r_row[1][2], punches[1], punches[2])
  local pValue2 = create_punch_value(r_row[4][2], punches[4], punches[5])

  local pLabel1 = apply_label_substitutions(r_row[1][1], LABEL_SUBSTITUTIONS.income.low)
  local pLabel2 = apply_label_substitutions(r_row[4][1], LABEL_SUBSTITUTIONS.income.high)

  table.insert(newText, 1, string.format([[R &IN2**D//S (%s - %s);NONE;EX(RD1-RD2) NOSZR]], pLabel1, pLabel2))
  table.insert(newText, 2, string.format([[R TOTAL %s&UT-;%s]], pLabel1, pValue1))
  table.insert(newText, 3, string.format([[R TOTAL %s&UT-;%s]], pLabel2, pValue2))

  local punch3 = table.remove(newText, 6)
  table.insert(newText, 8, punch3)

  update_buffer(newText, start_line, 4)
end

function M.six_one()
  local text, start_line = get_buffer_context(7)
  local r_row, punches, newText = process_lines(text, { skip_line = 4, indent_r = true })

  local pValue1 = create_punch_value(r_row[1][2], punches[1], punches[3])
  local pValue2 = create_punch_value(r_row[5][2], punches[5], punches[7])

  table.insert(newText, 1, string.format([[R &IN2**D//S (%s - %s);NONE;EX(RD1-RD2) NOSZR]], r_row[1][1], r_row[7][1]))
  table.insert(newText, 2, string.format([[R TOTAL %s&UT-;%s]], r_row[1][1], pValue1))
  table.insert(newText, 3, string.format([[R TOTAL %s&UT-;%s]], r_row[7][1], pValue2))

  local punch3 = table.remove(newText, 7)
  table.insert(newText, 10, punch3)

  update_buffer(newText, start_line, 6)
end

function M.six_two()
  local text, start_line = get_buffer_context(7)
  local r_row, punches, newText = process_lines(text, { indent_r = true })

  local pValue1 = create_punch_value(r_row[1][2], punches[1], punches[2])
  local pValue2 = create_punch_value(r_row[6][2], punches[6], punches[7])
  local pValue3 = create_punch_value(r_row[3][2], punches[3], punches[5])

  table.insert(newText, 1, string.format("R &IN2**D//S (%s-%s);NONE;EX(RD1-RD2) NOSZR", r_row[1][1], r_row[7][1]))
  table.insert(newText, 2, string.format([[R TOTAL %s&UT-;%s]], r_row[1][1], pValue1))
  table.insert(newText, 3, string.format([[R TOTAL %s&UT-;%s]], r_row[7][1], pValue2))
  table.insert(newText, 4, string.format([[R TOTAL LEAN//INDEPENDENT&UT-;%s]], pValue3))

  update_buffer(newText, start_line, 6)
end

function M.seven()
  local text, start_line = get_buffer_context(7)
  local r_row, punches, newText = process_lines(text, { indent_r = true })

  local pValue1, pValue2, pValue3 = "", "", ""
  local hs_end, sc_start, sc_end = nil, nil, nil

  for i, line in ipairs(text) do
    if line:match "DON'T KNOW" or line:match "REFUSED" then
      newText[i] = line
    end

    r_row[i][1] = vim.fn.substitute(r_row[i][1], PATTERNS.formatting_clean, "", "")

    if vim.fn.match(line, EDUCATION_PATTERNS.high_school) >= 0 then
      if i == 1 then
        pValue1 = create_single_punch_value(r_row[i][2], punches[i])
        hs_end = tonumber(punches[i])
      else
        pValue1 = create_punch_value(r_row[i][2], punches[1], punches[i])
        hs_end = tonumber(punches[i])
      end
    elseif vim.fn.match(line, EDUCATION_PATTERNS.college) >= 0 then
      sc_start = hs_end + 1
      sc_end = tonumber(punches[i]) - 1
      if sc_start == sc_end then
        pValue2 = create_single_punch_value(r_row[i][2], tostring(sc_start))
      else
        pValue2 = create_punch_value(r_row[i][2], tostring(sc_start), tostring(sc_end))
      end
    elseif vim.fn.match(line, EDUCATION_PATTERNS.post_grad) >= 0 then
      pValue3 = create_punch_value(r_row[i][2], tostring(sc_end + 1), punches[i])
    end
  end

  table.insert(newText, 1, string.format([[R HIGH SCHOOL OR LESS&UT-;%s]], pValue1))
  table.insert(newText, 2, string.format([[R SOME COLLEGE&UT-;%s]], pValue2))
  table.insert(newText, 3, string.format([[R COLLEGE+&UT-;%s]], pValue3))

  local nline = vim.fn.line "."
  vim.api.nvim_buf_set_lines(0, nline - 1, nline + 6, false, newText)
  vim.api.nvim_win_set_cursor(0, { nline, 0 })
end

vim.api.nvim_create_user_command("Nets2", M.menu, {})

return M
