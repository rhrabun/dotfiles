-- Panes
rex.bind("alt+h", "pane.focus.left")
rex.bind("alt+j", "pane.focus.down")
rex.bind("alt+k", "pane.focus.up")
rex.bind("alt+l", "pane.focus.right")

-- Tabs
rex.bind("cmd+shift+t", "client.tab.new")
rex.bind("ctrl+alt+j", "client.tab.next")
rex.bind("ctrl+alt+k", "client.tab.previous")

-- Sessions
rex.bind("ctrl+alt+r", "session.rename")
rex.bind("ctrl+alt+l", "session.next")
rex.bind("ctrl+alt+h", "session.previous")
