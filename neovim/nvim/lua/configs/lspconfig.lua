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

vim.lsp.enable "rust_analyzer"

-- csharp with csharp-ls
-- vim.lsp.enable('csharp_ls')
-- vim.lsp.enable('omnisharp')
vim.lsp.config("roslyn", {})


-- Override NvChad's buffer-local LSP mappings so gd/gr/gi use Telescope
-- (buffer-local mappings beat globals, so we need LspAttach to win the race)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = vim.keymap.set
    local buf = args.buf
    local builtin = require "telescope.builtin"
    local dropdown = require("telescope.themes").get_dropdown { previewer = false }

    map("n", "gd", function()
      vim.lsp.buf.definition({
        on_list = function(options)
          local items = options.items
          if #items == 0 then return end
          local first_file = items[1].filename
          local all_same_file = true
          for _, item in ipairs(items) do
            if item.filename ~= first_file then
              all_same_file = false
              break
            end
          end
          vim.fn.setqflist({}, " ", options)
          if all_same_file then
            vim.cmd "cfirst"
          else
            builtin.quickfix(dropdown)
          end
        end,
      })
    end, { buffer = buf, desc = "Go to definition" })
    map("n", "gr", function() builtin.lsp_references(dropdown) end, { buffer = buf, desc = "Find references" })
    map("n", "gi", function() builtin.lsp_implementations(dropdown) end, { buffer = buf, desc = "Go to implementation" })
  end,
})

-- read :h vim.lsp.config for changing options of lsp servers
