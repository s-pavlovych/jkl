' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub init()
    registerView()
end sub

sub registerView()
    m.titleFeatured = m.top.findNode("titleForFeaturedList")
    m.description = m.top.findNode("descriptionFeatured")
    m.showDetailEpisodes = m.top.findNode("showDetailEpisodes")
    m.episodeDetailScreen = m.top.findNode("episodeDetailScreen")
    m.serialsDetailScreen = m.top.findNode("serialsDetailScreen")
    m.featuredList = m.top.findNode("featuredList")
    m.topGroup = m.top.findNode("topGroup")
    m.episodesList = m.top.findNode("episodesList")
    m.expandListAnimation = m.top.findNode("expandListAnimation")
    m.loadingProgress = m.top.findNode("loadingProgress")
    m.upListAnimation = m.top.findNode("upListAnimation")
    observeFields()
    m.getChannelsRequest = CreateObject("roSGNode", "URLRequest")
end sub

sub observeFields()
    m.featuredList.observeField("rowItemSelected", "selectedFeatured")
    m.featuredList.observeField("rowItemFocused", "setFocus")
    m.episodesList.observeField("rowItemSelected", "selectedEpisodes")
    m.expandListAnimation.observeField("state", "onControlChangeToEpisode")
    m.upListAnimation.observeField("state", "onControlChangeToFeature")
    m.featuredList.observeField("content", "onContentChange")
end sub

sub setFocus(event)
    rowItemFocused = event.getData()
    setTextForTitle(rowItemFocused)
end sub

sub setTextForTitle(rowItemFocused)
    content = m.featuredList.content.getChild(0).getChild(rowItemFocused[1])
    m.titleFeatured.text = content.title
    m.description.text = content.shortDescription
    m.titleFeatured.visible = true
    m.description.visible = true
end sub

sub onControlChangeToEpisode(event)
    animeState = event.getData()
    if animeState = "running"
        m.loadingProgress.setFocus(true)
    else if animeState = "stopped"
        m.episodesList.setFocus(true)
    end if
end sub

sub onChangeAllow()
    ? "onChangeALLOW" m.top.changeAllowFocus
    m.top.allowFocusToEpisode = m.top.changeAllowFocus
end sub

sub onHideNavbar(event)
    ? "onHideNavBar"
    showView = event.getData()
    scene = m.top.getScene()
    scene.callFunc("hiddenNavBar", showView)
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
    else
        m.episodeDetailScreen.sentFocusToEpisode = true
    end if
end sub

sub onPassToNavChange()
    ? "onPassToNavChangeCall"
    m.top.passFocusToNavi = true
end sub

sub onControlChangeToFeature(event)
    animeState = event.getData()
    if animeState = "running"
        m.loadingProgress.setFocus(true)
    else if animeState = "stopped"
        m.featuredList.setFocus(true)
    end if
end sub

sub selectedFeatured(event)
    m.key = 0
    m.content = invalid
    index = event.getData()
    m.contentForDetail = m.featuredList.content.getChild(index[0]).getChild(index[1])
    m.content = m.featuredList.content.getChild(index[0]).getChild(index[1])
    shows = m.featuredList.content.getChild(index[0]).getChild(index[1])
    m.id = shows.id
    showLoadingIndicator(true)
    getShowContentFor(m.id)
end sub

sub nextReqeustForSeasons(event)
    state = event.getData()
    if state = "stop"
        m.networkManagerForShowContent.unobserveField("state")
        getSeassonContentFor(m.id)
    end if
end sub

sub nextReqestForEpisodes(event)
    state = event.getData()
    if state = "stop"
        m.networkManagerForSerials.unobserveField("state")
        getEpisodesContentFor(m.id)
    end if
end sub

sub getShowContentFor(shows)
    querry = CreateObject("roAssociativeArray")
    m.getShowContentnFor = CreateObject("roSGNode", "URLRequest")
    m.getShowContentnFor.path = getShowsInfo()
    m.getShowContentnFor.pathArgument = shows
    m.getShowContentnFor.querryParams = querry
    m.networkManagerForShowContent = NetworkManager()
    m.networkManagerForShowContent.request = m.getShowContentnFor
    m.networkManagerForShowContent.observeField("response", "onShowContentRecive")
    m.networkManagerForShowContent.observeField("state", "nextReqeustForSeasons")
    m.networkManagerForShowContent.control = "RUN"
end sub

function getSeassonContentFor(shows)
    querry = CreateObject("roAssociativeArray")
    media = "youtube,vimeo,jetstream,mp4-hd,mp4-sd,mp3,hls,bif"
    limit = "10"
    querry.AddReplace("media", media)
    m.getShowRequestSeasson = CreateObject("roSGNode", "URLRequest")
    m.getShowRequestSeasson.path = getListSeasons()
    m.getShowRequestSeasson.pathArgument = shows
    m.getShowRequestSeasson.querryParams = querry
    m.networkManagerForSerials = NetworkManager()
    m.networkManagerForSerials.request = m.getShowRequestSeasson
    m.networkManagerForSerials.observeField("response", "onSeassonsContentFor")
    m.networkManagerForSerials.observeField("state", "nextReqestForEpisodes")
    m.networkManagerForSerials.control = "RUN"
