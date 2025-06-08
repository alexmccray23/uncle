-- Neovim plugin that performs initial cleanup of specs used for summary tables (refactored)

local M = {}

-- Lua patterns for line matching
local PATTERNS = {
  question_line = "^Q?%S+",
  question_extract = "^Q?%w+_?%w*",
  indented_with_colon_digit = "^%s+.*%(:%d",
  indented_with_digit_code = "^%s+[%$%%]?%d+%-?%d*",
  indented_with_non_digit = "^%s+.*%(%%D",
}

-- Vim regex patterns for substitution
local VIM_PATTERNS = {
  question_prefix = [[^Q\?\w\+.\?\(\t\+\|\s\+\)]],
  colon_replacement = [[\((:\.*\)]],
  leading_whitespace = [[\(^\t\+\|^\s\+\)]],
  digit_group_capture = [[\(^\t\+\|^\s\+\)\(\$\?\|%\?\)\(\d\+-\?\d*\)]],
  space_before_paren = [[\(\t*\|\s*\)(]],
}

-- Utility functions
local function normalize_whitespace(text)
  return text:gsub("\t+", " ")
end

local function is_question_line(line)
  return line:match(PATTERNS.question_line) ~= nil
end

local function extract_question_id(line)
  return line:match(PATTERNS.question_extract)
end

local function is_indented_colon_digit_line(line)
  return vim.fn.match(line, VIM_PATTERNS.leading_whitespace .. [[\(.*\)(:\d]]) >= 0
end

local function is_indented_digit_code_line(line)
  return vim.fn.match(line, VIM_PATTERNS.digit_group_capture) >= 0
end

local function is_indented_non_digit_line(line)
  return vim.fn.match(line, VIM_PATTERNS.leading_whitespace .. [[\(.*\)(\D]]) >= 0
end

-- Line processing functions
local function process_question_line(line)
  local diff_score = vim.fn.substitute(line, VIM_PATTERNS.question_prefix, "R ", "")
  diff_score = normalize_whitespace(diff_score)
  return diff_score:upper()
end

local function process_colon_digit_line(line, current_question)
  local r_row = vim.fn.substitute(line, VIM_PATTERNS.colon_replacement, "(" .. current_question .. ":", "")
  r_row = vim.fn.substitute(r_row, VIM_PATTERNS.leading_whitespace, "R   ", "")
  r_row = r_row:gsub(" %(", ";(")
  return r_row:upper()
end

local function process_digit_code_line(line, current_question)
  local replacement = string.format([[R   \2\3;(%s:\3)]], current_question)
  local r_row = vim.fn.substitute(line, VIM_PATTERNS.digit_group_capture, replacement, "")
  return r_row:upper()
end

local function process_non_digit_line(line)
  local r_row = vim.fn.substitute(line, VIM_PATTERNS.leading_whitespace, "R   ", "")
  r_row = vim.fn.substitute(r_row, VIM_PATTERNS.space_before_paren, ";(", "")
  return r_row:upper()
end

-- Main processing function
local function process_line(line, current_question)
  if is_question_line(line) then
    local question_id = extract_question_id(line)
    local processed_line = process_question_line(line)
    return processed_line, question_id
  elseif is_indented_colon_digit_line(line) then
    local processed_line = process_colon_digit_line(line, current_question)
    return processed_line, current_question
  elseif is_indented_digit_code_line(line) then
    local processed_line = process_digit_code_line(line, current_question)
    return processed_line, current_question
  elseif is_indented_non_digit_line(line) then
    local processed_line = process_non_digit_line(line)
    return processed_line, current_question
  else
    -- Skip lines that don't match any pattern
    return nil, current_question
  end
end

function M.sum_init()
  local line_num = vim.fn.line "."
  local end_line = vim.fn.search("*\\n", "W") - 1

  if end_line == -1 then
    print "No ending marker found"
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, line_num - 1, end_line, false)
  local new_lines = {}
  local current_question = nil

  for _, line in ipairs(lines) do
    local processed_line, updated_question = process_line(line, current_question)
    current_question = updated_question

    if processed_line then
      table.insert(new_lines, processed_line)
    end
  end

  vim.api.nvim_buf_set_lines(0, line_num - 1, end_line, false, new_lines)
  vim.api.nvim_win_set_cursor(0, { line_num, 0 })
end

-- Legacy compatibility
local function sumInit()
  M.sum_init()
end

vim.api.nvim_create_user_command("SumInit", sumInit, {})

return M
