sub init()
    registerView()
end sub

sub registerView()
    m.nameItemLabel = m.top.findNode("nameItem")
    m.nameItemLabel.font.size = 35
    m.iconShows = m.top.findNode("iconForShow")
    m.focusItem = m.top.findNode("focusItem")
    m.failLabel = m.top.findNode("failItem")
    m.focus = false
end sub

sub addContent() 
    m.iconShows.uri = "pkg:/images/" + m.top.itemContent.title + ".png"
    m.nameItemLabel.text = tr(m.top.itemContent.title)
    m.failLabel.text = m.top.itemContent.title
    bounding = m.nameItemLabel.boundingRect()
    labelWidth = bounding["width"]
    
    m.nameItemLabel.width = labelWidth
    m.focusItem.width = 45 + labelWidth + 45
    if m.top.itemHasFocus
        m.focusItem.visible = true
        m.focusItem.blendColor = "#C4C4C4"
        m.iconShows.uri = "pkg:/images/" + "focus" + m.top.itemContent.title + ".png"
        m.nameItemLabel.color = "#0646A5"        
    end if
end sub

sub showfocus(event)
    if m.top.itemHasFocus
        m.focusItem.blendColor = "#C4C4C4"
        bounding = m.nameItemLabel.boundingRect()
        labelWidth = bounding["width"]
        m.iconShows.uri = "pkg:/images/" + "focus" + m.failLabel.text + ".png"
        m.nameItemLabel.color = "#0646A5"
        m.focusItem.visible = true
    else 
        if not m.top.height
            m.iconShows.uri = "pkg:/images/" + m.failLabel.text + ".png"
            m.nameItemLabel.color = "#2C2E35"
        end if
        m.focusItem.blendColor = "#FFFFFF"
    end if
end sub

sub changeHeightFocuse(event) 
    ? "5"
    m.focusItem.blendColor = "#C4C4C4"
    ' m.focusItem.visible = true
    selected = event.getData()
    m.iconShows.uri = "pkg:/images/" + "focus" + m.failLabel.text + ".png"
    m.nameItemLabel.color = "#0646A5"
end sub    