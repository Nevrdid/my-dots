local opt = vim.opt
_G.core = {}

-- Theme
core.default_colorscheme = "kanagawa-wave"
--opt.background = 'dark'
opt.termguicolors = true
opt.signcolumn = "yes"

-- GENERAL
opt.shell = "/sbin/bash"
opt.clipboard:append("unnamedplus")
opt.mouse = "a"
opt.undofile = true


-- HELP
opt.cursorline = true
opt.cursorlineopt = "number"
opt.wrap = false
opt.number = true
opt.relativenumber = true
opt.laststatus = 3
opt.backspace = "indent,eol,start"

-- SYNTAX
opt.tabstop = 2
opt.shiftwidth = 2
opt.autoindent = true
opt.expandtab = true

---
opt.softtabstop = 2
opt.smartindent = true
opt.shiftround = true

-- SEARCHING
opt.ignorecase = true
opt.smartcase = true

-- FOLDING
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99
opt.conceallevel = 2
