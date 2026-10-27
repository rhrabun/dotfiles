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
