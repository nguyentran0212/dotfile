require "nvchad.options"

-- add yours here!

local o = vim.o
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.relativenumber = true
vim.opt.clipboard = "unnamedplus"
