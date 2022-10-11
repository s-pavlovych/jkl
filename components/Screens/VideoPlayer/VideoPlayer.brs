sub init()
    m.reloadCount = 0
    registerView()
    addObserve()
    m.appInfo = CreateObject("roAppInfo")
end sub

sub registerView()
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.backgroundLogo = m.top.findNode("backgroundLogo")
    m.loadingProgress = m.top.findNode("loadingProgress")
    m.timerForCheckState = m.top.findNode("timerForCheckState")
    m.maskForTitle = m.top.findNode("maskForTitle")
    m.sendDataTimer = m.top.findNode("sendDataTimer")
    m.channelName = m.top.findNode("channelName")
    m.shannelTitle = m.top.findNode("shannelTitle")
    m.hideAnimation = m.top.findNode("hideAnimation")
    m.showAnimation = m.top.findNode("showAnimation")
    m.timerForCalculatePercent = m.top.findNode("timerForCalculatePercent")
    m.sheduleList = m.top.findNode("sheduleLive")
    m.shannelTitle.font = sourceSansPro(76)
    m.channelName.font = sourceSansPro(76)
    m.count = 0
    m.counts = 0
end sub

sub filterByDate()
    arrayNext = []
    arrayCurrent = []

    nowDateTimeSec = CreateObject("roDateTime")
    nowDateTimeSec.toLocalTime()

    currentTimeInterval = nowDateTimeSec.AsSeconds()
    index = 0
    for each item in m.global.sheduleLive
        startDate = CreateObject("roDateTime")
        startDate.FromISO8601String(item.begin)
        startDate.toLocalTime()

        endDate = CreateObject("roDateTime")
        endDate.FromISO8601String(item.end)
        endDate.toLocalTime()
        if startDate.AsSeconds() < currentTimeInterval and endDate.AsSeconds() > currentTimeInterval
            arrayCurrent.Push(item)
            arrayNext.Push(m.global.sheduleLive[index + 1])
            exit for
        end if
        index++
    end for
    if arrayCurrent.count() > 0 and arrayNext.count() > 0
        currentShedule = [arrayCurrent[0], arrayNext[0]]
        saveInGlobal("currentShedule", currentShedule)
        createdContentForShedule(currentShedule)
    end if
end sub

sub sendLiveAnalytics()
    di = CreateObject("roDeviceInfo")
    if di.IsRIDADisabled()
        uuid = GenerateUUID()
    else
        uuid = di.GetRIDA()
    end if
    m.arrayItemInNavigationMenu = []
    m.arrayForNavigation = []
    m.getChannelsRequest = CreateObject("roSGNode", "URLRequest")
    m.getChannelsRequest.path = "https://jstre.am/collect"
    if m.top.content.LIVE = true
        t = "live_view"
    else
        t = "vod_view"
    end if
    querry = {
        t: t
        sid: di.getModel()
        pl: "roku"
        v: "5.45"
        stream: m.global.selectedChannel.objectID
        vid: m.top.content.id
    }
    m.getChannelsRequest.querryParams = querry
    m.manager = NetworkManager()
    m.manager.request = m.getChannelsRequest
    m.manager.observeField("response", "onStartupInfo")
    m.manager.control = "RUN"
end sub

sub onStartupInfo(event)
    m.manager.control = "STOP"
    m.manager.unobserveField("response")
    print "sendLiveAnalytics isSuccess = ", event.getData().isSuccess
end sub

sub createdContentForShedule(array)
    contentNode = CreateObject("roSGNode", "ContentNode")
    rowChild = contentNode.createChild("ContentNode")
    for each item in array
        itemContent = rowChild.createChild("ContentNode")
        itemContent.addfield("end", "string", false)
        itemContent.addfield("titleShow", "string", false)
        itemContent.addfield("begin", "string", false)
        itemContent.title = item.titleEpisode
        itemContent.titleShow = item.titleShow
        itemContent.end = item.end
        itemContent.begin = item.begin
    end for
    m.sheduleList.content = contentNode
end sub

sub addObserve()
    m.videoPlayer.observeField("state", "setupVideo")
    m.timerForCheckState.observeField("fire", "checkStatePlayer")
    m.sendDataTimer.observeField("fire", "sendEvery20secVideo")
    m.timerForCalculatePercent.observeField("fire", "calculatePercentForDuration")
end sub

sub calculatePercentForDuration()
    duration = m.videoPlayer.duration
    if m.videoPlayer.positionInfo <> invalid
        positionMarker = m.videoPlayer.positionInfo["video"]
        onePercent = duration / 100
        percent = positionMarker / duration * 100
        second = onePercent * percent
        percentInt = Fix(percent)
        if percentInt = m.arrayMarkers[0]
            m.arrayMarkers.Delete(0)
            m.top.percentVideoPlaying = percentInt
            if m.arrayMarkers[0] = 100
                m.timerForCalculatePercent.control = "stop"
            end if
        end if
    end if
end sub

sub showLabel(event)
    hide = event.getData()
    if hide
        filterByDate()
        m.showAnimation.control = "start"
    else
        m.hideAnimation.control = "start"
    end if
end sub

sub sendEvery20secVideo()
    di = CreateObject("roDeviceInfo")
    model = di.getModel()
    m.google = invalid
    m.google = {
        t: "screenview",
        hit_type: "live_analytics_endpoint_update",
        cd15: m.global.selectedChannel.title,
        live_stream_name: m.global.selectedChannel.title,
        live_stream_id: m.global.selectedChannel.objectID,
        live_cms_channel_id: m.global.selectedChannel.objectID,
        app_version: m.appInfo.GetVersion(),
        app_platform: "Roku",
        country: di.GetCurrentLocale(),
        language: di.GetPreferredCaptionLanguage()
        timestamp: di.GetTimeZone()
        metadata: defaultMetadata()
    }
    ' m.google = {
    ' t: t
    ' sid: di.getModel()
    ' pl: "roku"
    ' v: "5.45"
    ' stream: m.global.selectedChannel.objectID
    ' vid: m.top.content.id

    sendAnalytics()
    sendLiveAnalytics()
