sub init()
    registerView()
end sub

sub registerView()
    m.container = m.top.findNode("container")
    m.btnText = m.top.findNode("btn_text")
    m.errorText = m.top.findNode("errorText")
    m.errorDiscribe = m.top.findNode("errorDiscribe")
    m.background = m.top.findNode("background")
    centralizeGroup()
end sub

sub centralizeGroup()
    m.errorText.font = getFontForChannel(m.global.selectedChannel.objectID, 48, "bold")
    m.btnText.font = getFontForChannel(m.global.selectedChannel.objectID, 38, "bold")
    m.errorDiscribe.font = getFontForChannel(m.global.selectedChannel.objectID, 30, "light")
    m.container.translation = [m.background.width / 2 - m.container.boundingRect().width / 2, m.background.height / 2 - m.container.boundingRect().height / 2]
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    handled = true
    if press then
        if key = "OK" or key = "back"
            m.top.erroBtnClicekd = true
        end if
    end if
    return handled
end function