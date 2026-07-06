keymap("Kitty tab switching", {
    C("RC-1"):                  C("Ctrl-Shift-1"),              # Go to tab 1
    C("RC-2"):                  C("Ctrl-Shift-2"),              # Go to tab 2
    C("RC-3"):                  C("Ctrl-Shift-3"),              # Go to tab 3
    C("RC-4"):                  C("Ctrl-Shift-4"),              # Go to tab 4
    C("RC-5"):                  C("Ctrl-Shift-5"),              # Go to tab 5
    C("RC-6"):                  C("Ctrl-Shift-6"),              # Go to tab 6
    C("RC-7"):                  C("Ctrl-Shift-7"),              # Go to tab 7
    C("RC-8"):                  C("Ctrl-Shift-8"),              # Go to tab 8
    C("RC-9"):                  C("Ctrl-Shift-9"),              # Go to tab 9
}, when = lambda ctx:
    cnfg.screen_has_focus and
    hmp_is_term_kitty(ctx)
)

keymap("Poppy launcher", {
    # RC-Space = physical Alt+Space via Toshy. Send Alt+Space so GNOME passes it to Poppy.
    # Overrides the default RC-Space → Alt-F1 app menu mapping in General GUI.
    # No window-class restriction — Poppy should open from everywhere including terminals.
    C("RC-Space"):              C("Alt-Space"),                 # Open Poppy launcher
}, when = lambda ctx:
    cnfg.screen_has_focus
)

keymap("Chrome tabs", {
    # General GUI has no RC-W/RC-T mapping for browsers; terminals remap these to Ctrl+Shift+*.
    # Chrome uses plain Ctrl+W/Ctrl+T.
    C("RC-W"):                  C("C-W"),                       # Close tab (Alt+W)
    C("RC-T"):                  C("C-T"),                       # New tab (Alt+T)
}, when = lambda ctx:
    cnfg.screen_has_focus and
    hmp_is_browser(ctx)
)
