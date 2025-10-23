require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "j", "gj")
map("n", "k", "gk")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "<leader>ae", function()
  setAutoCmp(true)
end, {desc = "Enable auto-completion for current buffer"})
map("n", "<leader>ad", function()
  setAutoCmp(false)
end, {desc = "Disable auto-completion for current buffer"})

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
