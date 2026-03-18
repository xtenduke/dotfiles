require "nvchad.options"

-- add yours here!


-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!


-- Set diagnostic underline colors after colorscheme loads
local function set_diagnostic_highlights()
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { sp = "#e06c75", undercurl = true, underline = true })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn",  { sp = "#888888", undercurl = true, underline = true })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo",  { sp = "#888888", undercurl = true, underline = true })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint",  { sp = "#888888", undercurl = true, underline = true })
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  callback = set_diagnostic_highlights,
})
