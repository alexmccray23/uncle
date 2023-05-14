-- Neovim plugin for generating region tables

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
  local region_col = vim.input("Region/DMA name column #")
  if region_col == "" then return end
  local county_col = vim.input("State/County name column #")
  if county_col == "" then return end
  local fips_col = vim.input("FIPS code column #")
  if fips_col == "" then return end
  --!G sort -b -t $'\t' -k 5 -k 3
end

function M.noNets()
end

function M.eightPoinNational()
end

function M.fourPointNational()
end

vim.api.nvim_create_user_command("Region", M.menu, {})

return M
