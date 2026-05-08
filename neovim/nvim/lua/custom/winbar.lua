local M = {}
local api = vim.api

vim.o.showtabline = 0

local function setup_hl()
  api.nvim_set_hl(0, "WinbarActive",   { fg = "#ffffff", sp = "#61afef", underline = true, bold = true })
  api.nvim_set_hl(0, "WinbarInactive", { fg = "#5c6370" })
end
setup_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_hl })

local exclude_ft = {
  "NvimTree", "neo-tree", "qf", "TelescopePrompt",
  "neotest-summary", "dap-repl", "dapui_scopes",
  "dapui_breakpoints", "dapui_stacks", "dapui_watches",
}

-- Window ID is baked into the winbar string so this function always knows
-- which window it's rendering for, regardless of which window is focused.
_G.WinbarBufs = function(win)
  local ok, bufs = pcall(api.nvim_win_get_var, win, "split_bufs")
  local cur = api.nvim_win_get_buf(win)
  if not ok or not bufs or #bufs == 0 then
    local name = vim.fn.fnamemodify(api.nvim_buf_get_name(cur), ":t")
    return name ~= "" and ("%#WinbarInactive# " .. name .. " %*") or ""
  end
  local parts = {}
  for _, buf in ipairs(bufs) do
    if api.nvim_buf_is_valid(buf) then
      local name = vim.fn.fnamemodify(api.nvim_buf_get_name(buf), ":t")
      if name == "" then name = "[No Name]" end
      local mod = vim.bo[buf].modified and " ●" or ""
      if buf == cur then
        table.insert(parts, "%#WinbarActive# " .. name .. mod .. " %*")
      else
        table.insert(parts, "%#WinbarInactive# " .. name .. mod .. " %*")
      end
    end
  end
  return table.concat(parts, "")
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype
    if vim.tbl_contains(exclude_ft, ft) or bt ~= "" then
      vim.wo.winbar = nil
      return
    end
    local win = api.nvim_get_current_win()
    local buf = api.nvim_get_current_buf()
    local ok, bufs = pcall(api.nvim_win_get_var, win, "split_bufs")

    if not ok then
      -- Window has no list yet — check if the buffer is already visible in
      -- another window, which means this is an inherited split copy, not a
      -- file the user explicitly opened here.
      local inherited = false
      for _, w in ipairs(api.nvim_list_wins()) do
        if w ~= win and api.nvim_win_get_buf(w) == buf then
          inherited = true
          break
        end
      end
      if inherited then
        -- Start an empty list so future opens are tracked normally
        api.nvim_win_set_var(win, "split_bufs", {})
        vim.wo.winbar = "%!v:lua.WinbarBufs(" .. win .. ")"
        return
      end
      bufs = {}
    end

    if vim.bo[buf].buflisted and not vim.tbl_contains(bufs, buf) then
      table.insert(bufs, buf)
      api.nvim_win_set_var(win, "split_bufs", bufs)
    end
    vim.wo.winbar = "%!v:lua.WinbarBufs(" .. win .. ")"
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args)
    for _, win in ipairs(api.nvim_list_wins()) do
      local ok, bufs = pcall(api.nvim_win_get_var, win, "split_bufs")
      if ok and bufs then
        for i, buf in ipairs(bufs) do
          if buf == args.buf then
            table.remove(bufs, i)
            api.nvim_win_set_var(win, "split_bufs", bufs)
            break
          end
        end
      end
    end
    vim.cmd "redrawstatus!"
  end,
})

M.nav = function(dir)
  local win = api.nvim_get_current_win()
  local ok, bufs = pcall(api.nvim_win_get_var, win, "split_bufs")
  if not ok or not bufs or #bufs == 0 then return end
  local cur = api.nvim_win_get_buf(win)
  local idx
  for i, buf in ipairs(bufs) do
    if buf == cur then idx = i; break end
  end
  if not idx then api.nvim_set_current_buf(bufs[1]); return end
  local next_idx = dir == "next"
    and ((idx == #bufs) and 1 or idx + 1)
    or  ((idx == 1) and #bufs or idx - 1)
  api.nvim_set_current_buf(bufs[next_idx])
end

M.close = function()
  local win = api.nvim_get_current_win()
  local ok, bufs = pcall(api.nvim_win_get_var, win, "split_bufs")
  if not ok then bufs = {} end
  local cur = api.nvim_win_get_buf(win)
  if #bufs > 1 then
    local idx
    for i, buf in ipairs(bufs) do
      if buf == cur then idx = i; break end
    end
    local next_idx = (idx and idx > 1) and (idx - 1) or 2
    api.nvim_set_current_buf(bufs[next_idx])
    pcall(api.nvim_buf_delete, cur, { force = false })
  else
    vim.cmd "close"
  end
end

return M
