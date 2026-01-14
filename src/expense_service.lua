local ExpenseStore = require("expense_store")
local Utils = require("utils")

local ExpenseService = {}

local function trim(value)
  if type(value) ~= "string" then
    return value
  end
  return value:match("^%s*(.-)%s*$")
end

local function validate(expense)
  if not expense.amount then
    error("Amount is required (use --amount)")
  end

  local amount = tonumber(expense.amount)
  if not amount or amount <= 0 then
    error("Amount must be a positive number")
  end

  local category = trim(expense.category or "")
  if category == "" then
    error("Category is required (use --category)")
  end

  local description = trim(expense.description or "")
  local date = expense.date or Utils.today()
  if not Utils.is_valid_date(date) then
    error("Date must follow YYYY-MM-DD and be valid")
  end

  return {
    amount = amount,
    category = category,
    description = description,
    date = date,
  }
end

local function matches_filters(expense, filters)
  if not filters then
    return true
  end

  if filters.month then
    if Utils.month_from_date(expense.date) ~= filters.month then
      return false
    end
  end

  if filters.category then
    if expense.category:lower() ~= filters.category:lower() then
      return false
    end
  end

  return true
end

function ExpenseService.add(fields)
  local normalized = validate(fields)
  ExpenseStore.append(normalized)
  return normalized
end

function ExpenseService.list(filters)
  local expenses = ExpenseStore.load_all()
  table.sort(expenses, function(a, b)
    if a.date == b.date then
      if a.category == b.category then
        return a.description < b.description
      end
      return a.category < b.category
    end
    return a.date < b.date
  end)

  local filtered = {}
  for _, expense in ipairs(expenses) do
    if matches_filters(expense, filters) then
      table.insert(filtered, expense)
    end
  end
  return filtered
end

function ExpenseService.summary(filters)
  local expenses = ExpenseService.list(filters)
  local totals_by_category = {}
  local sum = 0

  for _, expense in ipairs(expenses) do
    sum = sum + expense.amount
    totals_by_category[expense.category] = (totals_by_category[expense.category] or 0) + expense.amount
  end

  local by_category = {}
  for category, total in pairs(totals_by_category) do
    table.insert(by_category, { category = category, total = total })
  end

  table.sort(by_category, function(a, b)
    if a.total == b.total then
      return a.category < b.category
    end
    return a.total > b.total
  end)

  local result = {
    count = #expenses,
    total = sum,
    average = #expenses > 0 and (sum / #expenses) or 0,
    by_category = by_category,
  }

  if filters and filters.month then
    result.month = filters.month
  end
  if filters and filters.category then
    result.category = filters.category
  end
  return result
end

function ExpenseService.categories()
  local expenses = ExpenseStore.load_all()
  local seen = {}
  local categories = {}

  for _, expense in ipairs(expenses) do
    local key = expense.category
    if key and not seen[key] then
      seen[key] = true
      table.insert(categories, key)
    end
  end

  table.sort(categories)
  return categories
end

return ExpenseService
