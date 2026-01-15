# Lua Expense Tracker

Small command-line expense tracker written in pure Lua (no external libraries). Data is persisted as a Lua table under `data/expenses.lua`.

## Requirements

- Lua 5.3+ runtime in your PATH (package manager or https://www.lua.org/download.html).

## Setup

```bash
lua -v  # ensure lua is installed
```

The script automatically creates the `data` directory/file on first write. No other setup needed.

## Usage

```
lua expense_tracker.lua <command> [options]
```

Commands:

- `add --amount <number> --category <name> [--description <text>] [--date YYYY-MM-DD]`
- `list [--month YYYY-MM] [--category <name>]`
- `summary [--month YYYY-MM] [--category <name>]`
- `categories`
- `help`

Examples:

```bash
lua expense_tracker.lua add --amount 12.50 --category groceries --description "Bread"
lua expense_tracker.lua list --month 2026-01
lua expense_tracker.lua summary --category commute
lua expense_tracker.lua categories
```

### Data format

Expenses are stored as a Lua table so you can back up or version-control `data/expenses.lua`. Editing by hand is possible but keep structure identical:

```lua
return {
  { date = "2026-01-14", category = "groceries", amount = 12.5, description = "Bread" },
}
```

## Validation

The repository currently has no CI, but the CLI entry point can be smoke-tested via:

```bash
lua expense_tracker.lua help
```

If this fails with `lua: command not found`, install Lua as described aboves.
