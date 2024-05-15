vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)
vim.opt.shell = "fish"
vim.opt.relativenumber = true
vim.opt.number = true

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

local function close_buffers(close_all)
  local bufs = vim.api.nvim_list_bufs()
  local current_buf = vim.api.nvim_get_current_buf()

  for _, i in ipairs(bufs) do
    if i ~= current_buf or close_all == true then
      vim.api.nvim_buf_delete(i, {})
    end
  end
end

local telescope = require "telescope"
telescope.setup {
  extensions = {
    zoxide = {
      prompt_title = "[ Walking on the shoulders of TJ ]",
      mappings = {
        default = {
          after_action = function(selection)
            print("Directory changed to " .. selection.path)
            close_buffers(true)

            local nvim_tree = require("nvim-tree.api").tree
            nvim_tree.close()
            nvim_tree.open()
          end,
        },
      },
    },
  },
}

telescope.load_extension "zoxide"
vim.keymap.set("n", "<leader>cd", telescope.extensions.zoxide.list)

-- Shows list of all errors from LSP
local trouble = require "trouble"
vim.keymap.set("n", "<leader>tt", trouble.toggle)

-- LSP
vim.keymap.set("n", "<leader>ge", vim.diagnostic.open_float, { desc = "Show diagnostic [e]rror message" })
vim.keymap.set("n", "<leader>g[", vim.diagnostic.goto_prev, { desc = "Go to previus [d]iagnostic message" })
vim.keymap.set("n", "<leader>g]", vim.diagnostic.goto_next, { desc = "Go to next [d]iagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open [d]iagnostic quick fix" })

-- Navigation
vim.keymap.set("n", "m", "3j")
vim.keymap.set("n", ",", "3k")

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

-- Git
require("gitsigns").setup {
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 1000,
  },
}

-- Status line
require("hardline").setup {
  theme = "default",
}

vim.schedule(function()
  require "mappings"
end)
