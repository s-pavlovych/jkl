sub init()   
    registerView()
end sub

sub showContent()
    m.content = m.top.selectedContent
    getLiveContentFor(m.top.selectedContent.objectID)
    m.videoPlayer.focusKey = 1
    evt =""
    contentForVideo(evt)
end sub 
sub updateFocus()
    focus = m.top.focusKey
    if focus = 0
        m.google = {
            t : "screenview",
            hit_type : "screen_view_gtm",
            screen_name : "live stream",
            metadata: defaultMetadata()
          }
        sendAnalytics()
    end if    
end sub

sub sendAnalytics()
    m.global.RSG_analytics.trackEvent = {
      google: m.google
    }
end sub

sub registerView()
    m.videoPlayer = m.top.findNode("videoPlayer")
end sub  

sub changeStatePlayer(event)
   ? m.top.statePlayer
end sub  

sub getLiveContentFor(channel)
    m.getShowRequestLive = CreateObject("roSGNode", "URLRequest")
    m.getShowRequestLive.path = getChannelById()
    m.getShowRequestLive.pathArgument = channel
    m.networkManagerForLive = NetworkManager()
    m.networkManagerForLive.request = m.getShowRequestLive
    m.networkManagerForLive.observeField("response", "onLiveContentFor")
    m.networkManagerForLive.control = "RUN"
end sub

sub onLiveContentFor(event)
    m.networkManagerForLive.control = "STOP"
    m.networkManagerForLive.unobserveField("response")  
    response = event.getData()
    
    if isValid(response.data)
        if response.data.appSettings.livestream.enabled
            livestreamUrl = response.data.appSettings.livestream.url
            contentForVideo(livestreamUrl)
        end if
    end if
end sub  

sub contentForVideo(evt)
    m.videoContent = createObject("RoSGNode", "ContentNode")
    m.videoContent.url = evt
    m.videoContent.title = ""
    m.videoContent.LIVE = true
    m.videoContent.streamformat = "hls"
    m.videoPlayer.content = m.videoContent
end sub

sub showLabel(event)
    hide = event.getData()
    m.videoPlayer.showLabel = hide
end sub   

sub stopPlayer()
    m.videoPlayer.stopLive = m.top.stopPlayer
end sub

sub changePlayerStatus()
    m.videoPlayer.isChangePlayerStatus = m.top.isChangePlayerStatus
end sub    

function onKeyEvent(key as String, press as Boolean) as Boolean
    ? ">>> LiveScreen: onKeyEvent("key", "press")"
    result = false
    if not press then return result
    if key = "OK"
        newLiveScreen = CreateObject("roSGNode", "LiveScreen")
        newLiveScreen.backgroundColor = "#000000"
        showScreen(newLiveScreen)
        result = true
    end if
    return result 
end function