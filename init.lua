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
vim.opt.scrolloff = 5
vim.opt.cursorline = true
vim.opt.swapfile = false
vim.incsearch = true

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
      vim.api.nvim_buf_delete(i, { force = true })
    end
  end
end

local telescope = require "telescope"
telescope.setup {
  extensions = {
    zoxide = {
      prompt_title = "[ Choose directory ]",
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

require("nvim-tree").setup {
  disable_netrw = false,
  update_cwd = true,
  update_focused_file = {
    enable = true,
  },
  view = {
    width = 35,
  },
}

telescope.load_extension "zoxide"
vim.keymap.set("n", "<leader>cd", telescope.extensions.zoxide.list, { desc = "Opens zoxide directory search" })
vim.keymap.set("n", "tkm", ":Telescope keymaps<CR>", { desc = "Opens Telescope keybindings" })

-- Shows list of all errors from LSP
local trouble = require "trouble"
vim.keymap.set("n", "<leader>tt", ":Trouble diagnostics toggle<CR>")
-- LSP
vim.keymap.set("n", "<leader>ge", vim.diagnostic.open_float, { desc = "Show diagnostic [e]rror message" })
vim.keymap.set("n", "<leader>g[", vim.diagnostic.goto_prev, { desc = "Go to previus [d]iagnostic message" })
vim.keymap.set("n", "<leader>g]", vim.diagnostic.goto_next, { desc = "Go to next [d]iagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open [d]iagnostic quick fix" })
vim.keymap.set("n", "KL", vim.diagnostic.setloclist, { desc = "Opens variable type hover" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Opens variable type hover" })

-- Moving selected text
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- Quickfix
vim.keymap.set("n", "<leader>j", "<cmd>cprev<CR>")
vim.keymap.set("n", "<leader>k", "<cmd>cnext<CR>")

-- Delete without replacing clipboard contents
vim.keymap.set("v", "<leader>p", '"_dp')

-- Quit
vim.keymap.set("n", "<leader>qa", ":wqa<CR>", { desc = "Save all and quit" })

-- Navigation
vim.keymap.set("n", "m", "4j")
vim.keymap.set("n", ",", "4k")

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

vim.keymap.set("n", "<leader>gs", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "git-status",
    cmd = "git status",
    float_opts = {
      row = 0.1,
      col = 0.15,
      width = 0.7,
      height = 0.7,
      border = "single",
    },
  }
end, { desc = "Open terminal and run `git status`" })

vim.keymap.set("n", "<leader>tw", function()
  require("nvchad.term").toggle { pos = "vsp", id = "test:watch", size = 0.5, cmd = "npm run test:watch" }
end, { desc = "Open terminal and run `npm run test:watch`" })

vim.keymap.set("n", "<leader>tr", function()
  require("nvchad.term").toggle { pos = "vsp", id = "terminal", size = 0.5 }
end, { desc = "Open Te[r]minal" })

-- Exit insert mode in terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Status line
local background = "#171b20"
local text_color = "#00f788"

require("hardline").setup {
  theme = "custom",
  custom_theme = {
    inactive_comment = { gui = background },
    inactive_cursor = { gui = background },
    inactive_menu = { gui = background },
    text = { gui = text_color },
    normal = { gui = background },
    insert = { gui = background },
    replace = { gui = background },
    visual = { gui = background },
    command = { gui = background },
    alt_text = { gui = text_color },
    warning = { gui = background },
  },
}

vim.schedule(function()
  require "mappings"
end)

require("nvim-cursorline").setup()

require("nvim-surround").setup()
require("nvim_comment").setup()

-- Opens LSP references in the same view as open file
vim.keymap.set("n", "<leader>gr", function()
  vim.lsp.buf.references(nil, { loclist = true })
end, { desc = "Open [r]eferences" })

require("lsp_lines").setup()

vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Open Terminal",
  group = vim.api.nvim_create_augroup("open-terminal", { clear = true }),
  callback = function()
    vim.opt.relativenumber = false
    vim.opt.number = false
  end,
})

vim.keymap.set("n", "<leader>st", function()
  vim.cmd "vsp"
  vim.cmd.term()
  vim.cmd "vertical resize 85"
end)

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 100
vim.opt.foldnestmax = 4

local telescope_builtin = require "telescope.builtin"
vim.keymap.set("n", "<leader>fs", function()
  telescope_builtin.live_grep {
    default_text = " ",
    search_dirs = { vim.fn.getcwd() .. "/src" },
  }
end, { desc = "Live grep in ./src folder" })

vim.keymap.set("n", "<leader>sth", function()
  local hints = require "cheat_sheet_hints"
  hints.show_hints_of_the_day()
end, { desc = "[S]how [t]odays [h]ints" })
