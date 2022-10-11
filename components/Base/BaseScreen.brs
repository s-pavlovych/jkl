sub init()
    initSubvies()    
end sub

sub setupScreen()
    generalConfig(m.top.screenId)
end sub

sub initSubvies()
    m.navigationStack = m.top.findNode("navigationStack")
end sub

function pop(params = invalid)
    m.navigationStack.callFunc("pop", params)
    count = m.navigationStack.callFunc("screensCount", params)
    if count = 0
        m.top.setFocus(true)
    end if
end function

function showScreen(screen)
    m.navigationStack.callFunc("showScreen", screen)
end function

function getScreensCount(params = invalid)
    count = m.navigationStack.callFunc("screensCount", params)
    return count
end function

sub showLoadingIndicator(show)
    scene = m.top.getScene()
    scene.callFunc("showLoadingIndicator", show)
end sub