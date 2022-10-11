' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub init()
    initNetworkManager()
    writeCloudLog("INFO", "App Start")
    initAnalitics()
    m.top.SetFocus(true)
    initSubvies()
    m.InputTask = createObject("roSgNode", "inputTask")
    m.InputTask.observefield("inputData", "handleInputEvent")
    m.InputTask.control = "RUN"
    initNetworkManager()
    launchDeepLink()
    di = CreateObject("roDeviceInfo")
    m.dname = di.GetModelDisplayName()
end sub

sub initSubvies()
    ? "initSubviews"
    m.navigationStack = m.top.findNode("navigationStack")
    m.loadingIndicator = m.top.findNode("loadingProgress")
    m.liveScreen = m.top.findNode("liveScreen")
    m.settingsScreen = m.top.findNode("settingsScreen")
    m.featureScreen = m.top.findNode("featureScreen")
    m.showsScreen = m.top.findNode("showsScreen")
    m.timerForHideView = m.top.findNode("timerForHideView")
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.timerForHideView.observeField("fire", "hideView")
    configDialog()
    m.isHide = true
    m.timerForFocus = m.top.findNode("timerForFocus")
    m.timerForFocus.observeField("fire", "onFocusChange")
end sub

sub launchDeepLink()
    if m.global.deeplink <> invalid
        m.launchScreen = m.top.createChild("LaunchScreen")
        m.launchScreen.visible = true
        m.launchScreen.SetFocus(true)
        validateDeepLink(m.global.deeplink)
    else
        showLaunchScreen()
    end if
end sub

sub handleInputEvent(msg)
    if type(msg) = "roSGNodeEvent" and msg.getField() = "inputData"
        deeplink = msg.getData()
        validateDeepLink(deeplink)
    end if
end sub

function onStopVideo(event)
    data = event.getData()
    if data
        m.timerForFocus.control = "start"
    end if
end function

function onFocusChange()
    m.liveScreen.stopPlayer = "stop"
end function

function validateDeepLink(deeplink as object)
    if deeplink <> invalid
        m.getRequest = CreateObject("roSGNode", "URLRequest")
        if deeplink.type = "episode"
            m.focusForPlayer = 1
            ' m.getRequest.path = getEpisodePathFormat()
        else if deeplink.type = "live"
            m.focusForPlayer = 0
            ' m.getRequest.path = getLivePath()
        end if
        m.getRequest.pathArgument = deeplink.id
        m.manager = NetworkManager()
        m.manager.request = m.getRequest
        m.manager.observeField("response", "onVideoContentForDeepLink")
        m.manager.control = "RUN"
    end if
end function

sub onVideoContentForDeepLink(event)
    response = event.getData()
    m.manager.unobserveField("response")
    m.manager.unobserveField("state")
    videoContent = createObject("RoSGNode", "ContentNode")
    if response.data <> invalid
        for each media in response.data.media_links
            if media.media_format = "MP4 HD" or media.media_format = "m3u8"
                hideScreen()
                videoContent.url = media.link
                videoContent.STREAMFORMAT = media.media_format
                m.top.removeChild(m.launchScreen)
                m.launchScreen = invalid
                m.videoContentForPlayer = videoContent
                m.focusForPlayer = 0
                activateScreen("PlayerScreen")
                exit for
            end if
        end for
    else if response.arrayData <> invalid
        media = response.arrayData[0]
        hideScreen()
        videoContent.url = media.link
        videoContent.STREAMFORMAT = media.media_format
        m.top.removeChild(m.launchScreen)
        m.launchScreen = invalid
        m.videoContentForPlayer = videoContent
        m.focusForPlayer = 1
        activateScreen("PlayerScreen")
    else
        m.manager.control = "stop"
        m.videoplayer.isChangePlayerStatus = "stop"
        showLaunchScreen()
    end if
end sub

