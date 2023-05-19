-- Neovim plugin for adding split sample qualifiers and base labels

local M = {}

function M.stateFips()
  local states = {
    { name = "Alabama",                        abb = "AL", fips = "01" },
    { name = "Alaska",                         abb = "AK", fips = "02" },
    { name = "Arizona",                        abb = "AZ", fips = "04" },
    { name = "Arkansas",                       abb = "AR", fips = "05" },
    { name = "California",                     abb = "CA", fips = "06" },
    { name = "Colorado",                       abb = "CO", fips = "08" },
    { name = "Connecticut",                    abb = "CT", fips = "09" },
    { name = "Delaware",                       abb = "DE", fips = "10" },
    { name = "District of Columbia",           abb = "DC", fips = "11" },
    { name = "Florida",                        abb = "FL", fips = "12" },
    { name = "Georgia",                        abb = "GA", fips = "13" },
    { name = "Hawaii",                         abb = "HI", fips = "15" },
    { name = "Idaho",                          abb = "ID", fips = "16" },
    { name = "Illinois",                       abb = "IL", fips = "17" },
    { name = "Indiana",                        abb = "IN", fips = "18" },
    { name = "Iowa",                           abb = "IA", fips = "19" },
    { name = "Kansas",                         abb = "KS", fips = "20" },
    { name = "Kentucky",                       abb = "KY", fips = "21" },
    { name = "Louisiana",                      abb = "LA", fips = "22" },
    { name = "Maine",                          abb = "ME", fips = "23" },
    { name = "Maryland",                       abb = "MD", fips = "24" },
    { name = "Massachusetts",                  abb = "MA", fips = "25" },
    { name = "Michigan",                       abb = "MI", fips = "26" },
    { name = "Minnesota",                      abb = "MN", fips = "27" },
    { name = "Mississippi",                    abb = "MS", fips = "28" },
    { name = "Missouri",                       abb = "MO", fips = "29" },
    { name = "Montana",                        abb = "MT", fips = "30" },
    { name = "Nebraska",                       abb = "NE", fips = "31" },
    { name = "Nevada",                         abb = "NV", fips = "32" },
    { name = "New Hampshire",                  abb = "NH", fips = "33" },
    { name = "New Jersey",                     abb = "NJ", fips = "34" },
    { name = "New Mexico",                     abb = "NM", fips = "35" },
    { name = "New York",                       abb = "NY", fips = "36" },
    { name = "North Carolina",                 abb = "NC", fips = "37" },
    { name = "North Dakota",                   abb = "ND", fips = "38" },
    { name = "Ohio",                           abb = "OH", fips = "39" },
    { name = "Oklahoma",                       abb = "OK", fips = "40" },
    { name = "Oregon",                         abb = "OR", fips = "41" },
    { name = "Pennsylvania",                   abb = "PA", fips = "42" },
    { name = "Rhode Island",                   abb = "RI", fips = "44" },
    { name = "South Carolina",                 abb = "SC", fips = "45" },
    { name = "South Dakota",                   abb = "SD", fips = "46" },
    { name = "Tennessee",                      abb = "TN", fips = "47" },
    { name = "Texas",                          abb = "TX", fips = "48" },
    { name = "Utah",                           abb = "UT", fips = "49" },
    { name = "Vermont",                        abb = "VT", fips = "50" },
    { name = "Virginia",                       abb = "VA", fips = "51" },
    { name = "Washington",                     abb = "WA", fips = "53" },
    { name = "West Virginia",                  abb = "WV", fips = "54" },
    { name = "Wisconsin",                      abb = "WI", fips = "55" },
    { name = "Wyoming",                        abb = "WY", fips = "56" },
    { name = "American Samoa",                 abb = "AS", fips = "60" },
    { name = "Federated States of Micronesia", abb = "FM", fips = "64" },
    { name = "Guam",                           abb = "GU", fips = "66" },
    { name = "Johnston Atoll",                 abb = "JA", fips = "67" },
    { name = "Marshall Islands",               abb = "MH", fips = "68" },
    { name = "Northern Mariana Islands",       abb = "MP", fips = "69" },
    { name = "Palau",                          abb = "PW", fips = "70" },
    { name = "Midway Islands",                 abb = "MI", fips = "71" },
    { name = "Puerto Rico",                    abb = "PR", fips = "72" },
    { name = "U.S Minor Outlying Islands",     abb = "UM", fips = "74" },
    { name = "Navassa Island",                 abb = "NI", fips = "76" },
    { name = "Virgin Islands",                 abb = "VI", fips = "78" },
    { name = "Wake Island",                    abb = "WI", fips = "79" },
    { name = "Baker",                          abb = "BI", fips = "81" },
    { name = "Howland Island",                 abb = "HI", fips = "84" },
    { name = "Jarvis Island",                  abb = "JI", fips = "86" },
    { name = "Kingman Reef",                   abb = "KR", fips = "89" },
    { name = "Palmyra Atoll",                  abb = "PA", fips = "95" }
  }
  local text = vim.api.nvim_get_current_line():upper()
  local line_num = vim.fn.line('.')
  for i, _ in ipairs(states) do
    if text == states[i]['name']:upper() or text == states[i]['abb'] then
      local code = states[i]['fips']
      vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { code })
      vim.api.nvim_win_set_cursor(0, { line_num + 1, 0 })
      break
    end
  end
end

vim.api.nvim_create_user_command("Fips", M.stateFips, {})

return M
