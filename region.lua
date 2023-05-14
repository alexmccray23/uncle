-- Neovim plugin for generating region tables
-- NOTES:
-- !G sort -b -t $'\t' -k 5 -k 3
-- K:/2023/0291/docs/frame

local M = {}

function M.menu()
  local choices = {
    { label = "1. Nets",          func = M.nets },
    { label = "2. No Nets",       func = M.noNets },
    { label = "3. 8-pt National", func = M.eightPoinNational },
    { label = "4. 4-pt National", func = M.fourPointNational },
  }
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

function M.nets()
  local region_col = tonumber(vim.fn.input("Region/DMA name column #"))
  if region_col == "" then return end
  local county_col = tonumber(vim.fn.input("State/County name column #"))
  if county_col == "" then return end
  local fips_col = tonumber(vim.fn.input("FIPS code column #"))
  if fips_col == "" then return end

  local layout_col = vim.fn.input("Data columns - X:Y in R(1!X:Y...")
  if layout_col == "" then layout_col = "X:Y" end

  local sort_cmd = "2,$!sort -b -t$'\\t' -k " .. region_col .. " -k " .. fips_col .. "n"
  vim.api.nvim_exec2(sort_cmd, {})

  local text = vim.api.nvim_buf_get_lines(0, 2, -1, false)

  local region_data = {}
  local county_data = {}
  local fips_data = {}
  for _, line in ipairs(text) do
    local array = vim.split(line, "\t", { plain = false })
    table.insert(region_data, array[region_col])
    table.insert(county_data, array[county_col])
    table.insert(fips_data, array[fips_col])
  end
  vim.api.nvim_exec2("new", {})
end

function M.noNets()
end

function M.eightPoinNational()
end

function M.fourPointNational()
end

vim.api.nvim_create_user_command("Region", M.menu, {})

return M
