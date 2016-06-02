# Get rid of the alt-menu shortcuts
atom.menu.template.forEach (t) ->
   t.label = "Find" if t.label == "F&ind"
atom.menu.update()
