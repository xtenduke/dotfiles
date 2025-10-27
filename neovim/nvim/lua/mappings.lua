require "nvchad.mappings"

local map = vim.keymap.set
local tabufline = require "nvchad.tabufline"

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Switch buffers with Ctrl + H / Ctrl + L (NvChad built-in)
map("n", "<C-h>", function()
  tabufline.prev()
end, { desc = "Previous buffer" })

map("n", "<C-l>", function()
  tabufline.next()
end, { desc = "Next buffer" })

-- Searching
local builtin = require "telescope.builtin"
map("n", "<leader>o", builtin.find_files, { desc = "Search for files" })
map("n", "<leader>f", builtin.live_grep, { desc = "Search inside files" })

-- Vim test
map("n", "<leader>t", ":TestNearest<CR>", { desc = "Run nearest test" })
map("n", "<leader>T", ":TestFile<CR>", { desc = "Run tests in file" })
map("n", "<leader>a", ":TestSuite<CR>", { desc = "Run all tests" })
map("n", "<leader>l", ":TestLast<CR>", { desc = "Re-run last test" })
map("n", "<leader>g", ":TestVisit<CR>", { desc = "Go to last test file" })
map("t", "<C-o>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- LSP specific
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Show hover info" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>f", function()
  vim.lsp.buf.format { async = true }
end, { desc = "Format file" })
map("v", "<leader>f", vim.lsp.buf.format, { desc = "Format selection" })
map("n", "<leader>qf", vim.lsp.buf.code_action, { desc = "Quick fix / code action" })
map("v", "<leader>qf", vim.lsp.buf.code_action, { desc = "Code action (visual)" })
