require "nvchad.options"

-- add yours here!

local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
--
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.lsp.foldexpr()"
