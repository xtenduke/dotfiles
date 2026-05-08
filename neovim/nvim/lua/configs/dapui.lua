local dap = require "dap"
local dapui = require "dapui"

dapui.setup {
  layouts = {
    {
      -- Left panel: variables, watches, breakpoints (like WebStorm's Variables tab)
      elements = {
        { id = "scopes",      size = 0.50 },
        { id = "watches",     size = 0.25 },
        { id = "breakpoints", size = 0.25 },
      },
      size = 40,
      position = "left",
    },
    {
      -- Bottom panel: call stack + console
      elements = {
        { id = "stacks",  size = 0.50 },
        { id = "console", size = 0.50 },
      },
      size = 12,
      position = "bottom",
    },
  },
}

-- Auto-open/close UI with the debug session
dap.listeners.before.attach.dapui_config    = function() dapui.open() end
dap.listeners.before.launch.dapui_config    = function() dapui.open() end
dap.listeners.after.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.after.event_exited.dapui_config     = function() dapui.close() end
