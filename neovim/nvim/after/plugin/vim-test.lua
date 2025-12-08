-- Match multi-dot files like basic.ac.spec.ts
local js_file_pattern = [[\v(.+)\.(test|spec)\.(js|jsx|ts|tsx)$]]
vim.g["test#javascript#jest#file_pattern"] = js_file_pattern

-- Default runner/strategy
vim.g["test#javascript#runner"] = "jest"
vim.g["test#strategy"] = "neovim"
vim.g["test#preserve_screen"] = 1

-- Walk upwards from the buffer dir (and cwd fallback) to find the nearest
-- node_modules/.bin/jest. Falls back to a global jest if none are found.
local function find_nearest_jest()
  local candidates = {
    vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    vim.fn.getcwd(),
  }

  for _, root in ipairs(candidates) do
    if root and root ~= "" then
      local match = vim.fs.find({ "node_modules/.bin/jest" }, {
        path = root,
        upward = true,
      })[1]

      if match and vim.fn.filereadable(match) == 1 then
        return match
      end
    end
  end

  if vim.fn.executable("jest") == 1 then
    return "jest"
  end
end

local function set_jest_executable()
  local bin = find_nearest_jest() or "jest"
  -- Mirror CLI flags you use in package.json scripts
  local cmd = ("node --experimental-vm-modules --no-warnings %s"):format(
    vim.fn.shellescape(bin)
  )
  vim.g["test#javascript#jest#executable"] = cmd
end

local function find_jest_root()
  local buf_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local cwd = vim.fn.getcwd()
  local roots = { buf_dir, cwd }
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
  }

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

  local exe = find_nearest_jest()
  if exe and exe:find("node_modules/.bin/jest", 1, true) then
    return vim.fs.dirname(vim.fs.dirname(exe))
  end
end

-- Set project root so Jest runs from the nearest config or package dir
vim.g["test#project_root"] = function()
  return find_jest_root() or vim.fn.getcwd()
end

-- Default Jest options aligned with your npm script
vim.g["test#javascript#jest#options"] = "--detectOpenHandles"

-- Seed once, then keep up to date as you move around the repo
set_jest_executable()
vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = set_jest_executable,
})

