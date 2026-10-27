-- General
rex.bind("cmd+alt+p", "pane.insert_path")
rex.bind("cmd+shift+.", "client.sidebar.activity.toggle")

-- Panes
rex.bind("alt+h", "pane.focus.left")
rex.bind("alt+j", "pane.focus.down")
rex.bind("alt+k", "pane.focus.up")
rex.bind("alt+l", "pane.focus.right")

-- Tabs
rex.bind("cmd+alt+r", "client.tab.rename")

rex.bind("ctrl+alt+j", "client.tab.next")
rex.bind("ctrl+alt+k", "client.tab.previous")

-- Sessions
rex.bind("cmd+shift+r", "session.rename")

rex.bind("ctrl+alt+l", "session.next")
rex.bind("ctrl+alt+h", "session.previous")

-- Zellij-style modes
rex.bind("ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("ctrl+h", "client.mode.enter", { name = "move" })
rex.bind("ctrl+n", "client.mode.enter", { name = "resize" })
rex.bind("ctrl+o", "client.mode.enter", { name = "session" })

for _, name in ipairs({ "pane", "tab", "resize", "move", "session" }) do
  rex.mode(name, { exclusive = true })
  rex.bind(name .. "/enter", "client.mode.exit")
  rex.bind(name .. "/esc", "client.mode.exit")
end

-- Run an action, then leave the mode
rex.action{
  name  = "then_exit",
  title = "Once",
  args  = { action = "string", args = "object?" },
  run   = function(ctx, a)
    rex.client.queue(a.action, a.args)
    rex.client.queue("client.mode.exit")
  end,
}

-- Pane mode
rex.bind("pane/h", "pane.focus.left")
rex.bind("pane/j", "pane.focus.down")
rex.bind("pane/k", "pane.focus.up")
rex.bind("pane/l", "pane.focus.right")
rex.bind("pane/;", "pane.focus_next")
rex.bind("pane/p", "pane.focus_previous")
rex.bind("pane/n", "then_exit", { action = "pane.split.auto" })
rex.bind("pane/d", "then_exit", { action = "pane.split", args = { direction = "down" } })
rex.bind("pane/r", "then_exit", { action = "pane.split", args = { direction = "right" } })
rex.bind("pane/x", "then_exit", { action = "pane.close" })
rex.bind("pane/f", "then_exit", { action = "pane.zoom" })
rex.bind("pane/w", "then_exit", { action = "pane.float" })

-- Tab mode
rex.bind("tab/n", "then_exit", { action = "client.tab.new" })
rex.bind("tab/x", "then_exit", { action = "client.tab.close" })
rex.bind("tab/r", "then_exit", { action = "client.tab.rename" })
rex.bind("tab/h", "client.tab.previous")
rex.bind("tab/l", "client.tab.next")
rex.bind("tab/b", "then_exit", { action = "pane.move_to_new_tab" })

-- Resize mode
rex.bind("resize/h", "pane.resize", { direction = "left" })
rex.bind("resize/j", "pane.resize", { direction = "down" })
rex.bind("resize/k", "pane.resize", { direction = "up" })
rex.bind("resize/l", "pane.resize", { direction = "right" })

rex.bind("resize/shift+h", "pane.resize", { direction = "left", amount = 15 })
rex.bind("resize/shift+j", "pane.resize", { direction = "down", amount = 15 })
rex.bind("resize/shift+k", "pane.resize", { direction = "up", amount = 15 })
rex.bind("resize/shift+l", "pane.resize", { direction = "right", amount = 15 })

rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/down", "pane.resize", { direction = "down" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/right", "pane.resize", { direction = "right" })

rex.bind("resize/=", "pane.balance")

-- Move mode
rex.bind("move/h", "pane.move.left")
rex.bind("move/j", "pane.move.down")
rex.bind("move/k", "pane.move.up")
rex.bind("move/l", "pane.move.right")

rex.bind("move/left", "pane.move.left")
rex.bind("move/down", "pane.move.down")
rex.bind("move/up", "pane.move.up")
rex.bind("move/right", "pane.move.right")

rex.bind("move/n", "pane.move_to_new_tab")

-- Session mode
rex.bind("session/r", "session.rename")
rex.bind("session/h", "session.previous")
rex.bind("session/l", "session.next")
rex.bind("session/left", "session.previous")
rex.bind("session/right", "session.next")
rex.bind("session/tab", "session.next")
rex.bind("session/w", "session.switch")
