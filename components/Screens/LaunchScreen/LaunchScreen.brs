sub init()
    initSubvies()
end sub
function getStartupInfo(params = invalid)
    querry = CreateObject("roAssociativeArray")
    querry.AddReplace("sort", "geolocation")
    m.arrayItemInNavigationMenu = []
    m.arrayForNavigation = []
    m.getChannelsRequest = CreateObject("roSGNode", "URLRequest")
    m.getChannelsRequest.path = getChannelsList()
    m.getChannelsRequest.querryParams = querry
    m.manager = NetworkManager()
    m.manager.request = m.getChannelsRequest
    m.manager.observeField("response", "onStartupInfo")
    m.manager.observeField("state", "nextRequestForLive")
    m.manager.control = "RUN"
end function

sub onStartupInfo(event)
    response = event.getData()
    if response.isSuccess
        if isValid(response.arrayData)
            channels = []
            for each item in response.arrayData
                channelModel = CreateObject("roSGNode", "Channel")
                channelModel.callFunc("mapWith", item)
                channels.push(channelModel)
            end for
            if m.global.firstLaunchChannel = invalid
                saveInGlobal("firstLaunchChannel", channels[0])
                RegWrite("firstLaunchChannel", FormatJson(channels[0].rawData))
            end if
            if m.global.selectedChannel = invalid

                saveInGlobal("selectedChannel", channels[0])
                RegWrite("selectedChannel", FormatJson(channels[0].rawData))
            end if
            saveInGlobal("availableChannels", channels)
        else
            'show error
        end if
    end if
    m.manager.unobserveField("response")
end sub

sub nextRequestForLive(event)
    state = event.getData()
    if state = "stop"
        m.manager.unobserveField("state")
        getLiveContentFor(m.global.selectedChannel.id)
    end if
end sub

sub getSheduleInfo(channel)
    querry = CreateObject("roAssociativeArray")
    date = CreateObject("roDateTime")
    timeStamp = CreateObject("roDateTime")
    timeStamp.ToLocalTime()
    date.ToLocalTime()
    curentDate = date.AsSeconds()
    curentDate = curentDate - 4 * 3600
    date.FromSeconds(curentDate)
    startTime = date.ToISOString()
    ? "startTime: " startTime
    toTime = date.AsSeconds()
    toTime = toTime + 60 * 60 * 12
    timeStamp.FromSeconds(toTime)
    endTime = timeStamp.ToISOString()
    querry.AddReplace("from", startTime)
    querry.AddReplace("to", endTime)
    querry.AddReplace("limit", "200")
    m.getChannelsRequest.path = getListBroadCast()
    m.getChannelsRequest.pathArgument = channel.id
    m.getChannelsRequest.querryParams = querry
    m.manager.request = m.getChannelsRequest
    m.manager.observeField("response", "requestShedule")
    m.manager.observeField("state", "nextRequestForFeature")
    m.manager.control = "RUN"
end sub

sub nextRequestForFeature(event)
    state = event.getData()
    if state = "stop"
        m.manager.unobserveField("state")
        getCollectionData(m.global.selectedChannel.id)
    end if
end sub

sub requestShedule(event)
    response = event.getData()
    if response.isSuccess
        shedule = []
        for each item in response.data.items
            channelModel = CreateObject("roSGNode", "SheduleModel")
            channelModel.callFunc("mapWith", item)
            shedule.push(channelModel)
        end for
        saveInGlobal("sheduleLive", shedule)
        m.manager.unobserveField("response")
    end if
end sub

sub nextRequestForShedule(event)
    state = event.getData()
    if state = "stop"
        m.manager.unobserveField("state")
        getSheduleInfo(m.global.selectedChannel)
    end if
end sub

sub getLiveContentFor(channel)
    m.getChannelsRequest.path = getChannelById()
    m.getChannelsRequest.pathArgument = channel
    m.manager.request = m.getChannelsRequest
    m.manager.observeField("response", "onLiveContentFor")
    m.manager.observeField("state", "nextRequestForShedule")
    m.manager.control = "RUN"
end sub

