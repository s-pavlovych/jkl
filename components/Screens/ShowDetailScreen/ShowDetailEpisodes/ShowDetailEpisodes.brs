sub init()
    registerView()
end sub

sub registerView()
    m.conteiner = m.top.findNode("container")
    m.upListAnimation = m.top.findNode("upListAnimation")
    m.downListAnimation = m.top.findNode("downListAnimation")
    m.episodeList = m.top.findNode("episodeList")
    m.titleSerial = m.top.findNode("titleSerial")
    m.backgroundLogo = m.top.findNode("backgroundPoster")
    m.backgroundLogo.observeField("focusedChild", "onPosterGetFocus")
    m.descriptionSerial = m.top.findNode("descriptionSerial")
    m.episodeList.observeField("itemSelected", "onItemSelected")
    m.detatilsEpisode = m.top.findNode("detatilsEpisode")
    m.episodeGroup = m.top.findNode("EpisodeGroup")
    m.backgroundGradient = m.top.findNode("backgroundGradient")
    m.testRectangle = m.top.findNode("testRectangle")
    configureScreen()
end sub 

sub showLoadingIndicator(show)
    scene = m.top.getScene()
    scene.callFunc("showLoadingIndicator", show)
end sub

sub changeFont()
    m.descriptionSerial.font = getFontForChannel(m.global.selectedChannel.objectID, 29, "light")
    m.titleSerial.font = getFontForChannel(m.global.selectedChannel.objectID, 57, "bold")
end sub

sub configureScreen()
    configureRowListForEpisodes()
end sub    

sub configureRowListForEpisodes()
    sizeRowList = 1920 - 80
    m.episodeList.translation = [80, 828]
    m.episodeList.rowItemSpacing = [[40, 60]]
    m.episodeList.itemSpacing = [40, 60]
    m.episodeList.itemSize = [sizeRowList, 428]
    m.episodeList.rowItemSize = [[568, 410]]
    m.episodeList.showRowLabel = true 
    m.episodeList.rowLabelColor = "#2C2E35"
    m.episodeList.numRows = 4
    m.episodeList.focusBitmapBlendColor = "#0646A5"
    m.episodeList.vertFocusAnimationStyle = "fixedFocus"
    m.episodeList.rowFocusAnimationStyle = "floatingFocus"
end sub    

sub hideView(isHide)
    m.episodeList.visible = isHide
    m.titleSerial.visible = isHide
    m.descriptionSerial.visible = isHide
    m.episodeGroup.visible = isHide
end sub   

sub sendAnalytics()
    if m.google <> invalid
        m.global.RSG_analytics.trackEvent = {
        google: m.google
    }
    end if
end sub

sub onPosterGetFocus()
    m.backgroundLogo.scaleRotateCenter = [m.backgroundLogo.width / 2, m.backgroundLogo.height / 2]
    m.backgroundGradient.scaleRotateCenter = [m.backgroundGradient.width / 2, m.backgroundGradient.width / 2]
   if m.backgroundLogo.hasFocus()
    m.backgroundLogo.scale = [1.1, 1.1]
    m.backgroundGradient.scale = [1.0 , 1.1]
   else 
    m.backgroundLogo.scale = [1.0, 1.0]
    m.backgroundGradient.scale = [1.0 , 1.0]
   end if
end sub

sub updateFocus()
    if m.top.focusKey = 0 
      m.episodeList.setFocus(true)
    end if
end sub

sub showContent()
    m.conteiner.translation = [0, 140]
    m.episodeList.translation = [80, 828]
    changeFont()
    hideView(false)
    ' m.google = {
    '   t : "screenview",
    '   hit_type : "screen_view_gtm",
    '   screen_name: "Show Detail"
    '   cd13: m.top.preview.objectID,
    '   cd14: m.top.preview.title,
    '   show_id: m.top.preview.objectID,
    '   show_name: m.top.preview.title,
    '   metadata: defaultMetadata()
    ' }
    sendAnalytics()
    setupContentForEpisodes(m.top.content)
    showLoadingIndicator(true)
    setupDataForEpisode()