end function

function getEpisodesContentFor(shows)
    querry = CreateObject("roAssociativeArray")
    media = "youtube,vimeo,jetstream,mp4-hd,mp4-sd,mp3,hls,bif"
    limit = "100"
    querry.AddReplace("media", media)
    querry.AddReplace("limit", limit)
    m.getShowRequestEpisodes = CreateObject("roSGNode", "URLRequest")
    m.getShowRequestEpisodes.path = getShowEpisodes()
    m.getShowRequestEpisodes.pathArgument = shows
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

sub onEpisodeContent(event)
    state = event.getData()
    preview = m.dataForTV
    if state = "stop"
        m.networkManagerForEpisodes.unobserveField("state")
        if m.seasonData.count() > 0
            m.top.focusKey = 3
            m.episodesList.visible = false
            m.featuredList.visible = false
            m.serialsDetailScreen.focusKey = 0
            m.serialsDetailScreen.preview = preview
            hideNavBar(true)
            m.serialsDetailScreen.content = m.seasonData
            m.serialsDetailScreen.visible = true
            showLoadingIndicator(false)
        else if m.episodesData.count() > 0
            hideNavBar(true)
            m.top.focusKey = 3
            m.showDetailEpisodes.focusKey = 0
            m.showDetailEpisodes.visible = true
            m.episodesList.visible = false
            m.featuredList.visible = false
            m.episodeDetailScreen.visible = false
            m.showDetailEpisodes.preview = preview
            showLoadingIndicator(false)
            m.showDetailEpisodes.content = m.episodesData
        else
            m.top.focusKey = 3
            hideNavBar(true)
            m.episodeDetailScreen.content = m.contentForDetail
            m.episodeDetailScreen.showContent = m.contentForDetail
            m.episodeDetailScreen.focusKey = 0
            m.episodeDetailScreen.visible = true
            showLoadingIndicator(false)
        end if
    end if
end sub

sub onShowContentRecive(event)
    response = event.getData()
    if response.data <> invalid
        m.networkManagerForShowContent.unobserveField("response")
        m.dataForTV = response.data
    end if
end sub

sub selectedEpisodes(event)
    index = event.getData()
    episodeSelectedIndex = event.getData()
    m.key = 1
    m.content = invalid
    key = m.episodesList.content.getChild(m.episodesList.rowItemFocused[0]).title
    m.contentForDetail = m.episodesList.content.getChild(index[0]).getChild(index[1])
    episodes = m.arrayEpisodes[key]
    index = episodeSelectedIndex
    shows = m.episodesList.content.getChild(index[0]).getChild(index[1])
    m.id = shows.objectID
    showLoadingIndicator(true)
    getShowContentFor(m.id)
end sub

sub sendAnalytics()
    if m.google <> invalid
        m.global.RSG_analytics.trackEvent = {
            google: m.google
        }
    end if
end sub

sub updateFocus(event)
    indexFocus = event.GetData()
    if indexFocus = 0
        m.google = {
            t: "screenview",
            hit_type: "screen_view_gtm",
            screen_name: "featured",
            metadata: defaultMetadata()
        }
        counter = m.featuredList.content.getChildCount()
        if counter > 0
            content = m.featuredList.content.getChild(0).getChild(0)
            m.featuredList.SetFocus(true)
            sendAnalytics()
        end if
    else if indexFocus = 1
        m.episodesList.SetFocus(true)
    end if
end sub

sub hideScreenView()
    m.topGroup.translation = [0, 0]
    m.episodesList.translation = [80, 960]
    m.episodesList.visible = true
    m.top.hideEpisodeView = true
    m.featuredList.visible = true
    m.top.hideEmbbededScreen = true
    m.showDetailEpisodes.visible = false
    m.episodeDetailScreen.visible = false
    m.serialsDetailScreen.visible = false
end sub

sub changeContent()
    m.featuredItems = m.top.content
    m.episodesList.rowLabelFont = getFontForChannel(m.global.selectedChannel.objectID, 38, "light")
    m.description.font = getFontForChannel(m.global.selectedChannel.objectID, 38, "light")
    m.titleFeatured.font = getFontForChannel(m.global.selectedChannel.objectID, 48, "bold")
    if m.top.content.count() > 0
        m.titleFeatured.text = m.top.content[0].title
    end if
    if IsValid(m.featuredItems[0])
        m.showsEpisodes = m.featuredItems[0]
        fillInContentNodeForFeatured()
        rowItemFocused = [0, 0]
        setTextForTitle(rowItemFocused)
    else
        m.content = CreateObject("roSGNode", "ContentNode")
        m.featuredList.content = m.content
    end if
    if IsValid(m.featuredItems)
        m.dataEpisodes = m.featuredItems
        createdEpisode()
    end if
end sub

