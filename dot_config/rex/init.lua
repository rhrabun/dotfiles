-- General
rex.bind("cmd+alt+p", "pane.insert_path")
rex.bind("cmd+shift+.", "client.sidebar.activity.toggle")

-- Panes
rex.bind("alt+h", "pane.focus.left")
rex.bind("alt+j", "pane.focus.down")
rex.bind("alt+k", "pane.focus.up")
rex.bind("alt+l", "pane.focus.right")
rex.bind("alt+;", "pane.focus_next")
rex.bind("alt+p", "pane.focus_previous")

-- Tabs
rex.bind("cmd+r", "client.tab.rename")

rex.bind("ctrl+alt+j", "client.tab.next")
rex.bind("ctrl+alt+k", "client.tab.previous")

-- Sessions
rex.bind("cmd+shift+r", "session.rename")

rex.bind("ctrl+alt+l", "session.next")
rex.bind("ctrl+alt+h", "session.previous")

-- Zellij-style modes
require("modes")
