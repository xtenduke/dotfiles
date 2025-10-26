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
-- Run nearest test
map("n", "<leader>tn", ":TestNearest<CR>", { desc = "Run nearest test" })
-- Run all tests in current file
map("n", "<leader>tf", ":TestFile<CR>", { desc = "Run tests in file" })
-- Run entire test suite
map("n", "<leader>ts", ":TestSuite<CR>", { desc = "Run test suite" })
-- Re-run last test
map("n", "<leader>tl", ":TestLast<CR>", { desc = "Run last test" })
-- Jump to last test file
map("n", "<leader>tv", ":TestVisit<CR>", { desc = "Visit last test file" })
