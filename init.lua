local session_tracker = require "session_tracker"
session_tracker.setup().start()

vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootthtrap lazy and all plugins
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
    brnch = "v2.5",
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

local function load_nvim_tree()
  require("nvim-tree").setup {
    filters = {
      dotfiles = false,
    },
    git = {
      enable = true,
      ignore = false,
    },
    disable_netrw = false,
    update_cwd = true,
    update_focused_file = {
      enable = true,
    },
    view = {
      width = 35,
    },
  }
end
load_nvim_tree()

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

            load_nvim_tree()
          end,
        },
      },
    },
  },
}

telescope.load_extension "zoxide"
vim.keymap.set("n", "<leader>cd", telescope.extensions.zoxide.list, { desc = "Opens zoxide directory search" })
vim.keymap.set("n", "tkm", ":Telescope keymaps<CR>", { desc = "Opens Telescope keybindings" })

-- Shows list of all errors from LSP
require "trouble"
vim.keymap.set("n", "<leader>tt", ":Trouble diagnostics toggle<CR>")
-- LSP

local function make_diagnostic_jump(direction)
  return function()
    if direction == "next" then
      vim.diagnostic.jump { count = 1, float = true }
    elseif direction == "previous" then
      vim.diagnostic.jump { count = -1, float = true }
    end
  end
end

vim.keymap.set("n", "<leader>ge", vim.diagnostic.open_float, { desc = "Show diagnostic [e]rror message" })

vim.keymap.set("n", "<leader>g[", make_diagnostic_jump "previous", { desc = "Go to previus [d]iagnostic message" })
vim.keymap.set("n", "<leader>gj", make_diagnostic_jump "previous", { desc = "Go to previus [d]iagnostic message" })

