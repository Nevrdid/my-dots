return {
   "nevrdid/hypr_tmux.nvim",
   config = function()
      require("tmux").setup({
         copy_sync = {
            enable = true,
            redurect_to_clipboard = false,
            sync_clipboard = false,
         },
         navigation = {
            enable_default_keybindings = true,
            cycle_navigation = false,
         },
         resize = {
            enable_default_keybindings = true,
         },
      })
   end
}
