sub init()
    registerView()
end sub

sub registerView()
    m.showsList = m.top.findNode("showsList")
    m.episodeDetailScreen = m.top.findNode("episodeDetailScreen")
    m.showDetailEpisodes = m.top.findNode("showDetailEpisodes")
    m.serialsDetailScreen = m.top.findNode("serialsDetailScreen")
    configureRowList()
end sub

sub showLoadingIndicator(show)
    scene = m.top.getScene()
    scene.callFunc("showLoadingIndicator", show)
end sub

sub hideNavBar(show)
    scene = m.top.getScene()
    scene.callFunc("hiddenNavBar", show)
end sub

sub hideScreenView()
    ? "hideScreenView"
    m.top.hideEpisodeView = true
    m.showsList.visible = true
    m.episodeDetailScreen.visible = false
    m.serialsDetailScreen.visible = false
    m.showDetailEpisodes.visible = false
end sub

sub configureRowList()
    sizeRowList = 618 * 3
    m.showsList.itemSize = [sizeRowList, 408]
    m.showsList.rowItemSpacing = [[50, 50]]
    m.showsList.itemSpacing = [50, 50]
    m.showsList.rowItemSize = [[568, 408]]
    m.showsList.showRowLabel = false
    m.showsList.focusBitmapBlendColor = "#0646A5"
    m.showsList.numRows = 3
    m.showsList.vertFocusAnimationStyle = "fixedFocus"
    m.showsList.rowFocusAnimationStyle = "floatingFocus"
    m.showsList.observeField("itemSelected", "onItemSelected")
end sub

sub updateFocus()
    focus = m.top.focusKey
    if focus = 0
        setupContentForEpisodes()
    else
        m.showsList.setFocus(true)
        sendAnalytics()
    end if
end sub

sub sendAnalytics()
    if m.google <> invalid
        m.global.RSG_analytics.trackEvent = {
            google: m.google
        }
    end if
end sub

sub focusToNav()

end sub

sub onItemSelected()
    m.elementsCount = 0
    focus = m.showsList.rowItemFocused
    m.shows = m.showsList.content.getChild(m.showsList.itemSelected).getChild(focus[1])
    showLoadingIndicator(true)
    getShowContentFor(m.shows)
end sub

sub getShowContentFor(shows)
    querry = CreateObject("roAssociativeArray")
    m.getShowContentnFor = CreateObject("roSGNode", "URLRequest")
    m.getShowContentnFor.path = getShowsInfo()
    m.getShowContentnFor.pathArgument = shows.id
    m.getShowContentnFor.querryParams = querry
    m.networkManagerForShowContent = NetworkManager()
    m.networkManagerForShowContent.request = m.getShowContentnFor
    m.networkManagerForShowContent.observeField("response", "onShowContentRecive")
    m.networkManagerForShowContent.observeField("state", "nextReqeustForSeasons")
    m.networkManagerForShowContent.control = "RUN"
end sub

sub onShowContentRecive(event)
    response = event.getData()
    if response.data <> invalid
        m.networkManagerForShowContent.unobserveField("response")
        m.dataForTV = response.data
    end if
end sub

function getSeassonContentFor(shows)
    querry = CreateObject("roAssociativeArray")
    media = "youtube,vimeo,jetstream,mp4-hd,mp4-sd,mp3,hls,bif"
    limit = "10"
    querry.AddReplace("media", media)
    m.getShowRequestSeasson = CreateObject("roSGNode", "URLRequest")
    m.getShowRequestSeasson.path = getListSeasons()
    m.getShowRequestSeasson.pathArgument = shows.id
    m.getShowRequestSeasson.querryParams = querry
    m.networkManagerForSerials = NetworkManager()
    m.networkManagerForSerials.request = m.getShowRequestSeasson
    m.networkManagerForSerials.observeField("response", "onSeassonsContentFor")
    m.networkManagerForSerials.observeField("state", "nextReqestForEpisodes")
    m.networkManagerForSerials.control = "RUN"
end function

sub nextReqeustForSeasons(event)
    state = event.getData()
    if state = "stop"
        m.networkManagerForShowContent.unobserveField("state")
        getSeassonContentFor(m.shows)
    end if
end sub

sub onPassToNavChange()
    ? "onPassFocusToChange"
    m.top.passFocusToNav = true
end sub

sub nextReqestForEpisodes(event)
    state = event.getData()
    if state = "stop"
        m.networkManagerForSerials.unobserveField("state")
        getEpisodesContentFor(m.shows)
    end if
end sub

sub onEpisodeContent(event)
    state = event.getData()
    if m.dataForTV <> invalid
        preview = m.dataForTV
    else
        preview = m.shows
    end if

    if state = "stop"
        m.networkManagerForEpisodes.unobserveField("state")
        if m.seasonData.count() > 0
            m.showsList.visible = false
            m.serialsDetailScreen.focusKey = 0
            m.serialsDetailScreen.preview = preview
            hideNavBar(true)
            m.serialsDetailScreen.content = m.seasonData
            m.serialsDetailScreen.visible = true
            showLoadingIndicator(false)
        else if m.episodesData.count() > 0
            m.showDetailEpisodes.focusKey = 0
            m.showDetailEpisodes.visible = true
            m.showsList.visible = false
            m.episodeDetailScreen.visible = false
            m.showDetailEpisodes.preview = preview
            showLoadingIndicator(false)
            m.showDetailEpisodes.content = m.episodesData
        else
            showLoadingIndicator(false)
        end if
    end if
