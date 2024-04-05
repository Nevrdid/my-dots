return {
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          --null_ls.builtins.formatting.stylua,
          --null_ls.builtins.formatting.clang_format,
          --null_ls.builtins.diagnostics.gccdiag,
          null_ls.builtins.formatting.fish_indent,
          null_ls.builtins.diagnostics.fish,
          null_ls.builtins.formatting.shfmt,
          null_ls.builtins.formatting.black,
        },
      })
    end
  },
  {
    "p00f/clangd_extensions.nvim",
    config = function()
      require("clangd_extensions").setup({
        inlay_hints = {
          inline = vim.fn.has("nvim-0.10") == 1,
          -- Options other than `highlight' and `priority' only work
          -- if `inline' is disabled
          -- Only show inlay hints for the current line
          only_current_line = false,
          -- Event which triggers a refresh of the inlay hints.
          -- You can make this { "CursorMoved" } or { "CursorMoved,CursorMovedI" } but
          -- not that this may cause  higher CPU usage.
          -- This option is only respected when only_current_line and
          -- autoSetHints both are true.
          only_current_line_autocmd = { "CursorHold" },
          -- whether to show parameter hints with the inlay hints or not
          show_parameter_hints = true,
          -- prefix for parameter hints
          parameter_hints_prefix = "<- ",
          -- prefix for all the other hints (type, chaining)
          other_hints_prefix = "=> ",
          -- whether to align to the length of the longest line in the file
          max_len_align = false,
          -- padding from the left if max_len_align is true
          max_len_align_padding = 1,
          -- whether to align to the extreme right or not
          right_align = false,
          -- padding from the right if right_align is true
          right_align_padding = 7,
          -- The color of the hints
          highlight = "Comment",
          -- The highlight group priority for extmark
          priority = 100,
        },
        ast = {
          -- These are unicode, should be available in any font
          role_icons = {
            type = "🄣",
            declaration = "🄓",
            expression = "🄔",
            statement = ";",
            specifier = "🄢",
            ["template argument"] = "🆃",
          },
          kind_icons = {
            Compound = "🄲",
            Recovery = "🅁",
            TranslationUnit = "🅄",
            PackExpansion = "🄿",
            TemplateTypeParm = "🅃",
            TemplateTemplateParm = "🅃",
            TemplateParamObject = "🅃",
          },
          --[[ These require codicons (https://github.com/microsoft/vscode-codicons)
            role_icons = {
                type = "",
                declaration = "",
                expression = "",
                specifier = "",
                statement = "",
                ["template argument"] = "",
            },

            kind_icons = {
                Compound = "",
                Recovery = "",
                TranslationUnit = "",
                PackExpansion = "",
                TemplateTypeParm = "",
                TemplateTemplateParm = "",
                TemplateParamObject = "",
            }, ]]

          highlights = {
            detail = "Comment",
          },
        },
        memory_usage = {
          border = "none",
        },
        symbol_info = {
          border = "none",
        },
      })
    end
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
      require("mason-nvim-dap").setup()
    end
  },
  {
    "folke/neodev.nvim",
    config = function()
      require("neodev").setup({});
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "pyright", "perlnavigator" }
    }
  },
  { 'tikhomirov/vim-glsl' },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = 'Lua 5.4',
              path = {
                '?.lua',
                '?/init.lua',
                vim.fn.expand '~/.luarocks/share/lua/5.4/?.lua',
                vim.fn.expand '~/.luarocks/share/lua/5.4/?/init.lua',
                '/usr/share/lua/5.4/?.lua',
                '/usr/share/lua/5.4/?/init.lua'
              }
            },
            workspace = {
              library = {
                vim.fn.expand '~/.luarocks/share/lua/5.4',
                '/usr/share/lua/5.4'
              }
            }
          }
        }
      }
      )
      lspconfig.lemminx.setup({ capabilities = capabilities })
      lspconfig.perlnavigator.setup({
        capabilities = capabilities,
        cmd = { "node", "/home/narnaud/.local/share/nvim/mason/packages/perlnavigator/node_modules/perlnavigator-server/out/server.js", "--stdio" },
        settings = {
          perlnavigator = {
            includePaths = { "~/perl5/lib/perl5/" },
            perlPath = "perl",
            enableWarnings = true,
            perltidyProfile = '',
            perlcriticProfile = '',
            perlcriticEnabled = true,
          }
        }
      })

      -- some settings can only passed as commandline flags, see `clangd --help`
      local clangd_flags = {
        "--background-index",
        "--fallback-style=Google",
        "--all-scopes-completion",
        "--clang-tidy",
        "--log=error",
        "--suggest-missing-includes",
        "--cross-file-rename",
        "--completion-style=detailed",
        "--pch-storage=memory",     -- could also be disk
        "--folding-ranges",
        "--enable-config",          -- clangd 11+ supports reading from .clangd configuration file
        "--offset-encoding=utf-16", --temporary fix for null-ls
        -- "--limit-references=1000",
        -- "--limit-resutls=1000",
        -- "--malloc-trim",
        -- "--clang-tidy-checks=-*,llvm-*,clang-analyzer-*,modernize-*,-modernize-use-trailing-return-type",
        -- "--header-insertion=never",
        -- "--query-driver=<list-of-white-listed-complers>"
      }

      local provider = "clangd"

      local status_ok, project_config = pcall(require, "rhel.clangd_wrl")
      if status_ok then
        clangd_flags = vim.tbl_deep_extend("keep", project_config, clangd_flags)
      end
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = { provider, unpack(clangd_flags) },
        on_attach = function(client, bufnr)
          require("vim.lsp").common_on_attach(client, bufnr)

          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "<leader>lh", "<cmd>ClangdSwitchSourceHeader<cr>", opts)
          vim.keymap.set("x", "<leader>lA", "<cmd>ClangdAST<cr>", opts)
          vim.keymap.set("n", "<leader>lH", "<cmd>ClangdTypeHierarchy<cr>", opts)
          vim.keymap.set("n", "<leader>lt", "<cmd>ClangdSymbolInfo<cr>", opts)
          vim.keymap.set("n", "<leader>lm", "<cmd>ClangdMemoryUsage<cr>", opts)

          require("clangd_extensions.inlay_hints").setup_autocmd()
          require("clangd_extensions.inlay_hints").set_inlay_hints()
        end,
        on_init = function(client, bufnr)
          require("vim.lsp").common_on_init(client, bufnr)
          require("clangd_extensions.config").setup {}
          require("clangd_extensions.ast").init()
          vim.cmd [[
              command ClangdToggleInlayHints lua require('clangd_extensions.inlay_hints').toggle_inlay_hints()
              command -range ClangdAST lua require('clangd_extensions.ast').display_ast(<line1>, <line2>)
              command ClangdTypeHierarchy lua require('clangd_extensions.type_hierarchy').show_hierarchy()
              command ClangdSymbolInfo lua require('clangd_extensions.symbol_info').show_symbol_info()
              command -nargs=? -complete=customlist,s:memuse_compl ClangdMemoryUsage lua require('clangd_extensions.memory_usage').show_memory_usage('<args>' == 'expand_preamble')
          ]]
        end
      })


      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.bashls.setup({ capabilities = capabilities })
      lspconfig.glsl_analyzer.setup({
        filetypes = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
        capabilities = capabilities
      })
      -- Global mappings.
      -- See `:help vim.diagnostic.s` for documentation on any of the below functions
      vim.keymap.set('n', '<leader>ldo', vim.diagnostic.open_float)
      vim.keymap.set('n', '<leader>ldp', vim.diagnostic.goto_prev)
      vim.keymap.set('n', '<leader>ldn', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<leader>ldq', vim.diagnostic.setloclist)
      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', '<leader>lbD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', '<leader>lbd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', '<leader>lbk', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>lbi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<leader>lbh', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<leader>lwl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '<leader>lbt', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<leader>lbr', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<leader>lbc', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<leader>lbR', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<leader>lbf', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end
      })
    end
  },
}
