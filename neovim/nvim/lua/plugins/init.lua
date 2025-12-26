return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "c_sharp",
      },
    },
  },
  -- Vim test
  {
    "vim-test/vim-test",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    cmd = { "TestNearest", "TestFile", "TestSuite", "TestLast", "TestVisit" },
    config = function()
      vim.g["test#strategy"] = "neovim"
      vim.g["test#preserve_screen"] = 1
    end,
  },
  -- Tweaking mason https://git.ramboe.io/YouTube/neovim-c-the-actually-improved-configuration-2025-roslynnvim-rzslnvim/
  {
    "williamboman/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ensure_installed = {
        "lua-language-server",
        "xmlformatter",
        "csharpier",
        "prettier",
        "stylua",
        "bicep-lsp",
        "html-lsp",
        "css-lsp",
        "eslint-lsp",
        "typescript-language-server",
        "json-lsp",
        "rust-analyzer",

        -- !
        "roslyn",
        "rzls",
        -- "csharp-language-server",
        -- "omnisharp",
      },
    },
  },
  {
    "seblyng/roslyn.nvim",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    ft = { "cs", "razor" },
    opts = {
      -- your configuration comes here; leave empty for default settings
    },
  },

  -- DAP + test debugging
  {
    "mfussenegger/nvim-dap",
    config = function()
      require "configs.dap"
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed = { "js-debug-adapter" },
      automatic_installation = true,
      handlers = {},
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-jest",
      "antoinemadec/FixCursorHold.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require "configs.neotest"
    end,
  },
}
