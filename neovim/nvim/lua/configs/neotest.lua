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

local function find_jest_context(path)
  local file_dir = path and vim.fs.dirname(path) or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local roots = { file_dir, vim.fn.getcwd() }
  local cfg, root

  for _, base in ipairs(roots) do
    if base and base ~= "" then
      local found_cfg = vim.fs.find(config_names, { path = base, upward = true })[1]
      if found_cfg then
        cfg = found_cfg
        root = vim.fs.dirname(found_cfg)
        break
      end
      local pkg = vim.fs.find(package_markers, { path = base, upward = true })[1]
      if pkg then
        root = vim.fs.dirname(pkg)
        break
      end
    end
  end

  root = root or file_dir or vim.fn.getcwd()

  local jest_bin = vim.fs.find({ "node_modules/.bin/jest" }, {
    path = root,
    upward = true,
  })[1]
  if not jest_bin and vim.fn.executable("jest") == 1 then
    jest_bin = "jest"
  end

  return {
    root = root,
    config = cfg,
    bin = jest_bin,
  }
end

-- Export for debugging
_G.DebugJestContext = function(path)
  local ctx = find_jest_context(path)
  local file = path or vim.api.nvim_buf_get_name(0)
  local output = {
    "=== Jest Context Debug ===",
    "File: " .. (file or "none"),
    "Root: " .. (ctx.root or "none"),
    "Config: " .. (ctx.config or "none"),
    "Jest Bin: " .. (ctx.bin or "none"),
    "",
    "Checking if files exist:",
    "  Config readable: " .. (ctx.config and vim.fn.filereadable(ctx.config) == 1 and "YES" or "NO"),
    "  Jest bin readable: " .. (ctx.bin and vim.fn.filereadable(ctx.bin) == 1 and "YES" or "NO"),
    "  Jest executable: " .. (ctx.bin and vim.fn.executable(ctx.bin) == 1 and "YES" or "NO"),
  }
  vim.notify(table.concat(output, "\n"), vim.log.levels.INFO)
  print(table.concat(output, "\n"))
  return ctx
end

local neotest_lib = require("neotest.lib")

-- Find package root by looking for jest.config or package.json
-- This ensures neotest scopes to the package, not the monorepo root
local function find_package_root(path)
  if not path then
    path = vim.api.nvim_buf_get_name(0)
  end
  local ctx = find_jest_context(path)
  return ctx.root
end

require("neotest").setup({
  log_level = vim.log.levels.DEBUG,
  -- Custom root function that finds the package root (where jest.config is)
  -- This prevents neotest from scanning the entire monorepo
  root = function(path)
    return find_package_root(path)
  end,
  adapters = {
    require("neotest-jest")({
      -- Use the same logic as vim-test for finding jest executable
      jestCommand = function(path)
        local ctx = find_jest_context(path)
        local bin = ctx.bin or "jest"
        -- Build command exactly like vim-test does
        local cmd = {
          "node",
          "--experimental-vm-modules",
          "--no-warnings",
          bin,
          "--runInBand",
          "--detectOpenHandles",
        }
        if ctx.config then
          table.insert(cmd, "--config")
          table.insert(cmd, ctx.config)
        end
        -- Debug logging
        vim.notify("Neotest Jest Command: " .. vim.inspect(cmd), vim.log.levels.INFO)
        return cmd
      end,
      jestConfigFile = function(path)
        local ctx = find_jest_context(path)
        vim.notify("Neotest Config File: " .. (ctx.config or "none"), vim.log.levels.INFO)
        return ctx.config
      end,
      cwd = function(path)
        local ctx = find_jest_context(path)
        local cwd = ctx.root or (path and vim.fs.dirname(path)) or vim.fn.getcwd()
        vim.notify("Neotest CWD: " .. cwd, vim.log.levels.INFO)
        return cwd
      end,
      -- Enable discovery - neotest-jest will use Jest's --listTests
      -- This should work now that we have proper cwd and config detection
      jest_test_discovery = true,
      env = {
        NODE_OPTIONS = "--experimental-vm-modules --no-warnings",
      },
    }),
  },
})

