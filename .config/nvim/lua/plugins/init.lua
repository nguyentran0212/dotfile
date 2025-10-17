return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
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
      },
      highlight = {
        disable = { "markdown_inline", "markdown", "latex" },
      },
      indent = {
        enable = true,
      },
    },
  },
  {
    "lervag/vimtex",
    init = function()
      -- vim.g.vimtex_view_general_viewer = "okular"
      vim.g.vimtex_fold_enabled = 1
      vim.g.vimtex_complete_enabled = 0
    end,
  },
  {
    "ggml-org/llama.vim",
    lazy=false,
    init = function()
      vim.g.llama_config = {
        endpoint = "http://100.86.233.127:8080/infill",
        model = "Qwen3-30B-A3B-Instruct-2507-UD-Q4_K_XL",
        auto_fim = false,
      }
    end,
  },
}
