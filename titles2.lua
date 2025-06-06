-- Neovim plugin for shifting banner titles to fit above their columns
-- Refactored version with improved structure and readability

local M = {}

-- Configuration constants
local PATTERNS = {
  table_end = "^\\*\\n\\|F \\&CP",
  o_format = "^(O FORMAT 27 )(%d)(.*)",
  column_def = "^C %&CE",
  colw_pattern = "(.*)(COLW )(%d)(.*)",
  cc_pattern = "%&CC(%d+):(%d+)",
  special_title = "S//R//H",
}

local PROMPTS = {
  move_title = "&Yes\n&No\n&Cancel",
  title_too_wide = " is too wide by ",
}

-- Utility functions
local function get_current_position()
  return vim.fn.getcurpos()[2]
end

local function find_table_boundaries()
  local start_line = get_current_position()
  local end_line = vim.fn.search(PATTERNS.table_end, "W")
  return start_line, end_line
end

local function extract_table_text(start_line, end_line)
  return vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
end

local function set_cursor_position(line, col)
  vim.api.nvim_win_set_cursor(0, { line, col or 0 })
end

-- Main functionality
function M.copy_table()
  local start_line, end_line = find_table_boundaries()
  local whole_text = extract_table_text(start_line, end_line)
  set_cursor_position(start_line)
  return {
    text = whole_text,
    start_line = start_line,
    end_line = end_line,
  }
end

function M.extract_column_widths()
  local table_data = M.copy_table()
  local column_widths = {}
  local default_width = nil

  for _, line in ipairs(table_data.text) do
    if line:match "O FORMAT" then
      default_width = line:gsub(PATTERNS.o_format, "%2")
    elseif line:match(PATTERNS.column_def) then
      local width = M.parse_column_width(line, default_width)
      table.insert(column_widths, width)
    end
  end

  return column_widths
end

function M.parse_column_width(line, default_width)
  local line_parts = vim.split(line, ";", { plain = true })

  if #line_parts > 2 and line_parts[3]:match "COLW %d" then
    return line_parts[3]:gsub(PATTERNS.colw_pattern, "%3")
  end

  return default_width
end

function M.parse_title_text(text)
  -- Prepare text for parsing
  text = text:gsub(PATTERNS.cc_pattern, "|&CC%1:%2|")
  return vim.split(text, "|", { plain = true })
end

function M.calculate_column_span_width(range_text, column_widths)
  local total_width = 0
  local range = range_text:gsub("%&CC", "")
  local range_parts = vim.split(range, ":")
  local start_col, end_col = tonumber(range_parts[1]), tonumber(range_parts[2])

  for col = start_col, end_col do
    total_width = total_width + tonumber(column_widths[col])
    if col ~= end_col then
      total_width = total_width + 1 -- Add separator space
    end
  end

  return total_width
end

function M.clean_title_text(text)
  local cleaned = text:gsub("//", "/")
  cleaned = cleaned:gsub("%&&", "&")
  cleaned = cleaned:gsub("^%s+", "")
  return cleaned
end

function M.handle_title_overflow(title_text, available_width, original_text)
  local cleaned_text = M.clean_title_text(title_text)
  local text_width = #cleaned_text

  if text_width <= available_width then
    return { success = true, result = original_text }
  end

  local overflow = text_width - available_width
  local message = cleaned_text .. PROMPTS.title_too_wide .. overflow .. ". Move?"
  local choice = vim.fn.confirm(message, PROMPTS.move_title)

  if choice == 3 then -- Cancel
    return { success = false, cancelled = true }
  elseif choice == 1 then -- Yes, move
    return M.split_title_text(original_text, available_width)
  else -- No, keep as is
    return { success = true, result = original_text }
  end
end

function M.split_title_text(original_text, available_width)
  local processed_text = M.prepare_text_for_splitting(original_text)
  local word_array = vim.split(processed_text, " +", { plain = false, trimempty = true })

  return M.find_optimal_split(word_array, available_width, original_text)
end

function M.prepare_text_for_splitting(text)
  local processed = text:gsub("//", "// ")

  if text:match(PATTERNS.special_title) then
    processed = vim.fn.substitute(text, "S// R// H", "S//R//H", "g")
  end

  return processed
end

function M.find_optimal_split(word_array, available_width, original_text)
  local current_length = #M.clean_title_text(original_text)

  for i = 1, #word_array do
    current_length = current_length - #word_array[i]

    if current_length <= available_width or (i == #word_array - 1 and #word_array - i == 1) then
      local upper_part = table.concat({ unpack(word_array, 1, i) }, " ")
      local lower_part = table.concat({ unpack(word_array, i + 1) }, " ")

      return {
        success = true,
        split = true,
        upper = upper_part,
        lower = lower_part,
      }
    end
  end

  return { success = true, result = original_text }
end

function M.process_title_row()
  local table_data = M.copy_table()
  local column_widths = M.extract_column_widths()
  local title_text = table_data.text[1]
  local title_array = M.parse_title_text(title_text)

  local upper_row = {}
  local main_row = {}
  local current_span_width = 0

  for index, segment in ipairs(title_array) do
    if index % 2 == 0 then -- Column range specifier
      current_span_width = M.calculate_column_span_width(segment, column_widths)
      table.insert(main_row, segment)
    else -- Title text
      if index > 1 then -- Not the first segment
        local result = M.handle_title_overflow(segment, current_span_width, segment)

        if not result.success then
          return nil -- User cancelled
        end

        if result.split then
          table.insert(upper_row, title_array[index - 1] .. " " .. result.upper)
          table.insert(main_row, " " .. result.lower)
        else
          table.insert(main_row, result.result)
        end
      else
        table.insert(main_row, segment)
      end
    end
  end

  if #upper_row > 0 then
    return {
      "T " .. table.concat(upper_row, ""),
      table.concat(main_row, ""),
    }
  else
    return { table.concat(main_row, "") }
  end
end

function M.replace_titles()
  local new_titles = M.process_title_row()
  local table_data = M.copy_table()

  if new_titles then
    vim.api.nvim_buf_set_lines(0, table_data.start_line - 1, table_data.start_line, false, new_titles)
    set_cursor_position(table_data.start_line)
  end
end

-- Command registration
vim.api.nvim_create_user_command("Titles2", M.replace_titles, {})

return M
