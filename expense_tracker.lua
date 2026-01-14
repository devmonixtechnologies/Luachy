package.path = package.path .. ";./src/?.lua;./src/?/init.lua"

local Utils = require("utils")
Utils.ensure_package_path()

local Cli = require("cli")

local args = {}
for i = 1, #arg do
  table.insert(args, arg[i])
end

local ok = Cli.run(args)
if not ok then
  os.exit(1)
end