end sub    

sub setupDataForEpisode()
    if m.top.preview <> invalid
    m.titleSerial.text = m.top.preview.title
    m.descriptionSerial.text = m.top.preview.abstract
    m.titleSerial.color = "#000000"
    m.descriptionSerial.color = "#000000"
    if m.top.preview.images <> invalid    
        logo = m.top.preview.images
        if m.top.preview.images.default <> invalid 
          m.backgroundLogo.uri = logo.default.medium.url
        else
            m.backgroundLogo.uri = "pkg:/images/$$RES$$/defaultImageForBackground.png"
        end if
    end if
end if
end sub     

sub hideEpisodeView()
    m.top.changeAllowFocus = false
    m.detatilsEpisode.visible = false
end sub

sub onItemSelected(event)
    selected = event.getData()
    m.top.changeAllowFocus = true
    m.detatilsEpisode.visible = true
    m.detatilsEpisode.focusKey = 0
    contentForDetails = m.episodeList.content.getChild(m.episodeList.rowItemFocused[0]).getChild(m.episodeList.rowItemFocused[1])
    m.episodeGroup.visible = false
    m.detatilsEpisode.content = contentForDetails
end sub

sub onHideNavbar(event)
    ? "onHideNavBar"
    showView = event.getData()
    scene = m.top.getScene()
    scene.callFunc("hiddenNavBar", showView )
end sub
' 
sub onFocusToImg()
    m.backgroundLogo.setFocus(true)
end sub

sub hideNavBar(show)
    scene = m.top.getScene()
    scene.callFunc("hiddenNavBar", show)
end sub

sub setupContentForEpisodes(episodesContent)
        content = CreateObject("roSGNode", "ContentNode")
        m.episodes = content.createChild("ContentNode")
        m.episodes.title = "Episodes"
        for each episode in episodesContent
                episodeNode = m.episodes.createChild("ContentNodeShows")
                episodeNode.title = episode.title
                episodeNode.addfield("isShow","bool",false)
                episodeNode.isShow = true
                if m.top.preview.colors <> invalid
                    episodeNode.textColor = m.top.preview.colors.text_color
                end if
                if episode.short_description <> invalid
                    episodeNode.shortDescriptions = episode.short_description
                end if
                if episode.image <> invalid
                    episodeNode.SDPosterUrl = episode.image.small.url
                    episodeNode.HDPosterUrl = episode.image.medium.url
                else 
                    episodeNode.SDPosterUrl = "pkg:/images/defaultImageForCells.png" 
                end if
                episodeNode.objectID = episode.id
    end for
    hideView(true)
    showLoadingIndicator(false)
    m.backgroundLogo.setFocus(true)
    m.episodeList.content = content
end sub    

sub onDownClick()
    m.upListAnimation.control = "start"
end sub

sub onUpClick()
    m.downListAnimation.control = "start"
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    ? ">>> ShowDetailsEpisode: onKeyEvent("key", "press")"
    result = false
    if press 
        if key = "back"
            m.top.changeAllowFocus = false
            m.top.hideNavbar = true
            if m.episodeGroup.visible = false
                m.episodeGroup.visible = true
                m.detatilsEpisode.visible = false
                m.episodeList.setFocus(true)
                return true
            else
                m.detatilsEpisode.visible = false
                return false
            end if    
        else if key = "up"
            if m.backgroundLogo.hasFocus()
                m.top.passFocusToNav = true
                m.top.passFocusToNavi = true
            else if m.episodeList.hasFocus()
                onUpClick()
                m.backgroundLogo.setFocus(true)
            end if
            return true
        else if key="down"
            if m.backgroundLogo.hasFocus()
                onDownClick()
                m.episodeList.setFocus(true)
            end if
        end if
    end if
    return true 
end function