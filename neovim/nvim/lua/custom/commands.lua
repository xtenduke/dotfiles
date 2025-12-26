-- Format
vim.api.nvim_create_user_command("Format", function()
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.notify("Conform.nvim is not loaded!", vim.log.levels.ERROR)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  conform.format { bufnr = bufnr }
end, {
  desc = "Format current file with Conform",
  nargs = 0, -- no arguments required
})

-- Debug Jest context for current file
vim.api.nvim_create_user_command("DebugJest", function()
  _G.DebugJestContext()
end, {
  desc = "Debug Jest context detection for current file",
})

-- Test Jest command manually
vim.api.nvim_create_user_command("TestJestCommand", function()
  local file = vim.api.nvim_buf_get_name(0)
  local ctx = _G.DebugJestContext(file)
  local bin = ctx.bin or "jest"
  local cmd = {
    "node",
    "--experimental-vm-modules",
    "--no-warnings",
    bin,
    "--listTests",
    "--runInBand",
  }
  if ctx.config then
    table.insert(cmd, "--config")
    table.insert(cmd, ctx.config)
  end
  
  local cmd_str = table.concat(cmd, " ")
  vim.notify("Command: " .. cmd_str, vim.log.levels.INFO)
  vim.notify("CWD: " .. ctx.root, vim.log.levels.INFO)
  print("\n=== Run this command manually ===")
  print("cd " .. ctx.root)
  print(cmd_str)
  print("================================")
end, {
  desc = "Show Jest command that would be run",
})

-- Debug neotest discovery
vim.api.nvim_create_user_command("DebugNeotest", function()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    vim.notify("Neotest not loaded!", vim.log.levels.ERROR)
    return
  end
  
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file open!", vim.log.levels.ERROR)
    return
  end
  
  vim.notify("Testing neotest discovery for: " .. file, vim.log.levels.INFO)
  
  -- Try to get positions using the correct API
  local ok_positions, positions = pcall(function()
    local client = neotest.get_state()
    if client then
      return client:get_position(file)
    end
    return nil
  end)
  
  if ok_positions and positions then
    vim.notify("Found positions: " .. vim.inspect(positions), vim.log.levels.INFO)
    print("Positions:", vim.inspect(positions))
  else
    vim.notify("No positions found or error: " .. tostring(positions), vim.log.levels.WARN)
  end
  
  -- Check if file is discoverable
  local ok_discover, discovered = pcall(function()
    -- Try to run discovery manually
    return neotest.run.run({ file })
  end)
  
  if ok_discover then
    vim.notify("Discovery attempted", vim.log.levels.INFO)
  else
    vim.notify("Discovery error: " .. tostring(discovered), vim.log.levels.WARN)
  end
end, {
  desc = "Debug neotest discovery for current file",
})
