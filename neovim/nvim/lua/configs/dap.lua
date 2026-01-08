local ok, dap = pcall(require, "dap")
if not ok then
  vim.notify("nvim-dap not available", vim.log.levels.WARN)
  return
end

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

local function jest_command()
  local exe = vim.g["test#javascript#jest#executable"]
  if type(exe) == "function" then
    exe = exe()
  end

  if not exe or exe == "" then
    exe = "jest"
  end

  return exe
end

-- js-debug adapter - try multiple locations
local function find_js_debug()
  -- Try mason first
  local mason_path = vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter"
  local debugger_paths = {
    mason_path .. "/js-debug/src/dapDebugServer.js",
    mason_path .. "/out/src/dapDebugServer.js",
    mason_path .. "/dist/dapDebugServer.js",
  }
  
  for _, path in ipairs(debugger_paths) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  
  return nil
end

local js_debug_path = find_js_debug()

-- Configure pwa-node adapter
dap.adapters["pwa-node"] = {
  type = "server",
  host = "127.0.0.1",
  port = "${port}",
  executable = {
    command = js_debug_path and "node" or "npx",
    args = js_debug_path and { js_debug_path, "${port}", "127.0.0.1" } or { "js-debug", "${port}", "127.0.0.1" },
  },
}

-- Warn if js-debug-adapter not found
if not js_debug_path then
  vim.notify("js-debug-adapter not found in Mason. Install with :MasonInstall js-debug-adapter or using npx fallback", vim.log.levels.WARN)
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

-- Debug test using vim-test's working logic
local function debug_jest_test(test_type)
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

-- Export for use in mappings
_G.DebugJestTest = debug_jest_test

local function jest_config(name)
  return {
    type = "pwa-node",
    request = "launch",
    name = name,
    cwd = function()
      return find_jest_root() or vim.fn.getcwd()
    end,
    runtimeExecutable = "node",
    runtimeArgs = {
      "--inspect-brk",
      jest_command(),
      "${file}",
      "--runInBand",
    },
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
    env = {
      NODE_OPTIONS = "--experimental-vm-modules --no-warnings",
    },
  }
end

dap.configurations.javascript = {
  jest_config "Jest (file)",
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach to Port 9229",
    port = 9229,
    cwd = "${workspaceFolder}",
  },
}

dap.configurations.typescript = dap.configurations.javascript
dap.configurations.javascriptreact = dap.configurations.javascript
dap.configurations.typescriptreact = dap.configurations.javascript

