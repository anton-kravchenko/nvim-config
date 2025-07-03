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
        "kotlin-language-server",
        "python",
        "black",
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
        "kotlin",
        "python",
        "javascript",
        "typescript",
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
    "terrortylor/nvim-comment",
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  },
  {
    "https://github.com/nvim-telescope/telescope-live-grep-args.nvim",
  },
  {
    "averms/black-nvim",
  },
  {
    "MunifTanjim/nui.nvim",
  },
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood",
  },
  {
    "vinnymeller/swagger-preview.nvim",
    cmd = { "SwaggerPreview", "SwaggerPreviewStop", "SwaggerPreviewToggle" },
    build = "npm i",
    config = true,
  },
}
