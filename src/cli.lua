local ExpenseService = require("expense_service")
local Utils = require("utils")

local Cli = {}

local function pad(str, len)
  str = tostring(str or "")
  if #str >= len then
    return str
  end
  return str .. string.rep(" ", len - #str)
end

local function parse_options(args, start_index)
  local opts = {}
  local i = start_index or 2
  while i <= #args do
    local token = args[i]
    if not token:match("^%-%-") then
      error(("Unexpected argument '%s'. Only --key value pairs are allowed."):format(token))
    end
    local key = token:sub(3)
    if key == "" then
      error("Option name after '--' cannot be empty.")
    end
    if i + 1 > #args then
      error(("Option '--%s' is missing its value."):format(key))
    end
    local value = args[i + 1]
    opts[key] = value
    i = i + 2
  end
  return opts
end

local function print_expenses(expenses)
  if #expenses == 0 then
    print("No expenses found for the given filters.")
    return
  end

  print(("Found %d expenses:"):format(#expenses))
  print(pad("DATE", 12) .. pad("CATEGORY", 15) .. pad("AMOUNT", 12) .. "DESCRIPTION")
  print(string.rep("-", 60))
  for _, exp in ipairs(expenses) do
    local amount = string.format("%.2f", exp.amount)
    print(pad(exp.date, 12) .. pad(exp.category, 15) .. pad(amount, 12) .. exp.description)
  end
end

local function print_summary(summary)
  print("Expense summary")
  if summary.month then
    print(("  Month     : %s"):format(summary.month))
  end
  if summary.category then
    print(("  Category  : %s"):format(summary.category))
  end
  print(("  Count     : %d"):format(summary.count))
  print(("  Total     : %.2f"):format(summary.total))
  print(("  Average   : %.2f"):format(summary.average))
  print("")
  if #summary.by_category == 0 then
    print("No category breakdown available.")
    return
  end
  print("Totals by category:")
  for _, bucket in ipairs(summary.by_category) do
    print(("  - %-15s %.2f"):format(bucket.category, bucket.total))
  end
end

local function show_usage()
  local lines = {
    "Expense Tracker (Lua)",
    "",
    "Usage:",
    "  lua expense_tracker.lua <command> [options]",
    "",
    "Commands:",
    "  add         Add a new expense",
    "              Options: --amount <number> --category <name> [--description <text>] [--date YYYY-MM-DD]",
    "  list        List expenses. Filters: [--month YYYY-MM] [--category <name>]",
    "  summary     Show totals and averages. Filters same as list.",
    "  categories  List distinct categories used so far",
    "  help        Show this message",
    "",
    "Examples:",
    "  lua expense_tracker.lua add --amount 12.5 --category groceries --description \"Bread\"",
    "  lua expense_tracker.lua list --month 2025-01",
    "  lua expense_tracker.lua summary --category commute",
  }
  print(table.concat(lines, "\n"))
end

function Cli.run(args)
  if #args == 0 or args[1] == "help" or args[1] == "--help" then
    show_usage()
    return true
  end

  local command = args[1]

  local ok, result = pcall(function()
    if command == "add" then
      local options = parse_options(args, 2)
      local normalized = ExpenseService.add(options)
      print(("Added %s %.2f (%s)"):format(normalized.category, normalized.amount, normalized.date))
      if normalized.description ~= "" then
        print("Description: " .. normalized.description)
      end
      return true
    elseif command == "list" then
      local options = parse_options(args, 2)
      if options.month and not Utils.is_valid_month(options.month) then
        error("Month must be formatted as YYYY-MM")
      end
      local expenses = ExpenseService.list(options)
      print_expenses(expenses)
      return true
    elseif command == "summary" then
      local options = parse_options(args, 2)
      if options.month and not Utils.is_valid_month(options.month) then
        error("Month must be formatted as YYYY-MM")
      end
      local summary = ExpenseService.summary(options)
      print_summary(summary)
      return true
    elseif command == "categories" then
      local categories = ExpenseService.categories()
      if #categories == 0 then
        print("No categories recorded yet.")
      else
        print("Categories:")
        for _, category in ipairs(categories) do
          print("  - " .. category)
        end
      end
      return true
    else
      error(("Unknown command '%s'. Run 'lua expense_tracker.lua help' for usage."):format(command))
    end
  end)

  if not ok then
    io.stderr:write(result .. "\n")
    return false
  end
  return result
end

return Cli
