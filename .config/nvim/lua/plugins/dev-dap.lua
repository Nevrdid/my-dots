return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    }
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
      vim.keymap.set('n', '<Leader>db', function() dap.toggle_breakpoint() end, { desc = "Toogle breakpoint" })
      vim.keymap.set('n', '<Leader>dl', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
        { desc = "Set log breakpoint" })
      vim.keymap.set('n', '<Leader>dc', function() dap.continue() end, { desc = "Continue debuging" })

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          -- provide the absolute path for `codelldb` command if not using the one installed using `mason.nvim`
          command = "codelldb",
          args = { "--port", "${port}" },

          -- On windows you may have to uncomment this:
          -- detached = false,
        },
      }

      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            local path
            vim.ui.input({ prompt = "Path to executable: ", default = vim.loop.cwd() .. "/build/" }, function(input)
              path = input
            end)
            vim.cmd [[redraw]]
            return path
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      dap.configurations.c = dap.configurations.cpp
    end
  }
}