sub onLiveContentFor(event)
    response = event.getData()
    if response.data <> invalid
        if response.data.appSettings.livestream.enabled = false
            m.arrayItemInNavigationMenu.Push(" ")
        else
            if m.arrayItemInNavigationMenu[0] <> "LIVE"
                m.arrayItemInNavigationMenu.Push("LIVE")
                m.arrayForNavigation.Push("LiveScreen")
            end if
        end if
    end if
    m.manager.unobserveField("response")
end sub

function getCollectionData(channel)
    m.getChannelsRequest.path = getListCollections()
    m.getChannelsRequest.pathArgument = channel
    query = { media: "youtube,vimeo,jetstream,mp4-hd,mp4-sd,mp3,hls,bif" }
    m.getChannelsRequest.querryParams = query
    m.manager.request = m.getChannelsRequest
    m.manager.observeField("response", "onCollectionContent")
    m.manager.observeField("state", "nextRequestForShowsElements")
    m.manager.control = "RUN"
end function

sub nextRequestForShowsElements(event)
    state = event.getData()
    if state = "stop"
        m.manager.unobserveField("state")
        getShowsElement(m.global.selectedChannel.id)
    end if
end sub

sub onCollectionContent(event)
    response = event.getData()
    if response.isSuccess
        featured = []
        if response.arrayData <> invalid
            if response.arrayData.count() = 0
                m.arrayItemInNavigationMenu.Push(" ")
            else
                m.arrayItemInNavigationMenu.Push("FEATURED")
                m.arrayForNavigation.Push("FeatureScreen")
            end if
            for each item in response.arrayData
                featured.push(item)
            end for
            m.manager.unobserveField("response")
            saveInGlobal("featured", featured)
        end if
    else
        '     'show error
    end if

end sub

' episodes request
function getShowsElement(channel)
    querry = CreateObject("roAssociativeArray")
    media = "youtube,vimeo,jetstream,mp4-hd,mp4-sd,mp3,hls,bif"
    limit = "100"
    skip = "0"
    sort = "title"
    querry.AddReplace("media", media)
    querry.AddReplace("limit", limit)
    querry.AddReplace("skip", skip)
    querry.AddReplace("sort", sort)
    m.getChannelsRequest.path = getListShows()
    m.getChannelsRequest.pathArgument = channel
    m.getChannelsRequest.querryParams = querry
    m.manager.request = m.getChannelsRequest
    m.manager.observeField("response", "onShowsContent")
    m.manager.observeField("state", "onShowDataStopObserver")
    m.manager.control = "RUN"
end function


function onShowDataStopObserver(event)
    state = event.getData()
    if state = "stop"
        m.manager.unobserveField("state")
    end if
end function

sub onShowsContent(event)
    response = event.getData()

    if response.isSuccess
        shows = []
        if response.data.items.count() = 0
            m.arrayItemInNavigationMenu.Push(" ")
            saveInGlobal("arrayItemInNavigationMenu", m.arrayItemInNavigationMenu)
        else
            m.arrayItemInNavigationMenu.Push("SHOWS")
            m.arrayForNavigation.Push("ShowsScreen")
        end if
        for each item in response.data.items
            if item.episodeCount <> 0
                showsModel = CreateObject("roSGNode", "Shows")
                showsModel.callFunc("mapWith", item)
                shows.push(showsModel)
            end if
        end for
        shows = sortArray(shows, "title")
        saveInGlobal("allShows", shows)
        m.arrayItemInNavigationMenu.Push("CHANNELS")
        saveInGlobal("arrayItemInNavigationMenu", m.arrayItemInNavigationMenu)
    else
        'show error
    end if
    m.manager.control = "STOP"
    m.manager.unobserveField("response")
    m.arrayItemInNavigationMenu.Push("CHANNELS")
    m.arrayItemInNavigationMenu.pop()
    m.arrayForNavigation.Push("SettingsScreen")
    saveInGlobal("arrayForNavigation", m.arrayForNavigation)
    m.top.startupInfoDidLoad = true
    ' getEpisodesTrending(shows[0])
end sub

sub initSubvies()
    m.navigationStack = m.top.findNode("navigationStack")
    appDidLaunchBeacon()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ? ">>> LaunchScreen: onKeyEvent("key", "press")"
    result = false
    if not press then return result
    result = true
    return result
end function