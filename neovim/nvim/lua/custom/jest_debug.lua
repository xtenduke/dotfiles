-- Jest debug helper using vim-test's working logic
local function find_jest_root()
  local config_names = {
    "jest.config.js",
    "jest.config.ts",
    "jest.config.mjs",
    "jest.config.cjs",
    "jest.config.cts",
    "jest.config.json",
  }

  local package_markers = {
    "package.json",
    "pnpm-workspace.yaml",
    "yarn.lock",
    "rush.json",
    "lerna.json",
  }

  local buf_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local roots = { buf_dir, vim.fn.getcwd() }

  for _, root in ipairs(roots) do
    if root and root ~= "" then
      local found = vim.fs.find(config_names, { path = root, upward = true })[1]
      if found then
        return vim.fs.dirname(found)
      end

      local pkg = vim.fs.find(package_markers, { path = root, upward = true })[1]
      if pkg then
        return vim.fs.dirname(pkg)
      end
    end
  end
end

-- Get the test name at cursor for debugging a specific test
local function get_test_name_at_cursor()
  local line = vim.api.nvim_get_current_line()
  -- Match test/it/describe patterns with various quote styles
  local test_patterns = {
    "test%s*%([\"']([^\"']+)[\"']",     -- test("name"
    "it%s*%([\"']([^\"']+)[\"']",       -- it("name"
    "describe%s*%([\"']([^\"']+)[\"']", -- describe("name"
    'test%s*%(["\']([^"\']+)["\']',     -- test('name'
    'it%s*%(["\']([^"\']+)["\']',       -- it('name'
    'describe%s*%(["\']([^"\']+)["\']', -- describe('name'
  }
  
  for _, pattern in ipairs(test_patterns) do
    local name = line:match(pattern)
    if name then
      return name
    end
  end
  
  return nil
end

-- Debug test using vim-test's working logic + DAP
local function debug_jest_test(test_type)
  local ok, dap = pcall(require, "dap")
  if not ok then
    vim.notify("nvim-dap not available. Install with :LazyInstall nvim-dap", vim.log.levels.ERROR)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file open!", vim.log.levels.ERROR)
    return
  end
  
  local root = find_jest_root()
  if not root then
    vim.notify("Could not find Jest root!", vim.log.levels.ERROR)
    return
  end
  
  local exe = vim.g["test#javascript#jest#executable"]
  if type(exe) == "function" then
    exe = exe()
  end
  
  -- Extract jest binary from the command (remove node flags)
  -- The command is: "node --experimental-vm-modules --no-warnings /path/to/jest"
  local jest_bin = exe:match("node%s+--[^%s]+%s+--[^%s]+%s+(.+)") 
    or exe:match("node%s+--[^%s]+%s+(.+)")
    or exe:match("jest")
  
  -- Strip surrounding quotes if present
  if jest_bin then
    jest_bin = jest_bin:gsub("^['\"]", ""):gsub("['\"]$", "")
  end
  
  if not jest_bin or jest_bin == "" then
    -- Fallback: find jest binary
    local jest_path = vim.fs.find({ "node_modules/.bin/jest" }, {
      path = root,
      upward = true,
    })[1]
    jest_bin = jest_path or "jest"
  end
  
  -- Build Jest arguments
  local jest_args = {
    "--runInBand",
    "--detectOpenHandles",
    "--no-coverage",
  }
  
  -- Add config file if found
  local config_names = {
    "jest.config.js",
    "jest.config.ts",
    "jest.config.mjs",
    "jest.config.cjs",
    "jest.config.cts",
    "jest.config.json",
  }
  
  for _, name in ipairs(config_names) do
    local config_path = root .. "/" .. name
    if vim.fn.filereadable(config_path) == 1 then
      table.insert(jest_args, "--config")
      table.insert(jest_args, config_path)
      break
    end
  end
  
  -- Add test file and optionally test name
  if test_type == "nearest" then
    local test_name = get_test_name_at_cursor()
    if test_name then
      -- Use -t to match test name pattern
      table.insert(jest_args, "-t")
      table.insert(jest_args, test_name)
    end
    table.insert(jest_args, file)
  else
    table.insert(jest_args, file)
  end
  
  local config = {
    type = "pwa-node",
    request = "launch",
    name = "Debug Jest Test",
    cwd = root,
    runtimeExecutable = "node",
    runtimeArgs = {
      "--inspect-brk",
      "--experimental-vm-modules",
      "--no-warnings",
      jest_bin,
    },
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
    env = {
      NODE_OPTIONS = "--experimental-vm-modules --no-warnings",
    },
    skipFiles = { "<node_internals>/**" },
  }
  
  -- Append jest args to runtime args
  for _, arg in ipairs(jest_args) do
    table.insert(config.runtimeArgs, arg)
  end
  
  dap.run(config)
end

return {
  debug_jest_test = debug_jest_test,
}

