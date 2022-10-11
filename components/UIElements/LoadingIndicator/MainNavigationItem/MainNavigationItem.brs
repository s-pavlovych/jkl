sub init()
    registerUI() 
    configNavElement()
end sub

sub registerUI() 
    m.navigationBar = m.top.findNode("navigationBar")
    m.itemRow = m.top.findNode("itemRow")
    m.logoMenu = m.top.findNode("logoMenu")
    registerAnimation()
    m.index = 0
    m.isHideMenu = true
end sub

sub registerAnimation()
    m.animationShowNavigatioPanel = m.top.findNode("animationShowNavigatioPanel")
    m.animationHideNavigatioPanel = m.top.findNode("animationHideNavigatioPanel")
end sub    

sub configNavElement()
    m.itemRow.setFocus(true)
end sub    

sub hideFocus(event)
    unfocused = event.getData()
    if unfocused = true
        backFocusInLayoutGroup(m.index)
    else
        nextFocusInLayoutGroup(m.index)
    end if    
end sub    

sub hideMenu()
    isHide = m.top.isHideMenu
    if isHide
        m.animationShowNavigatioPanel.control = "start"
        m.isHideMenu = true  
    else if not m.top.perventBlink
        m.animationHideNavigatioPanel.control = "start"
        m.isHideMenu = false
        m.top.perventBlink = true
    end if
end sub

sub showContent() 
    m.index = 0
    m.myIndex = 0
    countChils = m.itemRow.getChildCount()
    m.itemRow.removeChildrenIndex(countChils, 0)    
    m.array = invalid
    m.array = m.top.content
    if m.top.logo <> invalid
        m.logoMenu.width = m.top.logo.small.width
        m.logoMenu.translation = [20, 21]
        m.itemRow.translation = [20 + m.top.logo.small.width + 60, 0]
        m.logoMenu.uri = m.top.logo.small.url
    else
        m.logoMenu.uri = "pkg:/images/Hope_Channel_Indonesia 1.png"
        m.logoMenu.width = 400
        m.logoMenu.translation = [20, 21]
        m.itemRow.translation = [20 + 129 + 300, 0]
    end if
    m.itemRow.setFocus(true)
    index = 0
    for each item in m.array
        index += 1
        if item <> " "
            if index = 1
                addItemInLayout(item, 0)  
            else
                addItemInLayout(item, index)  
            end if
        end if    
    end for
end sub

sub addItemInLayout(title, index = invalid)
    m.myIndex += 1
    if m.myIndex <> 1
        index = invalid
    end if   
    item = createObject("RoSGNode", "ContentNode")
    titleItemComponent = createObject("RoSGNode", "RowNavigationItem")
    if index = invalid
        item.title = title
    else
        item.title = title
        titleItemComponent.itemHasFocus = true
    end if
        titleItemComponent.itemContent = item
        m.itemRow.appendChild(titleItemComponent)
end sub

sub nextFocusInLayoutGroup(index)
    m.itemRow.getChild(index).itemHasFocus = true
end sub

sub backFocusInLayoutGroup(index)
    m.itemRow.getChild(index).itemHasFocus = false
end sub

sub changeButtonKey(key)
    m.navigationArray = m.global.arrayForNavigation
    if key = "right"
        m.index += 1
        if m.index < m.navigationArray.count()
            backFocusInLayoutGroup(m.index - 1)
            nextFocusInLayoutGroup(m.index)
            m.top.itemFocused = m.navigationArray[m.index]
        else
            m.index -= 1
        end if   
    else if key = "left"
            m.index -= 1
        if m.index >= 0
            backFocusInLayoutGroup(m.index + 1)
            nextFocusInLayoutGroup(m.index)
            m.top.itemFocused = m.navigationArray[m.index]
        else
            m.index += 1
        end if   
    else if key = "down"
        m.itemRow.getChild(m.index).height = true
        backFocusInLayoutGroup(m.index)
        m.top.itemFocused = m.navigationArray[m.index]
    else if key = "up"
        m.itemRow.getChild(m.index).height = false
        nextFocusInLayoutGroup(m.index)
        m.top.itemFocused = m.navigationArray[m.index]
    else if key = "back"
        m.itemRow.getChild(m.index).height = false
        nextFocusInLayoutGroup(m.index)
    else if key = "OK"
        nextFocusInLayoutGroup(m.index)
        m.itemRow.getChild(m.index).height = false
        m.top.itemFocused = m.navigationArray[m.index]
    end if    
end sub    

function onKeyEvent(key as String, press as Boolean) as Boolean
    ? ">>> MainNavigationItem: onKeyEvent("key", "press")"
    m.navigationArray = m.global.arrayForNavigation
    m.top.perventBlink = false
    m.top.showLable = false
    result = false
    if key = "up"
        changeButtonKey(key)
        return true
    end if   
    if key = "back"
        changeButtonKey(key)
        return false
    end if   

    if key = "OK"
         m.top.itemSelected = m.navigationArray[m.index]
        changeButtonKey(key)
        return true
    end if  
    if press
        if m.isHideMenu = true
            if key = "right"        
                changeButtonKey(key)
                return true                   
            else if key = "left"
                changeButtonKey(key)
                return true
            else if key = "down"
                if m.navigationArray[m.index] <> "LiveScreen"
                    changeButtonKey(key)
                    m.top.stopVideo = true
                    return false
                end if
                return true
            else if key = "up"
                changeButtonKey(key)
                return true
            else if key = "OK"
                changeButtonKey(key)
                return true
            end if  
        else
            m.top.itemFocused = 0
        end if
    end if
    return true 
end function