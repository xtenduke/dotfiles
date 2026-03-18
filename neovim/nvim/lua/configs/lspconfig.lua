require("nvchad.configs.lspconfig").defaults()

-- Override NvChad's diagnostic config
vim.diagnostic.config {
  underline = true,
  virtual_text = { prefix = "" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN]  = "W",
      [vim.diagnostic.severity.INFO]  = "I",
      [vim.diagnostic.severity.HINT]  = "H",
    },
  },
  update_in_insert = false,
}

local servers = { "html", "cssls", "ts_ls" }

local nvlsp = require "nvchad.configs.lspconfig"
vim.lsp.enable(servers)

vim.lsp.config("eslint", {
  cmd = {
    vim.fn.expand "~/.local/share/nvim/mason/bin/vscode-eslint-language-server",
    "--stdio",
  },
  -- nvim 0.11 root_dir: receives (bufnr, on_dir) — must call on_dir(path)
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local util = require "lspconfig.util"
    local root = util.find_git_ancestor(fname)
      or util.root_pattern(
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        "package.json"
      )(fname)
      or vim.fn.getcwd()
    on_dir(root)
  end,
  settings = {
    workingDirectory = { mode = "auto" },
    run = "onType",
    experimental = { useFlatConfig = false },
  },
})
vim.lsp.enable "eslint"



-- csharp with csharp-ls
-- vim.lsp.enable('csharp_ls')
-- vim.lsp.enable('omnisharp')
vim.lsp.config("roslyn", {})


-- read :h vim.lsp.config for changing options of lsp servers 
