-- General
rex.bind("cmd+alt+p", "pane.insert_path")

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

-- Resize mode: alt+r, then hjkl or arrows; shift for bigger steps, esc/enter to confirm
rex.mode("resize", { exclusive = true })
rex.bind("alt+r", "client.mode.enter", { name = "resize" })

rex.bind("resize/h", "pane.resize", { direction = "left" })
rex.bind("resize/j", "pane.resize", { direction = "down" })
rex.bind("resize/k", "pane.resize", { direction = "up" })
rex.bind("resize/l", "pane.resize", { direction = "right" })

rex.bind("resize/shift+h", "pane.resize", { direction = "left", amount = 15 })
rex.bind("resize/shift+j", "pane.resize", { direction = "down", amount = 15 })
rex.bind("resize/shift+k", "pane.resize", { direction = "up", amount = 15 })
rex.bind("resize/shift+l", "pane.resize", { direction = "right", amount = 15 })

rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/down", "pane.resize", { direction = "down" })

rex.bind("resize/=", "pane.balance")
rex.bind("resize/escape", "client.mode.exit")
rex.bind("resize/enter", "client.mode.exit")