function fillInContentNodeForFeatured()
    m.content = CreateObject("roSGNode", "ContentNode")
    m.child = m.content.createChild("ContentNode")
    m.child.Album = m.showsEpisodes.contentType
    if m.showsEpisodes.contentType = "episodes"
        shows = m.showsEpisodes.episodes
    else
        shows = m.showsEpisodes.shows
    end if
    for each item in shows
        content = m.child.createChild("ContentNode")
        content.addfield("backgroundImage", "assocarray", false)
        content.addfield("shortDescription", "string", false)
        content.id = item.id
        content.backgroundImage = item.backgroundImage
        content.addfield("colors", "assocarray", false)
        content.title = item.title
        if m.showsEpisodes.contentType = "shows"
            content.HDPosterUrl = item.images.default.medium.url
            content.SDPosterUrl = item.images.default.medium.url
        else
            content.HDPosterUrl = item.image.medium.url
            content.SDPosterUrl = item.image.medium.url
        end if
    end for
    m.featuredList.content = m.content

end function

sub createdEpisode()
    m.dataEpisodes.shift()
    m.arrayEpisodes = CreateObject("roAssociativeArray")
    m.arrayKey = []
    for each episode in m.dataEpisodes
        title = episode.title
        if title = "Latest Episodes"
            m.arrayKey.push("Latest Episode")
            m.arrayEpisodes.AddReplace(m.arrayKey[0], episode)
        else if title = "Trending Episodes"
            m.arrayKey.push("Trending Episodes")
            m.arrayEpisodes.AddReplace(m.arrayKey[1], episode)
        else
            m.arrayKey.push(title)
            m.arrayEpisodes.AddReplace(title, episode)
        end if
    end for
    m.episodes = CreateObject("roSGNode", "ContentNode")
    for each key in m.arrayKey
        episode = m.arrayEpisodes[key]
        counts = 0
        if episode <> invalid
            counts = episode.Count()
        end if
        if counts <> 0
            m.episodeChild = m.episodes.createChild("ContentNode")
            m.episodeChild.Album = m.showsEpisodes.contentType
            m.episodeChild.title = tr(key)
            addEpisode(episode)
        end if
    end for
    m.episodesList.content = m.episodes
end sub

sub addEpisode(episodes)
    if episodes.contentType = "episodes"
        elementsEposode = episodes.episodes
    else
        elementsEposode = episodes.shows
    end if
    for each value in elementsEposode
        content = m.episodeChild.createChild("ContentNode")
        content.addfield("backgroundImage", "assocarray", false)
        content.addfield("objectID", "string", false)
        content.addfield("shortDescriptions", "string", false)
        content.shortDescriptions = value.abstract
        content.objectID = value.id
        if episodes.contentType = "episodes"
            content.backgroundImage = value.image
        else
            content.backgroundImage = value.images
        end if
        content.addfield("colors", "assocarray", false)
        content.title = value.title
        if value.image <> invalid
            content.HDPosterUrl = value.image.medium.url

            content.SDPosterUrl = value.image.medium.url
        else
            if value.images.poster <> invalid
                content.HDPosterUrl = value.images.poster.small.url
                content.SDPosterUrl = value.images.poster.small.url
            else if value.images.default <> invalid
                content.HDPosterUrl = value.images.default.small.url
                content.SDPosterUrl = value.images.default.small.url
            else
                content.HDPosterUrl = "pkg:/images/defaultImageForCells.png"
                content.SDPosterUrl = "pkg:/images/defaultImageForCells.png"
            end if
        end if
    end for
end sub

sub showLoadingIndicator(show)
    scene = m.top.getScene()
    scene.callFunc("showLoadingIndicator", show)
end sub

sub hide_showPreviousScreen(isHidden)
    m.showDetailEpisodes.visible = isHidden
    m.episodeDetailScreen.visible = isHidden
    m.serialsDetailScreen.visible = isHidden
    m.featuredList.visible = not isHidden
    m.episodesList.visible = not isHidden
end sub

sub hideNavBar(show)
    scene = m.top.getScene()
    scene.callFunc("hiddenNavBar", show)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ? ">>> FeatureScreen: onKeyEvent("key", "press")"
    result = false
    if press
        if key = "right"
            result = false
        else if key = "left"
            result = false
        else if key = "up"
            if m.top.focusKey = 1
                m.top.focusKey = 0
                m.upListAnimation.control = "start"
                result = true
            end if
        else if key = "back"
            if m.top.focusKey = 3
                hide_showPreviousScreen(false)
                m.featuredList.visible = true
                m.featuredList.setFocus(true)
                showLoadingIndicator(false)
                hideNavBar(true)
                m.top.focusKey = m.key
                result = true
            else if m.top.focusKey = 1
                m.top.focusKey = 0
                m.upListAnimation.control = "start"
                result = true
            end if
        else if key = "down"
            elementCount = m.episodesList.content.getChildCount()
            if m.top.focusKey = 0 and elementCount > 0
                m.top.focusKey = 1
                m.expandListAnimation.control = "start"
                result = true
            end if
            result = true
        else if key = "OK"
            if not m.featuredList.visible

            end if
        end if
    end if
    return result
end function
