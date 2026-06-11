require "nvchad.mappings"

local map = vim.keymap.set
local winbar = require "custom.winbar"

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Per-split buffer navigation
map("n", "<C-h>", function() winbar.nav("prev") end, { desc = "Previous buffer in split" })
map("n", "<C-l>", function() winbar.nav("next") end, { desc = "Next buffer in split" })
map("n", "<leader>bq", winbar.close, { desc = "Close buffer in split" })


-- Searching
local builtin = require "telescope.builtin"
map("n", "<leader>o", builtin.find_files, { desc = "Search for files" })
map("n", "<leader>f", builtin.live_grep, { desc = "Search inside files" })
map("n", "<C-o>", builtin.find_files, { desc = "Search for files" })
map("n", "<C-f>", builtin.live_grep, { desc = "Fuzzy search whole directory" })
map("n", "n", "nzz", { desc = "Next search match (centered)" })
map("n", "N", "Nzz", { desc = "Prev search match (centered)" })
map("n", "<CR>", "nzz", { desc = "Next search match (centered)" })
map("n", "<Esc>", "<cmd>nohl<CR>", { desc = "Clear search highlights" })

-- Vim test
map("n", "<leader>t", ":TestNearest<CR>", { desc = "Run nearest test" })
map("n", "<leader>T", ":TestFile<CR>", { desc = "Run tests in file" })
map("n", "<leader>a", ":TestSuite<CR>", { desc = "Run all tests" })
map("n", "<leader>l", ":TestLast<CR>", { desc = "Re-run last test" })
map("n", "<leader>g", ":TestVisit<CR>", { desc = "Go to last test file" })
map("t", "<C-o>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Git
map("n", "<leader>gb", ":BlameToggle<CR>", { desc = "Toggle git blame" })

-- LSP specific (gd/gr/gi set via LspAttach in lspconfig.lua to beat NvChad's buffer-local mappings)
map("n", "K", vim.lsp.buf.hover, { desc = "Show hover info" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>f", function()
  vim.lsp.buf.format { async = true }
end, { desc = "Format file" })
map("v", "<leader>f", vim.lsp.buf.format, { desc = "Format selection" })
local hidden_actions = {
  "disable prettier",
  "show documentation",
  "move to a new file",
  "extract to type alias",
  "generate 'get' and 'set' accessors",
}

local function filter_code_actions(action)
  local title = action.title:lower()
  for _, pattern in ipairs(hidden_actions) do
    if title:find(pattern, 1, true) then return false end
  end
  return true
end

map("n", "<leader>qf", function()
  vim.lsp.buf.code_action { filter = filter_code_actions }
end, { desc = "Quick fix / code action" })
map("v", "<leader>qf", function()
  vim.lsp.buf.code_action { filter = filter_code_actions }
end, { desc = "Code action (visual)" })

-- Redo with Shift+U
map("n", "U", "<C-r>", { desc = "Redo" })

-- Shift+HJKL for faster movement (5x)
map("n", "H", "5h", { desc = "Move left fast" })
map("n", "J", "5j", { desc = "Move down fast" })
map("n", "K", "5k", { desc = "Move up fast" })
map("n", "L", "5l", { desc = "Move right fast" })

-- Smart paste: re-indent pasted text to match surrounding context
-- Uses '[  '] marks that Neovim sets automatically after a paste
map("n", "p", "p=`]", { desc = "Paste and re-indent" })
map("n", "P", "P=`[", { desc = "Paste above and re-indent" })

-- copilot
-- Copilot Suggestion Acceptance Key
map('i', '<leader>i', function ()
    vim.fn.feedkeys(vim.fn['copilot#Accept'](), '')
end, { desc = 'Copilot Accept', noremap = true, silent = true })
