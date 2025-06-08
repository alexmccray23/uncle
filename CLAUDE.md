# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a specialized Neovim configuration module for **Venture Data** that provides automated data processing tools for survey/polling analysis. The codebase consists of 50+ Lua plugins that automate creation and formatting of "Uncle tables" - a specific format for statistical data tabulation.

## Architecture

### Module Structure
- Each `.lua` file is a self-contained Neovim plugin following the pattern:
  ```lua
  local M = {}
  function M.functionName() -- Implementation end
  vim.api.nvim_create_user_command("CommandName", M.functionName, {})
  return M
  ```
- All modules are loaded via `keymaps.lua` which serves as the main entry point
- Heavy use of Vim ex-commands, regex operations, and string manipulation for text processing

### Key Categories
- **Data Processing**: `uncle_syntax.lua` (core parser), `layout.lua`, `pos_spec_conversion.lua`
- **Table Formatting**: `banner_column.lua`, `base_row.lua`, `qualifier_row.lua`, `r_row.lua`
- **Statistical Operations**: `summary_setup.lua`, `sum2_setup.lua`, `nets.lua`, `diff_score.lua`
- **Geographic/Regional**: `region.lua`, `state_abbv.lua`, `state_fips.lua`
- **Utilities**: `init_clean.lua`, `text2tab.lua`, `tab_columns.lua`, `zero_pad.lua`

### Core Data Flow
1. Survey layout files (`.lay`) are parsed by `layout.lua` and `uncle_syntax.lua`
2. Specifications are converted to Uncle programming syntax
3. Various formatting plugins add table elements (banners, rows, columns)
4. Statistical operations are applied via dedicated modules
5. Final output is formatted Uncle table specifications

## Key Technical Patterns

- **Interactive Prompts**: Use `vim.fn.input()` for user parameters
- **Text Processing**: Extensive use of `vim.split()`, `vim.fn.substitute()`, pattern matching
- **State Management**: Some modules cache data between operations (e.g., `uncle_syntax.lua`)
- **Error Handling**: User feedback via `print()` statements
- **Menu Interfaces**: Multi-option selections (see `region.lua`)

## File Types and Extensions
- `.lay` - Survey layout files (input format)
- `.rfl` - Readable format layout files
- `.E` - Uncle syntax files
- No specific test files or build processes - this is a runtime Neovim configuration
