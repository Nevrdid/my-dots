-- EVERY TIME NEOVIM OPENS:
-- Compile lua to bytecode if the nvim version supports it.
if vim.loader and vim.fn.has "nvim-0.9.1" == 1 then vim.loader.enable() end

-- Source config files by order.
for _, source in ipairs {
  "core.autocmds",
  "core.keymaps",
  "core.lazy",
  "core.opts",
} do
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
end


-- ONCE ALL SOURCE FILES HAVE LOADED:
-- Load the color scheme defined in ./lua/core/opts.lua
if core.default_colorscheme then
  pcall(vim.cmd.colorscheme, core.default_colorscheme)
end
