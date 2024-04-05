return {
  {
    'stevearc/dressing.nvim',
    opts = {},
  },
  {
    'mrded/nvim-lsp-notify',
    dependencies = { 'rcarriga/nvim-notify' },
    config = function()
      require('lsp-notify').setup({
        notify = require('notify'),
      })
    end
  },
  {
    "Zeioth/tokyonight.nvim",
    event = "User LoadColorSchemes",
    opts = {
      dim_inactive = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    }
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      --require('gruvbox').setup()
    end
  },
  { "rebelot/kanagawa.nvim" },
  {
    "zeioth/heirline-components.nvim",
    opts = {
      icons = require("icons.nerd_font")
    }
  },
  {
    "rebelot/heirline.nvim",
    dependencies = { "zeioth/heirline-components.nvim" },
    event = "User BaseDefered",
    opts = function()
      local lib = require "heirline-components.all"
      return {
        opts = {
          disable_winbar_cb = function(args) -- We do this to avoid showing it on the greeter.
            local is_disabled = not require("heirline-components.buffer").is_valid(args.buf) or
                lib.condition.buffer_matches({
                  buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
                  filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
                }, args.buf)
            return is_disabled
          end,
        },
        tabline = { -- UI upper bar
          lib.component.tabline_conditional_padding(),
          lib.component.tabline_buffers(),
          lib.component.fill { hl = { bg = "tabline_bg" } },
          lib.component.tabline_tabpages()
        },
        winbar = { -- UI breadcrumbs bar
          init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
          fallthrough = false,
          -- Winbar for terminal, neotree, and aerial.
          {
            condition = function() return not lib.condition.is_active() end,
            {
              lib.component.neotree(),
              lib.component.compiler_play(),
              lib.component.fill(),
              lib.component.compiler_build_type(),
              lib.component.compiler_redo(),
              lib.component.aerial(),
            },
          },
          -- Regular winbar
          {
            lib.component.neotree(),
            lib.component.compiler_play(),
            lib.component.fill(),
            lib.component.breadcrumbs(),
            lib.component.fill(),
            lib.component.compiler_redo(),
            lib.component.aerial(),
          }
        },
        statuscolumn = { -- UI left column
          init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
          lib.component.foldcolumn(),
          lib.component.numbercolumn(),
          lib.component.signcolumn(),
        } or nil,
        statusline = { -- UI statusbar
          hl = { fg = "fg", bg = "bg" },
          lib.component.mode(),
          lib.component.git_branch(),
          lib.component.file_info(),
          lib.component.git_diff(),
          lib.component.diagnostics(),
          lib.component.fill(),
          lib.component.cmd_info(),
          lib.component.fill(),
          lib.component.lsp(),
          lib.component.compiler_state(),
          lib.component.virtual_env(),
          lib.component.nav(),
          lib.component.mode { surround = { separator = "right" } },
        },
      }
    end,
    config = function(_, opts)
      local heirline = require("heirline")
      local heirline_components = require "heirline-components.all"

      -- Setup
      heirline_components.init.subscribe_to_events()
      heirline.load_colors(heirline_components.hl.get_colors())
      heirline.setup(opts)
    end,
  },
  -- {
  --   'nvim-lualine/lualine.nvim',
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   opts = {
  --     options = {
  --       theme = 'dracula'
  --     }
  --   }
  -- },
  {
    "goolord/alpha-nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.startify")
      dashboard.section.header.val = {
        [[     /\__\         /\  \         /\  \         /\__\          ___        /\__\    ]],
        [[    /::|  |       /::\  \       /::\  \       /:/  /         /\  \      /::|  |   ]],
        [[   /:|:|  |      /:/\:\  \     /:/\:\  \     /:/  /          \:\  \    /:|:|  |   ]],
        [[  /:/|:|  |__   /::\~\:\  \   /:/  \:\  \   /:/__/  ___      /::\__\  /:/|:|__|__ ]],
        [[ /:/ |:| /\__\ /:/\:\ \:\__\ /:/__/ \:\__\  |:|  | /\__\  __/:/\/__/ /:/ |::::\__\]],
        [[ \/__|:|/:/  / \:\~\:\ \/__/ \:\  \ /:/  /  |:|  |/:/  / /\/:/  /    \/__/~~/:/  /]],
        [[     |:/:/  /   \:\ \:\__\    \:\  /:/  /   |:|__/:/  /  \::/__/           /:/  / ]],
        [[     |::/  /     \:\ \/__/     \:\/:/  /     \::::/__/    \:\__\          /:/  /  ]],
        [[     /:/  /       \:\__\        \::/  /       ~~~~         \/__/         /:/  /   ]],
        [[     \/__/         \/__/         \/__/                                   \/__/    ]],
      }
      alpha.setup(dashboard.opts)
    end
  },
  {
    "echasnovski/mini.indentscope",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      draw = { delay = 0, animation = function() return 0 end },
      options = { border = "top", try_as_border = true },
      symbol = "▏",
    },
    config = function(_, opts)
      require("mini.indentscope").setup(opts)

      -- Disable for certain filetypes
      vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "Disable indentscope for certain filetypes",
        callback = function()
          local ignored_filetypes = {
            "aerial",
            "dashboard",
            "help",
            "lazy",
            "leetcode.nvim",
            "mason",
            "neo-tree",
            "NvimTree",
            "neogitstatus",
            "notify",
            "startify",
            "toggleterm",
            "Trouble",
            "calltree"
          }
          if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
            vim.b.miniindentscope_disable = true
          end
        end,
      })
    end
  },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    config = function()
      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

      -- Option 2: nvim lsp as LSP client
      -- Tell the server the capability of foldingRange,
      -- Neovim hasn't added foldingRange to default capabilities, users must add it manually
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }
      local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
      for _, ls in ipairs(language_servers) do
        require('lspconfig')[ls].setup({
          capabilities = capabilities
          -- you can add other fields for setting up lsp server in this table
        })
      end
      require('ufo').setup()
    end
  }
}
