; Toggle window transparency on the current window with Win+Escape.
#Esc::
    WinGet, TransLevel, Transparent, A
    if (TransLevel = OFF) {
        WinSet, Transparent, 200, A
    } else {
        WinSet, Transparent, OFF, A
    }
return