sub initNetworkManager()
    m.top.networkManager = CreateObject("roSGNode", "NetworkManager")
    m.top.writeCloudLog = CreateObject("roSGNode", "WriteCloudLog")
    m.top.networkManager.baseUrl = getBaseUrl()
end sub

sub configDialog()
    m.dialog = m.top.findNode("alert")
    m.background = m.top.findNode("background")
    m.alertButtons = m.top.findNode("buttonsForAlert")
    m.descriptionAlert = m.top.findNode("descriptionsAlert")
    m.dialog.width = 1200
    m.dialog.height = 600
    m.dialog.translation = [350, 200]
    m.titleAlert = m.top.findNode("titleAlert")
    m.titleAlert.width = 1200
    m.titleAlert.font = robotoBoldOfSize(50)
    m.descriptionAlert.width = 1200
    m.descriptionAlert.text = tr("Are you sure you want to exit Hope Channel?")
    m.descriptionAlert.font = robotoOfSize(25)
    m.alertButtons.font = robotoBoldOfSize(35)
    m.alertButtons.focusedFont = robotoBoldOfSize(35)
    m.alertButtons.translation = [(m.dialog.width / 2) - 150, 350]
    m.alertButtons.observeField("itemSelected", "selectAlert")
end sub

sub initMainNavigationItem()
    m.mainNavigationItem = m.top.findNode("mainNavigationItem")
    m.mainNavigationItem.visible = true
    m.mainNavigationItem.logo = m.global.selectedChannel
    m.mainNavigationItem.content = m.global.arrayItemInNavigationMenu
    m.mainNavigationItem.SetFocus(true)
    if m.global.arrayForNavigation[0] = "LiveScreen"
        showLive()
    else
        m.top.removeChild(m.launchScreen)
        m.launchScreen = invalid
        activateScreen(m.global.arrayForNavigation[0])
    end if
end sub

sub showError(errorDialog)
    if IsValid(errorDialog)
        m.dialogContainer = CreateObject("roSGNode", "Rectangle")
        m.dialogContainer.update({
            width: 1920
            height: 1080
            color: "0x00000099"
        })
        m.dialogContainer.appendChild(errorDialog)
        errorDialog.observeField("erroBtnClicekd", "onErrorBtnClicked")
        m.top.appendChild(m.dialogContainer)
    end if
end sub

sub onErrorBtnClicked(event)
    if IsValid(m.dialogContainer)
        m.top.removeChild(m.dialogContainer)
        m.dialogContainer = invalid
    end if
end sub

sub selectAlert(event)
    selected = event.getData()

    if selected = 1
        m.top.exitApp = true
    else
        m.dialog.visible = false
        m.background.visible = true
        m.mainNavigationItem.unfocused = false
        m.mainNavigationItem.SetFocus(true)
    end if
end sub

sub hidePreviousScreen()
    itemSelected = m.top.itemSelected
    if itemSelected = "ShowsScreen" or itemSelected = "FeatureScreen"
        m.top.passFocusToNav = false
        m.top.passFocusToNavi = false
        m.top.hideEmbbededScreen = true
        m.top.hideEmbbededScreenFeat = true
        m.showsScreen.visible = true
        m.mainNavigationItem.SetFocus(true)
    end if
end sub

function showLaunchScreen(param = invalid)
    m.launchScreen = m.top.createChild("LaunchScreen")
    m.launchScreen.observeField("startupInfoDidLoad", "initMainNavigationItem")
    m.launchScreen.visible = true
    m.launchScreen.SetFocus(true)
    m.launchScreen.callFunc("getStartupInfo", {})
end function

function showLive()
    if m.launchScreen <> invalid
        m.top.removeChild(m.launchScreen)
        m.launchScreen = invalid
    end if
    m.liveScreen.selectedContent = m.global.selectedChannel
    activateScreen("LiveScreen")
end function

function showScreen(screenNode)
    m.navigationStack.callFunc("showScreen", screenNode)
end function

function popToRoot(params = true)
    result = m.navigationStack.callFunc("popToRoot", params)
end function

