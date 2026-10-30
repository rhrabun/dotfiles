-- Zellij-style modes

-- Leave the mode before running the action
rex.action{
  name  = "one_shot",
  title = "⏏",
  args  = { action = "string", args = "object?" },
  run   = function(ctx, a)
    rex.client.queue("client.mode.exit")
    rex.client.queue(a.action, a.args)
  end,
}

-- Pane mode
rex.bind("ctrl+p", "client.mode.enter", { name = "pane" })

rex.bind("pane/h", "pane.focus.left")
rex.bind("pane/j", "pane.focus.down")
rex.bind("pane/k", "pane.focus.up")
rex.bind("pane/l", "pane.focus.right")

rex.bind("pane/p", "pane.focus_next")
rex.bind("pane/;", "pane.focus_previous")

rex.bind("pane/n", "one_shot", { action = "pane.split.auto" })
rex.bind("pane/d", "one_shot", { action = "pane.split", args = { direction = "down" } })
rex.bind("pane/r", "one_shot", { action = "pane.split", args = { direction = "right" } })

rex.bind("pane/x", "one_shot", { action = "pane.close" })
rex.bind("pane/f", "one_shot", { action = "pane.zoom" })
rex.bind("pane/w", "one_shot", { action = "pane.float" })

rex.bind("pane/m", "one_shot", { action = "pane.minimize_floating" })
rex.bind("pane/shift+m", "one_shot", { action = "pane.minimize_all_floating" })

rex.bind("pane/b", "one_shot", { action = "pane.move_to_new_tab" })

-- Tab mode
rex.bind("ctrl+t", "client.mode.enter", { name = "tab" })

rex.bind("tab/n", "one_shot", { action = "client.tab.new" })
rex.bind("tab/x", "one_shot", { action = "client.tab.close" })
rex.bind("tab/r", "one_shot", { action = "client.tab.rename" })

rex.bind("tab/h", "client.tab.previous")
rex.bind("tab/l", "client.tab.next")
rex.bind("tab/j", "client.tab.next")
rex.bind("tab/k", "client.tab.previous")
rex.bind("tab/down", "client.tab.next")
rex.bind("tab/up", "client.tab.previous")
rex.bind("tab/left", "client.tab.previous")
rex.bind("tab/right", "client.tab.next")

rex.bind("tab/shift+h", "client.tab.move.backward")
rex.bind("tab/shift+l", "client.tab.move.forward")
rex.bind("tab/shift+k", "client.tab.move.backward")
rex.bind("tab/shift+j", "client.tab.move.forward")
rex.bind("tab/b", "one_shot", { action = "pane.move_to_new_tab" })

-- Resize mode
rex.bind("ctrl+n", "client.mode.enter", { name = "resize" })

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
rex.bind("ctrl+h", "client.mode.enter", { name = "move" })

rex.bind("move/h", "pane.move.left")
rex.bind("move/j", "pane.move.down")
rex.bind("move/k", "pane.move.up")
rex.bind("move/l", "pane.move.right")

rex.bind("move/left", "pane.move.left")
rex.bind("move/down", "pane.move.down")
rex.bind("move/up", "pane.move.up")
rex.bind("move/right", "pane.move.right")

rex.bind("move/n", "one_shot", { action = "pane.move_to_new_tab" })

-- Session mode
rex.bind("ctrl+o", "client.mode.enter", { name = "session" })

rex.bind("session/c", "one_shot", { action = "client.settings" })
rex.bind("session/r", "one_shot", { action = "session.rename" })
rex.bind("session/w", "one_shot", { action = "session.switch" })

rex.bind("session/j", "session.next")
rex.bind("session/k", "session.previous")
rex.bind("session/l", "session.next")
rex.bind("session/h", "session.previous")

rex.bind("session/tab", "session.next")
rex.bind("session/shift+tab", "session.previous")
rex.bind("session/right", "session.next")
rex.bind("session/left", "session.previous")
rex.bind("session/down", "session.next")
rex.bind("session/up", "session.previous")

-- Exit mode
for _, name in ipairs({ "tab", "pane", "resize", "move", "session" }) do
  rex.mode(name, { exclusive = true })
  for _, key in ipairs({ "enter", "esc", "ctrl+c" }) do
    rex.bind(name .. "/" .. key, "client.mode.exit")
  end
end
