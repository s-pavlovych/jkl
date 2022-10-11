sub init()
    m.top.focusable = true
end sub

function showScreen(screen as object, animated = true)
    if screen <> invalid
        screen.callFunc("screenWillShow", animated)
        if screen <> invalid
            screen.observeField("backTapped", "onScreenBackTapped")
            m.top.appendChild(screen)
            screen.callFunc("screenDidShow", animated)
            screen.setFocus(true)
            screen.focusKey = screen.focusKey
        end if
    end if
end function

function showError(errorObject as object, animated = true)
    if errorObject <> invalid
        if errorObject <> invalid
            ' do smth
        end if
    end if
end function

function pop(animated = invalid)
    ? "function pop"
    lastIndex = m.top.getChildCount() - 1
    m.top.removeChildIndex(lastIndex)
    if lastIndex <> 0
        lastScreen = m.top.getChild(lastIndex - 1)
        lastScreen.callFunc("screenWillShow", animated)
        lastScreen.setFocus(true)
        lastScreen.focusKey = lastScreen.focusKey
        lastScreen.callFunc("screenDidShow", animated)    
    end if
end function


function pop2(animated = invalid)
? "function pop2(animated)"
    lastIndex = m.top.getChildCount() - 1
    m.top.removeChildIndex(lastIndex)
    m.top.removeChildIndex(lastIndex-1)
    if lastIndex <> 0
        lastScreen = m.top.getChild(lastIndex - 2)
        lastScreen.callFunc("screenWillShow", animated)
        lastScreen.setFocus(true)
        lastScreen.focusKey = lastScreen.focusKey
        lastScreen.callFunc("screenDidShow", animated)
    end if
end function

function popToRoot(animated = invalid)
    m.top.removeChildrenIndex(1000, 1)
end function

function topScreen(animated)
    count = screensCount()
    return m.top.getChild(count - 1)
end function


function screensCount(screen = invalid)
    if m.top.getChildCount() <> invalid
        return m.top.getChildCount()
    end if
    return 0
end function

function screens(screen = invalid)
    return m.top.getChildren( - 1, 0)
end function

function back(params)
    count = screensCount()
    lastScreen = screens()[count - 1]
    if count = 1    
    else
        pop(true)
    end if
end function

sub onScreenBackTapped(event)
    ? "sub onScreenBackTapped(event)"
    count = screensCount()
end sub