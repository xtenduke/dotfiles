local M = {}

local ns      = vim.api.nvim_create_namespace("custom_blame")
local ns_cur  = vim.api.nvim_create_namespace("custom_blame_cursor")
local enabled = false
local cache   = {}  -- bufnr -> { max_sha, data = { [lnum] = { author, time, summary, sha } } }
local autocmd_id = nil

local DEFAULT_STC = vim.o.statuscolumn  -- capture before we change it

-- Cycling palette of muted background colours for commit groups
local PALETTE = {
  "#1a3a5c", "#1a4a2e", "#4a1a2e", "#4a3a1a", "#2e1a4a", "#1a4a4a",
}

-- Highlights
local function set_hl()
  vim.api.nvim_set_hl(0, "BlameCursor", { fg = "#9ca3af", italic = true })
  -- per-commit group highlights are created dynamically in build_hl_map()
end
set_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

-- Returns { sha -> hl_group_name }, creating highlight groups as needed
local function build_hl_map(data, max_sha)
  local seen  = {}
  local idx   = 0
  local map   = {}
  -- stable order: walk lines 1..n so colour assignment is deterministic
  local lnums = vim.tbl_keys(data)
  table.sort(lnums)
  for _, lnum in ipairs(lnums) do
    local sha = data[lnum].sha
    if not seen[sha] then
      local name = "BlameGroup" .. idx
      local bg   = PALETTE[(idx % #PALETTE) + 1]
      local fg   = (sha == max_sha) and "#e6edf3" or "#8b949e"
      local bold = (sha == max_sha)
      vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg, bold = bold, italic = true })
      seen[sha] = name
      idx = idx + 1
    end
    map[sha] = seen[sha]
  end
  return map
end

local function fmt_date(timestamp)
  return os.date("%d/%m/%y", tonumber(timestamp))
end

-- Called by statuscolumn expression for each line
function M.stc()
  if not enabled then return "" end
  local bufnr = vim.api.nvim_get_current_buf()
  local entry = cache[bufnr]
  if not entry then return "          " end
  local info = entry.data[vim.v.lnum]
  if not info then return "          " end
  local date = info.time and fmt_date(info.time) or "?"
  local hl   = entry.hl_map[info.sha] or "BlameDate"
  return "%#" .. hl .. "#" .. date .. " %#Normal#"
end

local function set_statuscolumn(on)
  if on then
    -- date gutter | signs | line number (right-aligned) + padding
    vim.o.statuscolumn = "%{%v:lua.require('custom.blame').stc()%}%s%=%l  "
  else
    vim.o.statuscolumn = DEFAULT_STC
  end
end

local function parse_porcelain(raw)
  local result = {}
  local lines  = vim.split(raw, "\n", { plain = true })
  local i      = 1
  while i <= #lines do
    local sha, final = lines[i]:match("^(%x+) %d+ (%d+)")
    if sha then
      local lnum = tonumber(final)
      local info = {}
      i = i + 1
      while i <= #lines and not lines[i]:match("^\t") do
        local k, v = lines[i]:match("^([%w%-]+) (.+)")
        if k then info[k] = v end
        i = i + 1
      end
      result[lnum] = {
        sha     = sha,
        author  = info.author or "Unknown",
        time    = tonumber(info["author-time"]),
        summary = info.summary or "",
      }
    end
    i = i + 1
  end
  return result
end

local function find_max_sha(data)
  local max_time, max_sha = 0, nil
  for _, info in pairs(data) do
    if info.time and info.time > max_time then
      max_time = info.time
      max_sha  = info.sha
    end
  end
  return max_sha
end

local function fetch(bufnr, cb)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then return end
  vim.fn.jobstart({ "git", "blame", "--line-porcelain", path }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.schedule(function() cb(parse_porcelain(table.concat(data, "\n"))) end)
      end
    end,
  })
end

local function render_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum  = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_clear_namespace(bufnr, ns_cur, 0, -1)

  local entry = cache[bufnr]
  if not entry then return end
  local info = entry.data[lnum]
  if not info then return end

  vim.api.nvim_buf_set_extmark(bufnr, ns_cur, lnum - 1, 0, {
    virt_text     = { { "  " .. info.summary .. "  — " .. info.author, "BlameCursor" } },
    virt_text_pos = "eol",
  })
end

function M.toggle()
  enabled = not enabled
  local bufnr = vim.api.nvim_get_current_buf()

  if enabled then
    fetch(bufnr, function(parsed)
      local max_sha = find_max_sha(parsed)
      cache[bufnr] = { data = parsed, max_sha = max_sha, hl_map = build_hl_map(parsed, max_sha) }
      set_statuscolumn(true)
      vim.cmd "redraw!"
      render_cursor()
    end)
    autocmd_id = vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      callback = render_cursor,
    })
  else
    if autocmd_id then
      vim.api.nvim_del_autocmd(autocmd_id)
      autocmd_id = nil
    end
    cache = {}
    set_statuscolumn(false)
    vim.api.nvim_buf_clear_namespace(bufnr, ns_cur, 0, -1)
    vim.cmd "redraw!"
  end
end

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(ev)
    if enabled then
      fetch(ev.buf, function(parsed)
        local max_sha = find_max_sha(parsed)
        cache[ev.buf] = { data = parsed, max_sha = max_sha, hl_map = build_hl_map(parsed, max_sha) }
        vim.cmd "redraw!"
        render_cursor()
      end)
    end
  end,
})

vim.api.nvim_create_user_command("BlameToggle", M.toggle, {})

return M
