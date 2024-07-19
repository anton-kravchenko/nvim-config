return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },
  {
    "williamboman/nvim-lsp-installer",
  },
  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  --
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "typescript",
        "javascript",
        "html-lsp",
        "css-lsp",
        "prettier",
      },
    },
  },
  --
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
      },
    },
  },
  {
    "jvgrootveld/telescope-zoxide",
  },
  { "sbdchd/neoformat" },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { position = "right", width = 85, multiline = true },
  },
  {
    "lewis6991/gitsigns.nvim",
  },
  {
    "ojroques/nvim-hardline",
  },
  {
    "yamatsum/nvim-cursorline",
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  },
  {
    "tpope/vim-surround",
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  },
}
