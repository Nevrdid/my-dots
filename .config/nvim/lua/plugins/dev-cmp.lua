return {
   { 'hrsh7th/cmp-nvim-lsp' },
   { 'hrsh7th/cmp-buffer' },
   { 'hrsh7th/cmp-path' },
   { 'hrsh7th/cmp-cmdline' },
   {
      "L3MON4D3/LuaSnip",
      -- follow latest release.
      version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      -- install jsregexp (optional!).
      build = "make install_jsregexp",
      dependencies = {
         "rafamadriz/friendly-snippets",
         'saadparwaiz1/cmp_luasnip'
      },
   },
   {
      'hrsh7th/nvim-cmp',
      config = function()
         local cmp = require 'cmp'
         require("luasnip.loaders.from_vscode").lazy_load()
         local has_words_before = function()
            unpack = unpack or table.unpack
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
         end

         local luasnip = require("luasnip")
         cmp.setup({
            snippet = {
               -- REQUIRED - you must specify a snippet engine
               expand = function(args)
                  --vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                  require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                  -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                  -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
               end,
            },
            window = {
               -- completion = cmp.config.window.bordered(),
               -- documentation = cmp.config.window.bordered(),
            },
            mapping = {
               ['<C-k>'] = cmp.mapping.select_prev_item(),
               ['<C-j>'] = cmp.mapping.select_next_item(),
               ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
               ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
               ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
               ['<C-e>'] = cmp.mapping.abort(),
               ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
               ["<Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                     cmp.select_next_item()
                     -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                     -- that way you will only jump inside the snippet region
                  elseif luasnip.expand_or_jumpable() then
                     luasnip.expand_or_jump()
                  elseif has_words_before() then
                     cmp.complete()
                  else
                     fallback()
                  end
               end, { "i", "s" }),

               ["<S-Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                     cmp.select_prev_item()
                  elseif luasnip.jumpable(-1) then
                     luasnip.jump(-1)
                  else
                     fallback()
                  end
               end, { "i", "s" }),

            },
            sources = cmp.config.sources({
               { name = 'nvim_lsp' },
               -- { name = 'vsnip' }, -- For vsnip users.
               { name = 'luasnip' }, -- For luasnip users.
               -- { name = 'ultisnips' }, -- For ultisnips users.
               -- { name = 'snippy' }, -- For snippy users.
            }, {
               { name = 'buffer' },
            },
            {
               { name = 'path' },
            })
         })

         -- Set configuration for specific filetype.
         cmp.setup.filetype('gitcommit', {
            sources = cmp.config.sources({
               { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
            }, {
               { name = 'buffer' },
            })
         })

         -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
         cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
               { name = 'buffer' }
            }
         })

         -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
         cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
               { name = 'path' }
            }, {
               { name = 'cmdline' }
            })
         })
      end
   },
}