function pop(params)
    result = m.navigationStack.callFunc("pop", params)
end function

function showLoadingIndicator(show)
    m.loadingIndicator.visible = show
    if show
        m.loadingIndicator.control = "start"
    else
        m.loadingIndicator.control = "stop"
    end if
end function

function backgroundImageForIndicator(image)
    m.loadingIndicator.backgroundUri = image
end function

function getActiveScreen()
    return m.screen
end function

sub changeScreen(event)
    screen = event.getData()
    activateScreen(screen)
end sub

sub hideView()
    if m.mainNavigationItem <> invalid
        m.mainNavigationItem.isHideMenu = false
        m.isHide = false
        if not m.mainNavigationItem.showLable
            m.liveScreen.showLabelInPlayer = false
            m.mainNavigationItem.showLable = true
        end if
    end if
end sub

sub changeStatePlayer()
    if m.top.state = "playing"
        m.timerForHideView.control = "start"
    else
        m.timerForHideView.control = "stop"
    end if
end sub

sub selectedScreen(screen)
    if screen = "LiveScreen"
        ? "activateScreen(LiveScreen)"
        m.liveScreen.focusKey = 0
    else if screen = "FeatureScreen"
        m.featureScreen.focusKey = 0
        ? "activateScreen(FeatureScreen)"
    else if screen = "ShowsScreen"
        ? "activateScreen(ShowsScreen)"
        if m.showsScreen.visible
            m.showsScreen.focusKey = 1
        else
        end if

    else if screen = "SettingsScreen"
        ? "activateScreen(SettingsScreen)"
        m.settingsScreen.focusKey = 0
    end if
end sub

function hiddenNavBar(event)
    m.mainNavigationItem.visible = event
end function

sub hideScreen()
    m.timerForHideView.control = "stop"
    m.liveScreen.isChangePlayerStatus = "stop"
    m.liveScreen.visible = false
    if m.mainNavigationItem <> invalid
        m.mainNavigationItem.visible = false
    end if
    m.settingsScreen.visible = false
    m.featureScreen.visible = false
    m.showsScreen.visible = false
end sub

sub onPassFocusToNav()
    m.mainNavigationItem.SetFocus(true)
end sub

sub onPassFocusToNavi()
    ? "onPssFocusToNavi"
    m.mainNavigationItem.SetFocus(true)
end sub

sub passFocusToNavE()
    m.mainNavigationItem.SetFocus(true)
end sub

sub onDesendantScreenHide()
    m.top.hideEmbbededScreen = true
    m.top.hideEmbbededScreenFeat = true
    m.showsScreen.visible = true
    m.top.passFocusToNav = false
    m.top.passFocusToNavi = false
end sub

