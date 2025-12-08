require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "ts_ls" }

local nvlsp = require "nvchad.configs.lspconfig"
vim.lsp.enable(servers)



-- csharp with csharp-ls
-- vim.lsp.enable('csharp_ls')
-- vim.lsp.enable('omnisharp')
vim.lsp.config("roslyn", {})


-- read :h vim.lsp.config for changing options of lsp servers 
