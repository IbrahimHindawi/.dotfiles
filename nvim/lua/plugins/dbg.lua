return {
    'mfussenegger/nvim-dap',
    dependencies = {
        'rcarriga/nvim-dap-ui',
        'nvim-neotest/nvim-nio',
    },
    config = function ()
        local dap = require('dap')
        local dapui = require('dapui')
        dapui.setup()
        dap.adapters.codelldb = {
            type = "executable",
            command = "codelldb",
            detached = false,
        }
        dap.configurations.c = {
            {
                name = "Launch",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input('path to exe: ', vim.fn.getcwd() .. '/build', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
            },
        }
        -- dap.adapters.cppdbg = {
        --     id = 'cppdbg',
        --     type = 'executable',
        --     command = 'C:\\ms-vscode.cpptools-1.23.2\\extension\\debugAdapters\\bin\\OpenDebugAD7.exe',
        --     options = {
        --         detached = false,
        --     }
        -- }
        -- dap.configurations.c = {
        --   {
        --     name = "Launch file",
        --     type = "cppdbg",
        --     request = "launch",
        --     program = function()
        --       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build', 'file')
        --     end,
        --     cwd = '${workspaceFolder}',
        --     stopAtEntry = true,
        --   },
        -- }
        -- dap.configurations.c = dap.configurations.cpp
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
        vim.keymap.set('n', '<Leader>d', '', {desc = 'Debug'})
        vim.keymap.set('n', '<Leader>dd', function() dap.disconnect() end, {desc = 'Disconnect'})
        vim.keymap.set('n', '<Leader>dc', function() dap.continue() end, {desc = 'Continue'})
        vim.keymap.set('n', '<Leader>dl', function() dap.step_over() end, {desc = 'Step Over'})
        vim.keymap.set('n', '<Leader>dj', function() dap.step_into() end, {desc = 'Step Into'})
        vim.keymap.set('n', '<Leader>dk', function() dap.step_out() end, {desc = 'Step Out'})
        vim.keymap.set('n', '<Leader>db', function() dap.toggle_breakpoint() end, {desc = 'Toggle Breakpoint'})
        vim.keymap.set('n', '<Leader>dr', function() dap.run_last() end, {desc = 'Run Last'})
        vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
          require('dap.ui.widgets').hover()
        end, {desc = 'hover'})
        vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
          require('dap.ui.widgets').preview()
        end, {desc = 'preview'})
    end
}
