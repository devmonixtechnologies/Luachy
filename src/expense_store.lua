local ExpenseStore = {}

local DATA_FILE = "data/expenses.lua"

local function quote(str)
  local escaped = tostring(str)
    :gsub("\\", "\\\\")
    :gsub("\n", "\\n")
    :gsub("\"", "\\\"")
  return string.format("\"%s\"", escaped)
end

local function serialize(expenses)
  local lines = { "return {" }
  for _, expense in ipairs(expenses) do
    local line = string.format(
      "  { date = %s, category = %s, amount = %s, description = %s },",
      quote(expense.date),
      quote(expense.category),
      tostring(expense.amount),
      quote(expense.description)
    )
    table.insert(lines, line)
  end
  table.insert(lines, "}")
  table.insert(lines, "")
  return table.concat(lines, "\n")
end

local function load_raw()
  local file = io.open(DATA_FILE, "r")
  if not file then
    return {}
  end

  local content = file:read("*a")
  file:close()

  if not content or content == "" then
    return {}
  end

  local chunk, err = load(content, "expense_data", "t", {})
  if not chunk then
    error(("The expense file is corrupted: %s"):format(err))
  end

  local ok, value = pcall(chunk)
  if not ok then
    error(("Unable to execute expense data: %s"):format(value))
  end

  if type(value) ~= "table" then
    error("Expense data is not a table")
  end

  return value
end

local function ensure_data_dir()
  local dir = DATA_FILE:match("(.+)/[^/]+$")
  if not dir then
    return
  end

  local ok = os.execute(string.format("mkdir -p %q", dir))
  if not ok then
    error("Failed to ensure data directory exists")
  end
end

function ExpenseStore.load_all()
  return load_raw()
end

function ExpenseStore.save_all(expenses)
  ensure_data_dir()
  local serialized = serialize(expenses)
  local file, err = io.open(DATA_FILE, "w")
  if not file then
    error(("Unable to write expense file: %s"):format(err))
  end
  file:write(serialized)
  file:close()
end

function ExpenseStore.append(expense)
  local expenses = load_raw()
  table.insert(expenses, expense)
  ExpenseStore.save_all(expenses)
end

return ExpenseStore
