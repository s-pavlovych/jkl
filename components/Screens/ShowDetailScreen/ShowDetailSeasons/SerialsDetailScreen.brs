sub init()
    registerView()
    m.taskNode = CreateObject("RoSGNode", "TaskNodeData")
    m.taskNode.observeField("state", "onStateChange")
    m.taskNode.observeField("loadData", "onLoadData")
    m.count = 0
    m.counter = 0
    m.seasonCount = 0
    m.seasonsData = []
    m.arrayTitles = []
    m.rowElements = 2
end sub

sub registerView()
    m.textContainer = m.top.findNode("textContainer")
    m.seasonList = m.top.findNode("seasonList")
    m.seasonList.observeField("itemFocused", "onItemFocus")
    m.titleSerial = m.top.findNode("titleSerial")
    m.loadingProgress = m.top.findNode("loadingProgress")
    m.backgroundLogo = m.top.findNode("backgroundPoster")
    m.descriptionSerial = m.top.findNode("descriptionSerial")
    m.detatilsEpisode = m.top.findNode("detatilsEpisode")
    m.serialGroup = m.top.findNode("SerialGroup")
    m.backgroundGradient = m.top.findNode("backgroundGradient")
    m.upListAnimation = m.top.findNode("upListAnimation")
    m.downListAnimation = m.top.findNode("downListAnimation")
    m.timer = m.top.findNode("timer")
    m.container = m.top.findNode("container")
    observeFields()
    configDialog()
    configureScreen()
end sub

sub observeFields()
    m.timer.observeField("fire", "reloadData")
    m.backgroundLogo.observeField("focusedChild", "onPosterGetFocus")
    m.loadingProgress.observeField("visible", "onVisibleChange")
    m.upListAnimation.observeField("state", "onControlChangeToPoster")
    m.downListAnimation.observeField("state", "onControlChangeToList")
end sub

sub configDialog()
    m.dialog = m.top.findNode("alert")
    m.alertButtons = m.top.findNode("buttonsForAlert")
    m.dialog.width = 1200
    m.dialog.height = 600
    m.dialog.translation = [350, 200]
    m.titleAlert = m.top.findNode("titleAlert")
    m.titleAlert.width = 1200
    m.titleAlert.font = robotoBoldOfSize(50)
    m.alertButtons.font = robotoBoldOfSize(35)
    m.alertButtons.focusedFont = robotoBoldOfSize(35)
    m.alertButtons.translation = [(m.dialog.width / 2) - 150, 350]
end sub

sub configureScreen()
    configureSeasonList()
    m.indexSeason = 0
    if m.global.selectedChannel <> invalid
        m.descriptionSerial.font = getFontForChannel(m.global.selectedChannel.objectID, 29, "light")
        m.titleSerial.font = getFontForChannel(m.global.selectedChannel.objectID, 57, "bold")
    end if
    m.seasonList.observeField("itemSelected", "onItemSelected")
end sub

sub _backToSerialGroup()
    m.response = invalid
    m.top.allowFocusToEpisode = false
    m.serialGroup.visible = true
    m.seasonList.visible = true
    m.seasonList.setFocus(true)
end sub

sub _resetScreen()
    m.response = invalid
    m.top.allowFocusToEpisode = false
    m.top.passFocusToNav = false
    m.top.passFocusToNavi = false
    m.top.focusPassed = false
    if IsValid(m.arr)
    m.arr.clear()
    end if
    m.counter = 0
    m.seasonList.content = invalid
    m.arrayTitles.clear()
    m.seasonsData.clear()
    m.dialog.visible = false
    m.isError = false
    m.countRequest = 0
    m.rowElements = 2
    if m.networkManager <> invalid
        m.indexSeason = 0
        m.networkManager.unobserveField("state")
        m.networkManager.unobserveField("response")
        m.networkManager.control = "stop"
    end if
    m.detatilsEpisode.visible = false
end sub

function onLoadData(event)
    isLoading = event.getData()
    if isLoading
        m.seasonList.setFocus(true)
        showLoadingIndicator(false)
    end if
end function

function getFiveElements(firstIndex, lastIndex)
    m.loadingProgress.setFocus(true)
    m.loadingProgress.visible = true
    m.arr = []
    if lastIndex >= m.seasonsID.count()
        lastIndex = m.seasonsID.count()
    end if
    for i = firstIndex to lastIndex step 1
        if m.seasonsID[i] <> invalid
            m.arr.push(m.seasonsID[i].id)
            m.arrayTitles.push({ title: m.seasonsID[i].title, group_name: m.seasonsID[i].group_name })
        end if
    end for
    m.counter = 0
    if lastIndex > firstIndex
        onRequestHandler()
    else
        m.seasonList.setFocus(true)
        m.loadingProgress.visible = false
    end if
end function

