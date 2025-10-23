require("nvchad.configs.lspconfig").defaults()

-- EXAMPLE
local servers = { "html", "cssls", "pyright", "ts_ls", "tailwindcss"}
vim.lsp.enable(servers)
