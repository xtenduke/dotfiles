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