sub activateScreen(screen)
    ? "activateScreen("screen")"
    if m.mainNavigationItem <> invalid and m.isHide = false
        m.timerForHideView.control = "start"
        m.mainNavigationItem.isHideMenu = true
        m.liveScreen.showLabelInPlayer = true
        m.isHide = true
    end if
    if screen <> m.selectedScreen
        m.selectedScreen = screen
        if screen = "LiveScreen"
            m.liveScreen.stopPlayer = "play"
            ? "activateScreen(LiveScreen)"
            if m.dname = "Roku LT"
                m.top.stopVideo = false
            end if
            showLive()
            m.liveScreen.isChangePlayerStatus = "play"
            m.liveScreen.visible = true
            m.videoPlayer.visible = false
            m.featureScreen.visible = false
            m.settingsScreen.visible = false
            m.mainNavigationItem.visible = true
            m.mainNavigationItem.SetFocus(true)
        else if screen = "FeatureScreen"
            ? "activateScreen(FeatureScreen)"
            m.timerForHideView.control = "stop"
            if m.dname = "Roku LT"
                m.liveScreen.stopPlayer = "pause"
            else
                m.liveScreen.stopPlayer = "stop"
            end if
            m.videoPlayer.visible = false
            m.liveScreen.visible = false
            m.featureScreen.content = m.global.featured
            m.featureScreen.visible = true
            m.settingsScreen.visible = false
            m.mainNavigationItem.SetFocus(true)
        else if screen = "ShowsScreen"
            m.timerForHideView.control = "stop"
            if m.dname = "Roku LT"
                m.liveScreen.stopPlayer = "pause"
            else
                m.liveScreen.stopPlayer = "stop"
            end if
            ? "activateScreen(ShowsScreen)"
            m.featureScreen.visible = false
            m.videoPlayer.visible = false
            m.liveScreen.visible = false
            m.settingsScreen.visible = false
            m.showsScreen.visible = true
            m.showsScreen.focusKey = 0
            m.liveScreen.stopPlayer = "pause"
        else if screen = "SettingsScreen"
            m.timerForHideView.control = "stop"
            if m.dname = "Roku LT"
                m.liveScreen.stopPlayer = "pause"
            else
                m.mainNavigationItem.SetFocus(true)
                m.liveScreen.stopPlayer = "stop"
            end if
            ? "activateScreen(SettingsScreen)"
            m.videoPlayer.visible = false
            m.liveScreen.stopPlayer = "pause"
            m.timerForHideView.control = "stop"
            m.showsScreen.visible = false
            m.liveScreen.visible = false
            m.settingsScreen.content = m.global.availableChannels
            m.featureScreen.visible = false
            m.settingsScreen.visible = true
        else if screen = "PlayerScreen"
            m.timerForHideView.control = "play"
            m.liveScreen.visible = false
            m.featureScreen.visible = false
            m.settingsScreen.visible = false
            m.videoPlayer.visible = true
            m.videoPlayer.SetFocus(true)
            m.videoPlayer.focusKey = m.focusForPlayer
            m.videoPlayer.content = m.videoContentForPlayer
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ? ">>> MainScene: onKeyEvent("key", "press")"
    result = false
    m.top.showLable = false
    if press
        if key = "OK"
            m.mainNavigationItem.SetFocus(true)
            return false
        end if
        if key = "up"
            if m.dialog.visible = false
                m.mainNavigationItem.SetFocus(true)
                return false
            end if
        end if
        if key = "down"
            if m.dialog.visible = false
                if m.top.itemFocused = "ShowsScreen"
                    ? "1"

                    if not m.top.passFocusToNav
                        ? "2"
                        m.top.stopVideo = true
                        selectedScreen(m.top.itemFocused)
                    else
                        ? "3"
                        m.showsScreen.focusToImg = true
                    end if
                else if m.top.itemFocused = "FeatureScreen"
                    if not m.top.passFocusToNavi
                        m.top.stopVideo = true
                        selectedScreen(m.top.itemFocused)
                    else
                        m.featureScreen.focusToImg = true
                    end if
                else
                    selectedScreen(m.top.itemFocused)
                end if
                return true
            end if
        end if
        if key = "back"
            if m.videoplayer.visible
                m.videoplayer.isChangePlayerStatus = "stop"
                showLaunchScreen()
                return true
            end if
            if m.mainNavigationItem.focusedChild <> invalid
                m.dialog.visible = true
                m.background.visible = true
                m.alertButtons.SetFocus(true)
                m.mainNavigationItem.unfocused = true
                return true
            else if m.dialog.visible = true
                m.dialog.visible = false
                m.background.visible = true
                m.mainNavigationItem.unfocused = false
                m.mainNavigationItem.SetFocus(true)
            else
                m.mainNavigationItem.unfocused = false
                m.mainNavigationItem.SetFocus(true)
            end if
            return true
        end if
    end if

    if not press then return result
    if key = "back"
        activeScreen = getActiveScreen()
        if activeScreen <> invalid
            screensCount = activeScreen.callFunc("getScreensCount", {})
            if screensCount >= 1
                activeScreen.callFunc("pop", {})
            else
                'TODO activate main menu
            end if
            result = true
        else
            'TODO show exit dialog
        end if

    end if
    return result
end function