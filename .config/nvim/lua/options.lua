require "nvchad.options"

-- add yours here!

local o = vim.o
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.opt.clipboard = "unnamedplus"
