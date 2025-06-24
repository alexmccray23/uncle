-- Uncle syntax plugin (refactored)

local M = {}

-- Cache for parsed layout data
local cache = {
  data_table = {},
  check_count = 0,
  buffer_id = nil,
}

-- Constants
local LAYOUT_PATTERNS = { "*.[Ll][Aa][Yy]" }
local COLUMN_SEPARATOR = ";"
local SPEC_SEPARATOR = " +"

-- Utility functions
local function split_line(line, separator, opts)
  return vim.split(line, separator, opts or { plain = true })
end

local function get_current_line_data()
  local buffer = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_get_current_line()
  local parts = split_line(line, COLUMN_SEPARATOR)
  return {
    buffer = buffer,
    line = line,
    parts = parts,
    questions = parts[2],
  }
end

local function find_layout_file()
  local current_file = vim.fn.expand "%:p"
  local dir_parts = split_line(current_file, "/")
  table.remove(dir_parts, #dir_parts)

  local dir_path = table.concat(dir_parts, "/")
  local pattern = dir_path .. "/" .. LAYOUT_PATTERNS[1]

  local files = vim.fn.glob(pattern, false, true)
  if #files == 0 then
    error("Cannot find layout file in current directory: " .. dir_path)
  end

  return files[#files] -- Return the last (most recent) layout file
end

-- Core parsing functions
function M.parse_layout()
  local current_data = get_current_line_data()

  -- Check cache validity
  if cache.check_count > 1 and cache.buffer_id == current_data.buffer then
    return cache.data_table
  end

  -- Reset cache if buffer changed
  if cache.buffer_id ~= current_data.buffer then
    cache.data_table = {}
  end

  local layout_file = find_layout_file()
  local layout_lines = vim.fn.readfile(layout_file)

  local data_table = {}

  for _, line in ipairs(layout_lines) do
    local columns = split_line(line, SPEC_SEPARATOR, { plain = false, trimempty = true })

    if #columns >= 6 then
      local question_id = columns[1]
      data_table[question_id] = {
        start_col = tonumber(columns[2]),
        end_col = tonumber(columns[3]),
        n_field = tonumber(columns[5]),
        w_field = tonumber(columns[6]),
      }
    end
  end

  -- Update cache
  cache.data_table = data_table
  cache.check_count = vim.tbl_count(data_table)
  cache.buffer_id = current_data.buffer

  return data_table
end

function M.parse_spec(questions_string, data_table)
  if not questions_string then
    return {}
  end

  local spec_table = {}
  local normalized_questions = questions_string:upper():gsub(", ", ",")
  local specs = split_line(normalized_questions, SPEC_SEPARATOR, { plain = false, trimempty = true })

  for index, spec_value in ipairs(specs) do
    if spec_value:match "^[oO][rR]$" then
      spec_table[index] = {
        question = "OR",
        code = "OR",
        spec = "OR",
      }
    else
      local clean_spec = vim.fn.substitute(spec_value, [[\([nN][oO][tT]\)\?(\+\|)\+]], "", "")
      local parts = split_line(clean_spec, "-", {})
      local question_num = parts[1]
      local code = parts[2]

      local question_key = nil
      if data_table[question_num] then
        question_key = question_num
      elseif data_table["Q" .. question_num] then
        question_key = "Q" .. question_num
      else
        print(string.format("Cannot find Q%s or %s in layout file", question_num, question_num))
      end

      if question_key then
        spec_table[index] = {
          question = question_key,
          code = code,
          spec = clean_spec,
        }
      end
    end
  end

  return spec_table
end

-- Syntax generation functions
local function generate_single_column_syntax(start_col, code)
  return string.format("1!%d-%s", start_col, code)
end

local function generate_range_syntax(start_col, end_col, code)
  return string.format("1!%d:%d-%s", start_col, end_col, code)
end

local function generate_multi_field_syntax(start_col, end_col, w_field, n_field, code)
  if n_field == 1 then
    return string.format("R(1!%d:%d,%s)", start_col, end_col, code)
  elseif n_field == 2 then
    local first_end = start_col + w_field - 1
    local second_start = end_col - w_field + 1
    return string.format("R(1!%d:%d/1!%d:%d,%s)", start_col, first_end, second_start, end_col, code)
  elseif n_field == 3 then
    local first_end = start_col + w_field - 1
    local second_start = start_col + (2 * (w_field - 1))
    local second_end = start_col + (3 * (w_field - 1))
    local third_start = end_col - w_field + 1
    return string.format("R(1!%d:%d/1!%d:%d/1!%d:%d,%s)", start_col, first_end, second_start, second_end, third_start, end_col, code)
  else
    local first_end = start_col + w_field - 1
    local second_start = start_col + (2 * (w_field - 1))
    local second_end = start_col + (3 * (w_field - 1))
    local last_start = end_col - w_field + 1
    return string.format("R(1!%d:%d/1!%d:%d...1!%d:%d,%s)", start_col, first_end, second_start, second_end, last_start, end_col, code)
  end
end

local function generate_syntax_for_spec(spec_entry, data_table)
  if spec_entry.question == "OR" then
    return nil
  end

  local question_data = data_table[spec_entry.question]
  if not question_data then
    return nil
  end

  local start_col = question_data.start_col
  local end_col = question_data.end_col
  local w_field = question_data.w_field
  local n_field = question_data.n_field
  local code = spec_entry.code

  if w_field == 1 then
    if start_col == end_col then
      return generate_single_column_syntax(start_col, code)
    else
      return generate_range_syntax(start_col, end_col, code)
    end
  else
    return generate_multi_field_syntax(start_col, end_col, w_field, n_field, code)
  end
end

function M.replace_columns()
  local current_data = get_current_line_data()
  if not current_data.questions then
    return
  end

  local data_table = M.parse_layout()
  local normalized_spec = current_data.questions:gsub(", ", ",")
  local original_spec = normalized_spec
  local spec_table = M.parse_spec(current_data.questions, data_table)

  local updated_spec = normalized_spec

  for _, spec_entry in ipairs(spec_table) do
    if spec_entry.question ~= "OR" then
      local syntax = generate_syntax_for_spec(spec_entry, data_table)
      if syntax then
        local pattern = [[\(!\S*\)\@<!]] .. spec_entry.spec
        updated_spec = vim.fn.substitute(updated_spec, pattern, syntax, "")
      end
    end
  end

  -- Update the current line
  local parts = current_data.parts
  parts[2] = vim.fn.substitute(parts[2]:gsub(", ", ","), original_spec, updated_spec, "")

  local new_line = vim.fn.join(parts, COLUMN_SEPARATOR):upper()
  vim.api.nvim_set_current_line(new_line)
end

-- Main processing function
function M.process_uncle_syntax()
  local count = vim.v.count ~= 0 and vim.v.count or 1
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for _ = 1, count do
    M.replace_columns()
    current_line = current_line + 1
    vim.api.nvim_win_set_cursor(0, { current_line, 0 })
  end
end

-- Combined fix function
function M.combined_fix()
  local line = vim.fn.line "."
  vim.cmd [[SpecFix]]
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  vim.cmd [[USyntax]]
end

-- Legacy API compatibility
M.selectQuestions = function()
  local data = get_current_line_data()
  return { data.questions, data.buffer }
end

M.parseLayout = M.parse_layout
M.parseSpec = function()
  local data = get_current_line_data()
  local data_table = M.parse_layout()
  return M.parse_spec(data.questions, data_table)
end
M.replaceColumns = M.replace_columns
M.uncleSyntax = M.process_uncle_syntax
M.combFix = M.combined_fix

-- Keep the data_table exposed for backward compatibility
M.data_table = cache.data_table

-- Register command
vim.api.nvim_create_user_command("USyntax", M.process_uncle_syntax, {})

return M