vim.keymap.set("n", "<leader>g]", make_diagnostic_jump "next", { desc = "Go to next [d]iagnostic message" })
vim.keymap.set("n", "<leader>gk", make_diagnostic_jump "next", { desc = "Go to next [d]iagnostic message" })

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open [d]iagnostic quick fix" })
vim.keymap.set("n", "KL", vim.diagnostic.setloclist, { desc = "Opens variable type hover" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Opens variable type hover" })
vim.api.nvim_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { noremap = true, silent = true })

-- Moving selected text
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- Quickfix
vim.keymap.set("n", "<leader>j", "<cmd>cnext<CR>")
vim.keymap.set("n", "<leader>k", "<cmd>cprev<CR>")

-- PWD
vim.keymap.set("n", "pwd", ":pwd<CR>")

-- Delete without replacing clipboard contents
vim.keymap.set("v", "<leader>p", '"_dp')

-- Quit
vim.keymap.set("n", "<leader>qa", ":qa!<CR>", { desc = "Force quit" })

-- Navigation
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

local function jump_and_scroll(jump)
  local cursor_line = vim.fn.line "."
  local lines_in_current_buffer = vim.api.nvim_buf_line_count(0)
  local new_cursor_line = cursor_line + jump

  if new_cursor_line <= lines_in_current_buffer and new_cursor_line > 0 then
    local view = vim.fn.winsaveview()
    view.topline = view.topline + jump
    vim.fn.winrestview(view)

    local cursor_column = vim.fn.col "."
    vim.api.nvim_win_set_cursor(0, { new_cursor_line, cursor_column })
  end
end

vim.keymap.set("n", "m", function()
  jump_and_scroll(5)
end)

vim.keymap.set("n", ",", function()
  jump_and_scroll(-5)
end)

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

-- Folding
vim.opt.foldmethod = "expr"
-- TODO: uncomment
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
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

local function definition_split()
  vim.lsp.buf.definition {
    on_list = function(options)
      if #options.items > 1 then
        vim.notify("Multiple items found, opening first one", vim.log.levels.WARN)
      end

      local item = options.items[1]
      local cmd = "vsplit +" .. item.lnum .. " " .. item.filename .. "|" .. "normal " .. item.col .. "|"

      vim.cmd(cmd)
    end,
  }
end

vim.keymap.set("n", "<leader>gD", definition_split, { desc = "Goto Definition (popup)" })

-- Integrated terminals
local testWatchTerminalConfig =
  { pos = "vsp", id = "test:watch", size = 0.45, cmd = "npm run test:watch", name = "Test watch terminal" }

local terminalConfig = { pos = "vsp", id = "terminal", size = 0.45, name = "Terminal" }

local gitStatusTerminalConfig = {
  pos = "float",
  id = "git-status",
  cmd = "git status",
  float_opts = { row = 0.1, col = 0.15, width = 0.7, height = 0.7, border = "single" },
  name = "Git status terminal",
}

local recent_terminal = nil
local TERMINALS_ARE_HIDDEN = false
local function toggle_terminal(config)
  require("nvchad.term").toggle(config)
  recent_terminal = config
end

vim.keymap.set("n", "<leader>gs", function()
  toggle_terminal(gitStatusTerminalConfig)
end, { desc = "Open terminal and run `git status`" })

vim.keymap.set("n", "<leader>tw", function()
  toggle_terminal(testWatchTerminalConfig)
end, { desc = "Open terminal and run `npm run test:watch`" })

vim.keymap.set("n", "<leader>tr", function()
  toggle_terminal(terminalConfig)
end, { desc = "Open Te[r]minal" })

local function toggle_integrated_terminals()
  if TERMINALS_ARE_HIDDEN == true and recent_terminal then
    toggle_terminal(recent_terminal)
    TERMINALS_ARE_HIDDEN = false
  else
    TERMINALS_ARE_HIDDEN = true
    local terminalConfigs = {
      testWatchTerminalConfig,
      terminalConfig,
      gitStatusTerminalConfig,
    }

    local function id_to_term(id)
      local terms = vim.g.nvchad_terms
      if terms then
        for _, opts in pairs(vim.g.nvchad_terms) do
          if opts.id == id then
            return opts
          end
        end
      else
        print "No hidden terminals"
      end
    end

    for _, t in pairs(terminalConfigs) do
      local x = id_to_term(t.id)

      if (x ~= nil and vim.api.nvim_buf_is_valid(x.buf)) and vim.fn.bufwinid(x.buf) ~= -1 then
        vim.api.nvim_win_close(x.win, true)
      end
    end
  end
end

-- Exit insert mode in terminal
-- vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<leader><leader>", "<C-\\><C-n>")
-- vim.keymap.set("t", "jk", "<C-\\><C-n>")
vim.keymap.set("t", "fd", "<C-\\><C-n>")

-- Quit terminal mode and hide all integrated terminals
vim.keymap.set("t", "<C-Space>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
  toggle_integrated_terminals()
end)

-- Toggle recently opened integrated terminal
vim.keymap.set("n", "<C-Space>", function()
  toggle_integrated_terminals()
end)

vim.keymap.set("n", "ii", function()
  vim.cmd "normal! zz"
end)

-- Quit visual mode
vim.keymap.set("v", "v", "<Esc>", { noremap = true, silent = true })

-- Swager preview
vim.keymap.set("n", "<leader>sp", ":SwaggerPreviewToggle<CR>", { desc = "Toggle swagger preview" })
require("swagger-preview").setup { port = 8000, host = "localhost" }

-- Disable replacing clipboard with the context of replacing text when pasting
vim.keymap.set("x", "p", function()
  return 'pgv"' .. vim.v.register .. "y"
end, { remap = false, expr = true })

-- Session tracker
vim.keymap.set("n", "<leader>sts", ":ST sessions<CR>", { desc = "Shows the list of sessions" })
vim.keymap.set("n", "<leader>stc", ":ST current<CR>", { desc = "Show current session" })
vim.keymap.set("n", "<leader>stt", ":ST show<CR>", { desc = "Show today's timeline" })
