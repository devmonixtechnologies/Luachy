local Utils = {}

function Utils.ensure_package_path()
  local src_path = "./src/?.lua;./src/?/init.lua"
  if not string.find(package.path, src_path, 1, true) then
    package.path = table.concat({ package.path, src_path }, ";")
  end
end

local function is_leap(year)
  if year % 400 == 0 then
    return true
  elseif year % 100 == 0 then
    return false
  elseif year % 4 == 0 then
    return true
  end
  return false
end

local function max_days_in_month(year, month)
  local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
  if month == 2 and is_leap(year) then
    return 29
  end
  return days[month]
end

function Utils.is_valid_date(date_str)
  if type(date_str) ~= "string" then
    return false
  end

  local year, month, day = date_str:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
  year, month, day = tonumber(year), tonumber(month), tonumber(day)
  if not (year and month and day) then
    return false
  end

  if month < 1 or month > 12 then
    return false
  end
  local max_day = max_days_in_month(year, month)
  if day < 1 or day > max_day then
    return false
  end
  return true
end

function Utils.is_valid_month(month_str)
  if type(month_str) ~= "string" then
    return false
  end
  local year, month = month_str:match("^(%d%d%d%d)%-(%d%d)$")
  year, month = tonumber(year), tonumber(month)
  if not (year and month) then
    return false
  end
  return month >= 1 and month <= 12
end

function Utils.today()
  return os.date("%Y-%m-%d")
end

function Utils.month_from_date(date_str)
  return date_str:sub(1, 7)
end

function Utils.copy_table(t)
  local copy = {}
  for key, value in pairs(t) do
    copy[key] = value
  end
  return copy
end

return Utils
