local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init

require("cmp").setup {
  sources = {
    { name = "nvim_lsp" },
  },
}
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require "lspconfig"
local servers = { "html", "cssls" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

local function on_attach_without_focus_grab(client, bufnr)
  on_attach(client, bufnr)

  if client.name == "tsserver" or client.name == "ts_ls" then
    local orig = vim.lsp.util.open_floating_preview
    vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
      opts = opts or {}
      opts.focusable = false
      return orig(contents, syntax, opts, ...)
    end
  end
end

lspconfig.ts_ls.setup {
  on_attach = on_attach_without_focus_grab,
  on_init = on_init,
  capabilities = capabilities,
}
