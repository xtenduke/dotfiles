require "nvchad.options"

-- add yours here!
vim.o.foldenable = false
vim.o.exrc = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- Right-click context menu — append after NvChad finishes setting up the menu
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("custom.blame") -- ensure module + command are registered
    vim.cmd "anoremenu PopUp.-GitSep- <Nop>"
    vim.cmd "anoremenu PopUp.Git\\ Blame\\ Toggle :BlameToggle<CR>"
  end,
})


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

require "custom.winbar"
