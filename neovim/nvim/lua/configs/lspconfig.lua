require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

-- csharp with csharp-ls
vim.lsp.enable('csharp_ls')



-- read :h vim.lsp.config for changing options of lsp servers 