function onRequestHandler()
    if m.counter <> m.arr.count()
        id = m.arr[m.counter]
        if id <> invalid
            getSeassonContentFor(id)
            m.counter++
        else
            m.loadingProgress.visible = true
            m.seasonList.setFocus(true)
        end if
    end if
end function

function onStateChange(event)
    data = event.getData()
    if data = "stop"
        if not m.top.focusPassed
            m.loadingProgress.visible = false
            m.backgroundLogo.setFocus(true)
            m.top.focusPassed = true
        else
            m.seasonList.setFocus(true)
            m.loadingProgress.visible = false
            hideView(true)
        end if
    end if
end function

function onItemFocus(event)
    indexOfRow = event.getData()
    if indexOfRow = m.rowElements
        m.arrayTitles.clear()
        m.seasonsData.clear()
        m.arr.clear()
        firstIndex = m.rowElements + 1
        lastIndex = firstIndex + 2
        getFiveElements(firstIndex, lastIndex)
        m.rowElements = m.rowElements + 3
    end if
end function

sub onPosterGetFocus()
    m.backgroundLogo.scaleRotateCenter = [m.backgroundLogo.width / 2, m.backgroundLogo.height / 2]
    m.backgroundGradient.scaleRotateCenter = [m.backgroundGradient.width / 2, m.backgroundGradient.width / 2]
    if m.backgroundLogo.hasFocus()
        m.backgroundLogo.scale = [1.1, 1.1]
        m.backgroundGradient.scale = [1.0, 1.1]
    else
        m.backgroundLogo.scale = [1.0, 1.0]
        m.backgroundGradient.scale = [1.0, 1.0]
    end if
end sub

sub onControlChangeToPoster(event)
    animeState = event.getData()
    if animeState = "running"
        m.loadingProgress.setFocus(true)
    else if animeState = "stopped"
        m.seasonList.setFocus(true)
    end if
end sub

sub onControlChangeToList(event)
    animeState = event.getData()
    if animeState = "running"
        m.loadingProgress.setFocus(true)
    else if animeState = "stopped"
        m.backgroundLogo.setFocus(true)
    end if
end sub

function onVisibleChange(event)
    visible = event.getData()
    if visible
        m.top.backAfteLoad = false
    else
        m.top.backAfteLoad = true
    end if
end function

sub showLoadingIndicator(show)
    scene = m.top.getScene()
    scene.callFunc("showLoadingIndicator", show)
end sub

sub configureSeasonList()
    sizeRowList = 1920 - 80
    m.seasonList.translation = [80, 828]
    m.seasonList.rowItemSpacing = [[30, 90]]
    m.seasonList.itemSpacing = [30, 90]
    m.seasonList.itemSize = [sizeRowList, 400]
    m.seasonList.rowItemSize = [[568, 400]]
    m.seasonList.showRowLabel = true
    m.seasonList.numRows = 4
    m.seasonList.focusBitmapBlendColor = "#0646A5"
    m.seasonList.vertFocusAnimationStyle = "fixedFocus"
    m.seasonList.rowFocusAnimationStyle = "floatingFocus"
end sub

sub hideView(isHide)
    m.titleSerial.visible = isHide
    m.descriptionSerial.visible = isHide
end sub

sub updateFocus()
    if m.top.focusKey = 0
        m.seasonList.setFocus(true)
    end if
end sub

sub onPreviewChange(event)
    data = event.getData()
    m.titleSerial.text = m.top.preview.title
    m.descriptionSerial.text = m.top.preview.abstract
    if m.top.preview.images <> invalid
        m.backgroundLogo.uri = m.top.preview.images.default.medium.url
    else
        m.backgroundLogo.uri = "pkg:/images/$$RES$$/defaultImageForBackground.png"
    end if
end sub

sub reloadData()
    if m.response = invalid
    end if
end sub

sub onFocusToImg()
    m.backgroundLogo.setFocus(true)
end sub

sub showContent()
    _resetScreen()
    m.seasonList.translation = [80, 828]
    m.container.translation = [0, 140]
    m.seasonsID = m.top.content
    if m.seasonsID.count() < 2
        lastIndex = m.seasonsID.count()
    else
        lastIndex = 2
    end if
    getFiveElements(0, lastIndex)
    setupDataForSerial()
    hideView(false)
    m.serialGroup.visible = true
    m.timer.control = "start"
    m.detatilsEpisode.visible = false
    m.response = invalid
end sub

' sub onHide_showNavigation(event)
' showView = event.getData()
' scene = m.top.getScene()
' scene.callFunc("hiddenNavBar", showView)
' end sub

