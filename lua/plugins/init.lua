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
  { -- language support
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("*", {})
      vim.lsp.enable {
        "lua_ls",
        "pylsp",
        "ts_ls",
        "json_lsp",
      }
    end,
  },
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
        "yamlfmt",
        "yaml-language-server",
      },
    },
  },
  {
    "Elive/nvim-nvchad-base46",
  },
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
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  {
    "folke/snacks.nvim",
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup {
        -- Size can be a number (cells) or a function (percentage)
        size = function(term)
          if term.direction == "horizontal" then
            return 20
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.5
          end
        end,
        hide_numbers = true, -- Hide line numbers in terminal
        shade_terminals = false, -- IMPORTANT: Set to false to avoid the bluish tint
        insert_mappings = true, -- Whether open mapping applies in insert mode
        terminal_mappings = true, -- Whether open mapping applies in terminal mode
        start_in_insert = true,
        close_on_exit = true,
      }
    end,
  },
}
