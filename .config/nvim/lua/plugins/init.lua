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
  			"vim", "lua", "vimdoc", "html", "css",
  		},
      highlight = {
        disable = {"markdown_inline", "markdown", "latex"}
      }, 
      indent = {
        enable = true
      }
  	},
  },
  {
    "lervag/vimtex",
    init = function()
      -- vim.g.vimtex_view_general_viewer = "okular"
      vim.g.vimtex_fold_enabled = 1
      vim.g.vimtex_complete_enabled = 0
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
  }
}