end sub

sub updateFocus()
    if m.top.focusKey = 0
        m.arrayMarkers = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        m.videoPlayer.setFocus(true)
    else if m.top.focusKey = 1
        m.videoPlayer.setFocus(false)
    end if
end sub

function showLoadingIndicator(show)
    m.loadingProgress.visible = show
    if show
        m.loadingProgress.control = "start"
    else
        m.loadingProgress.control = "stop"
    end if
end function

sub stopPlayer(event)
    value = event.getData()
    m.videoPlayer.control = value
end sub

sub checkStatePlayer()
    if m.videoPlayer.state = "finished"
        m.videoPlayer.control = "stop"
        m.top.finishedVideo = true
        m.count = 0
    else if m.videoPlayer.state = "buffering"
        if m.count >= 10 and m.top.content.LIVE
        else
            m.count += 1
        end if
    else
        m.count = 0
        m.top.statePlayer = m.videoPlayer.state
    end if
end sub

sub showContent()
    m.sheduleList.content = invalid
    m.timerForCheckState.control = "start"
    logo = "pkg:/images/no-logo.png"
    if m.top.content.rawData <> invalid
        logo = m.top.content.rawData.ln.en.us.logo_alternative
    end if
    if logo <> invalid
        m.backgroundLogo.width = 600
        m.backgroundLogo.height = 423
        m.backgroundLogo.uri = logo
        centerX = (1920 - m.backgroundLogo.width) / 2
        centerY = (1080 - m.backgroundLogo.height) / 2
        m.backgroundLogo.translation = [centerx, centery]
        m.backgroundLogo.visible = true
    else
        m.backgroundLogo.width = 600
        m.backgroundLogo.height = 423
        m.backgroundLogo.uri = "pkg:/images/no-logo.png"
        centerX = (1920 - m.backgroundLogo.width) / 2
        centerY = (1080 - m.backgroundLogo.height) / 2
        m.backgroundLogo.translation = [centerx, centery]
        m.backgroundLogo.visible = true
    end if
    if left(m.global.selectedChannel.title, 12) = "Hope Channel"
        m.channelName.text = "Hope Channel"
        m.channelName.color = "#FFFFFF"
        m.shannelTitle.text = right(m.global.selectedChannel.title, len(m.global.selectedChannel.title) - 12)
    else
        m.channelName.text = m.global.selectedChannel.title
        m.shannelTitle.text = ""
        m.channelName.color = "#FFFFFF"
    end if
    filterByDate()
    m.maskForTitle.uri = "pkg:/images/$$RES$$/maskForLive.png"
    m.videoPlayer.visible = false
    m.videoPlayer.content = m.top.content
    m.videoPlayer.control = "play"
end sub

sub sendAnalytics()
    if m.google <> invalid
        m.global.RSG_analytics.trackEvent = {
            google: m.google
        }
    end if
end sub

sub changePlayerStatus()
    filterByDate()
    state = m.top.isChangePlayerStatus
    if m.top.content <> invalid
        if m.top.content.LIVE and state = "play"
            m.videoPlayer.control = "stop"
            m.top.finishedVideo = true
            showContent()
        else
            m.videoPlayer.control = "stop"
            m.top.finishedVideo = true
            m.videoPlayer.control = state
        end if
    end if
end sub

sub setupVideo()
    ? "setupVideo()", m.videoPlayer.state
    if m.videoPlayer.state = "playing"
        if m.top.focusKey = 1
            m.sendDataTimer.control = "start"
            m.channelName.visible = true
            m.shannelTitle.visible = true
            m.maskForTitle.visible = true
            m.google = invalid
            m.google = {
                t: "screenview",
                hit_type: "live_stream_play",
                live_stream_name: m.global.selectedChannel.title,
                cd15: m.global.selectedChannel.title,
                metadata: defaultMetadata()
            }
        else
            m.timerForCalculatePercent.control = "start"
        end if
        m.backgroundLogo.visible = false
        m.sheduleList.visible = m.videoPlayer.content.LIVE
        m.videoPlayer.visible = true
        showLoadingIndicator(false)
        sendAnalytics()
    else if m.videoPlayer.state = "buffering"
        m.top.hideload = true
        if m.reloadCount = 0
            m.reloadCount = 1
            m.videoPlayer.control = "stop"
            showContent()
        else if not m.top.showContent and m.reloadCount <> 0
            m.reloadCount = 0
        end if
        m.backgroundLogo.visible = true
        m.videoPlayer.visible = false
        m.channelName.visible = false
        m.shannelTitle.visible = false
        m.maskForTitle.visible = false
        m.sheduleList.visible = false
        showLoadingIndicator(true)
    else if m.videoPlayer.state = "stopped"
        m.backgroundLogo.visible = true
        m.videoPlayer.visible = false
        m.channelName.visible = false
        m.shannelTitle.visible = false
        m.maskForTitle.visible = false
        m.sheduleList.visible = false
        m.sendDataTimer.control = "stop"
    else if m.videoPlayer.state = "error"
        m.top.showDialog = true
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ? ">>> VideoPlayer: onKeyEvent("key", "press")"
    result = true
    if not press then return result
    if press
        if key = "back"
            m.top.showContent = false
            m.videoPlayer.control = "stop"
            if m.top.focusKey = 0
                return false
            end if
        end if
    end if
    return result
end function