end sub

function getEpisodesContentFor(shows)
    querry = CreateObject("roAssociativeArray")
    media = "youtube,vimeo,jetstream,mp4-hd,mp4-sd,mp3,hls,bif"
    limit = "100"
    querry.AddReplace("media", media)
    querry.AddReplace("limit", limit)
    m.getShowRequestEpisodes = CreateObject("roSGNode", "URLRequest")
    m.getShowRequestEpisodes.path = getShowEpisodes()
    m.getShowRequestEpisodes.pathArgument = shows.id
    m.getShowRequestEpisodes.querryParams = querry
    m.networkManagerForEpisodes = NetworkManager()
    m.networkManagerForEpisodes.request = m.getShowRequestEpisodes
    m.networkManagerForEpisodes.observeField("response", "onEpisodesContentRecive")
    m.networkManagerForEpisodes.observeField("state", "onEpisodeContent")
    m.networkManagerForEpisodes.control = "RUN"
end function

sub onEpisodesContentRecive(event)
    response = event.getData()
    if response.data <> invalid
        if response.data.items.count() > 0
            m.networkManagerForEpisodes.unobserveField("response")
            m.episodesData = response.data.items
        end if
    else
        m.episodesData = []
        showLoadingIndicator(false)
    end if
end sub

sub onChangeAllow()
    m.top.allowFocusToEpisode = m.top.changeAllowFocus
end sub

sub onWhichScreenPass()
    if m.serialsDetailScreen.visible
        if not m.top.allowFocusToEpisode
            m.serialsDetailScreen.focusToImg = true
        else
            m.serialsDetailScreen.sentFocusToEpisode = true
        end if
    else if m.showDetailEpisodes.visible
        if not m.top.allowFocusToEpisode
            m.showDetailEpisodes.focusToImg = true
        else
            m.showDetailEpisodes.sentFocusToEpisodeF = true
        end if
    end if
end sub

sub onSeassonsContentFor(event)
    response = event.getData()
    if response.arrayData <> invalid
        if response.arrayData.count() > 0
            m.seasonData = response.arrayData
            m.networkManagerForSerials.unobserveField("response")
        end if
    else
        m.seasonData = []
        showLoadingIndicator(false)
    end if
end sub

sub onEpisodesContentFor(event)
    m.episodes = event.getData()
end sub

sub setupContentForEpisodes()
    showsContent = m.global.allShows
    content = CreateObject("roSGNode", "ContentNode")
    countSectionMod = showsContent.count() / 3
    countSection = showsContent.count() \ 3
    if countSection = 0
        countSection = 1
    else if countSectionMod / countSection <> 0
        countSection += 1
    end if
    for indexSection = 1 to countSection step 1
        episodes = content.createChild("ContentNode")
        for indexEpisode = (indexSection * 3) - 3 to (indexSection * 3) - 1 step 1
            if indexEpisode < showsContent.count()
                shows = showsContent[indexEpisode]
                episode = episodes.createChild("ContentNodeShows")
                episode.addfield("isShow", "bool", false)
                episode.isShow = true
                episode.title = shows.title
                episode.id = shows.objectID
                episode.colors = shows.colors
                if shows.images.default <> invalid
                    episode.HDPosterUrl = shows.images.default.small.url
                else
                    episode.HDPosterUrl = "pkg:/images/defaultImageForCells.png"
                end if
            end if
        end for
    end for

    if content.getChild(content.getChildCount() - 1).getChildCount() = 0
        content.removeChildIndex(content.getChildCount() - 1)
    end if
    m.showsList.content = content
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ? ">>> ShowsScreen: onKeyEvent("key", "press")"
    if press
        if key = "back"
            if m.showsList.visible = true
                return false
            else
                m.showsList.visible = true
                m.episodeDetailScreen.visible = false
                m.serialsDetailScreen.visible = false
                m.showDetailEpisodes.visible = false
                m.top.focusKey = 1
                hideNavBar(true)
                showLoadingIndicator(false)
                return true
            end if
        else if key = "OK"
            if not m.showsList.visible
                m.showsList.visible = true
                m.episodeDetailScreen.visible = false
                m.serialsDetailScreen.visible = false
                m.showDetailEpisodes.visible = false
                m.top.focusKey = 1
                hideNavBar(true)
                showLoadingIndicator(false)
                return true
            end if
        else if key = "down"
            lastIndex = m.showsList.content.getChildCount()
            focusedIndex = m.showsList.rowItemFocused[0] + 1
            if lastIndex = focusedIndex
                m.showsList.animateToItem = 0
            end if
        end if
    end if
    return false
end function