sub setupDataForSerial()
    m.seasonList.rowLabelColor = "#000000"
    if m.top.preview <> invalid
        m.titleSerial.translation = [80, 350]
        m.descriptionSerial.translation = [80, 426]
        m.seasonList.translation = [80, 828]
        logo = m.top.preview.HDPOSTERURL
        m.backgroundLogo.uri = logo
    else
        m.backgroundLogo.uri = ""
        m.titleSerial.translation = [80, 80]
        m.descriptionSerial.translation = [80, 166]
        m.seasonList.translation = [80, 496]
        if m.descriptionSerial.text = ""
            m.seasonList.translation = [80, 200]
        end if
    end if
end sub

sub onItemSelected(event)
    m.top.allowFocusToEpisode = true
    m.top.hide_showNavigation = false
    selected = event.getData()
    m.detatilsEpisode.visible = true
    m.detatilsEpisode.focusKey = 0
    contentForDetails = m.seasonList.content.getChild(m.seasonList.rowItemFocused[0]).getChild(m.seasonList.rowItemFocused[1])
    m.serialGroup.visible = false
    m.detatilsEpisode.serialContent = m.top.preview
    m.detatilsEpisode.seasoneNumber = m.seasonList.content.getChild(m.seasonList.rowItemFocused[0]).title
    m.detatilsEpisode.content = contentForDetails
end sub

sub onHideNavbar(event)
    ? "onHideNavBar"
    showView = event.getData()
    scene = m.top.getScene()
    scene.callFunc("hiddenNavBar", showView)
end sub

function getSeassonContentFor(id)
    querry = {}
    media = "youtube,vimeo,jetstream,mp4-hd,mp4-sd,mp3,hls,bif"
    limit = "100"
    skip = "0"
    sort = "-publishedAt"
    querry["media"] = media
    querry["limit"] = limit
    querry["skip"] = skip
    querry["sort"] = sort
    season = m.top.content[m.indexSeason]
    m.getSeriesRequest = CreateObject("roSGNode", "URLRequest")
    m.getSeriesRequest.path = getSeasonEpisodes()
    m.getSeriesRequest.pathArgument = id
    m.getSeriesRequest.querryParams = querry
    m.networkManager = NetworkManager()
    m.networkManager.request = m.getSeriesRequest
    m.networkManager.observeField("response", "onSeassonDetailContentFor")
    m.networkManager.control = "RUN"
end function

function nextRequestSeries(event)
    state = event.getData()
    if state = "stop"
        onRequestHandler()
    end if
end function

sub onDownClick()
    m.upListAnimation.control = "start"
end sub

sub onUpClick()
    m.downListAnimation.control = "start"
end sub

sub onSeassonDetailContentFor(event)
    m.networkManager.unobserveField("response")
    if m.timer.control = "START"
        m.timer.control = "STOP"
    end if
    response = event.getData()
    data = response.data
    m.seasonsData.push(data)
    responseCounter = m.seasonsData.count()
    if m.arr.count() = m.counter
        setupContentForSeasons()
    end if
    if responseCounter = 0
        m.seasonList.setFocus(true)
        m.loadingProgress.visible = false
    end if
    m.networkManager.observeField("state", "nextRequestSeries")
end sub


sub onContentHide()
    m.top.focusPassed = false
    m.top.allowFocusToEpisode = false
    m.detatilsEpisode.visible = false
    if m.arr <> invalid
        m.top.passFocusToNav = false
        m.arr.clear()
        m.seasonList.content = invalid
        m.arrayTitles.clear()
        m.seasonsData.clear()
        m.rowElements = 2
        m.counter = 0
        m.indexSeason = 0
        if m.networkManager <> invalid
            m.networkManager.unobserveField("state")
            m.networkManager.unobserveField("response")
        end if
    end if
end sub

sub setupContentForSeasons()
    if m.seasonList.content = invalid
        m.content = CreateObject("roSgNode", "ContentNode")
        m.seasonList.content = m.content
        m.taskNode.content = m.content
    end if
    m.taskNode.seasons = m.seasonsData
    m.taskNode.preview = m.top.preview
    m.taskNode.control = "run"
    hideView(true)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ? ">>> ShowDetailsSerial: onKeyEvent("key", "press")"
    result = false
    if press
        if key = "back"
            if m.serialGroup.visible = false
                _backToSerialGroup()
                return true
            else if m.top.backAfteLoad
                _resetScreen()
                return false
            end if
        else if key = "up"
            if m.seasonList.hasFocus()
                onUpClick()
            else if m.backgroundLogo.hasFocus()
                m.top.passFocusToNav = true
                m.top.passFocusToNavi = true
            end if
            return true
        else if key = "down"
            if m.backgroundLogo.hasFocus()
                onDownClick()
            end if
        else if key = "OK"
            if m.dialog.visible
                m.indexSeason = 0
                m.networkManager.unobserveField("state")
                m.networkManager.unobserveField("response")
                m.networkManager.control = "stop"
                m.detatilsEpisode.visible = false
                return false
            end if
        end if
    end if
    return true
end function