sub init()
    registerView()
end sub

sub registerView()
    m.recommendationList = m.top.findNode("recommendationList")
    m.up_DownContainerAnimation = m.top.findNode("up_DownContainerAnimation")
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.titleEpisode = m.top.findNode("titleEpisode")
    m.descriptionEpisode = m.top.findNode("descriptionEpisode")
    m.fittingLabel = m.top.findNode("fittingLabel")
    m.episodeShow = m.top.findNode("episodeShow")
    m.episodeShow.observeField("itemSelected", "onItemSelected")
    m.episodeShow.observeField("itemFocused", "onVisible")
    m.recommendationList.observeField("itemSelected", "onItemSelectedRecommendationList")
    m.episodesGroup = m.top.findNode("EpisodesGroup")
    m.loadingProgress = m.top.findNode("loadingProgress")
    m.container = m.top.findNode("container")
    m.title = m.top.findNode("title")
    m.translationInterpContainer = m.top.findNode("translationInterpContainer")
    m.translationInterpReccoList = m.top.findNode("translationInterpReccoList")
    m.id = ""
    m.showID = ""
    m.showTitle = ""
    m.serialTitle = ""
    m.seasoneNum = ""
end sub

function onVisible()
    m.episodesGroup.visible = true
end function

sub changePercent(event)
    overwrittenContent()
    m.google = invalid
    m.google = {
        t: "screenview",
        hit_type: "vod_milestone",
        episode_id: m.id,
        episode_title: m.top.content.title,
        video_milestone: m.top.percentVideo,
        cd9: m.id,
        cd10: m.top.content.title,
        metadata: defaultMetadata()
    }
    ifEmptyContent()
end sub

sub ifEmptyContent()
    if m.showID <> ""
        m.google.AddReplace("cd13", m.showID)
        m.google.AddReplace("show_id", m.showID)
    end if

    if m.showTitle <> ""
        m.google.AddReplace("cd14", m.showTitle)
        m.google.AddReplace("show_name", m.showTitle)
    end if

    if m.serialTitle <> ""
        m.google.AddReplace("cd12", m.serialTitle)
        m.google.AddReplace("season", m.serialTitle)
    end if
    sendAnalytics()
end sub

sub showLoadingIndicator(show)
    scene = m.top.getScene()
    scene.callFunc("showLoadingIndicator", show)
end sub

sub sendAnalytics()
    if m.google <> invalid
        m.global.RSG_analytics.trackEvent = {
            google: m.google
        }
    end if
end sub

sub updateFocus()
    if m.top.focusKey = 0
        m.recommendationList.content = invalid
        m.episodeShow.setFocus(true)
    end if
end sub

sub changeFont()
    m.titleEpisode.font = getFontForChannel(m.global.selectedChannel.objectID, 42, "bold")
    m.descriptionEpisode.font = getFontForChannel(m.global.selectedChannel.objectID, 32, "bold")
    m.fittingLabel.font = getFontForChannel(m.global.selectedChannel.objectID, 32, "bold")
end sub

sub showContent()
    if m.top.content <> invalid
        changeFont()
        overwrittenContent()
        m.google = {
            t: "screenview",
            hit_type: "screen_view_gtm",
            screen_name: "Video Detail",
            show_id: m.showID,
            show_name: m.showTitle,
            episode_id: m.id,
            episode_title: m.top.content.title
            brightcove_video_id: "",
            season: m.serialTitle,
            metadata: defaultMetadata()
        }
        ifEmptyContent()
        hideView(true)
        content = m.top.content
        setupDataForShow()
        m.getRequest = CreateObject("roSGNode", "URLRequest")
        m.networkManager = NetworkManager()
        m.networkManager.unobserveField("state")
        m.networkManager.unobserveField("response")
        m.networkManager.control = "stop"
        setupRowListForShow(content)
        showLoadingIndicator(true)
        getRecommendationEpisodesContentFor(m.top.content.objectID)
    end if
end sub

sub setupDataForShow()
    description = m.top.content.DESCRIPTION
    if description = ""
        description = m.top.content.shortDescriptions
    end if
    m.descriptionEpisode.text = description
    font = CreateObject("roSgNode", "Font")
    font.size = 27
    font.uri = "pkg:/fonts/Roboto-Bold.ttf"
    m.descriptionEpisode.font = font
    m.titleEpisode.text = m.top.content.title
    titleFont = CreateObject("roSgNode", "Font")
    titleFont.size = 21
    titleFont.uri = "pkg:/fonts/Roboto-Light.ttf"
    m.title.font = titleFont
    font = invalid
    titleFont = invalid
end sub

sub showDialog(event)
    onVideoUrsDosentExist()
    m.videoPlayer.visible = false
end sub

sub finishedPlayer(event)
    if m.top.showDialog = false
        showNavigationBar(true)
        isFinished = event.getData()
        m.videoPlayer.visible = isFinished
        m.episodeShow.setFocus(true)
    end if
end sub

sub hideView(hide)
    m.descriptionEpisode.visible = hide
    m.titleEpisode.visible = hide
    m.episodeShow.visible = hide
    m.recommendationList.visible = hide
end sub

sub upAnimation()
    m.titleEpisode.setFocus(true)
    m.up_DownContainerAnimation.observeField("state", "onAnimationUpState")
    m.translationInterpReccoList.keyValue = [[80, 500], [80, 660]]
    m.translationInterpContainer.keyValue = [[46, 176], [46, 336]]
    m.up_DownContainerAnimation.control = "start"
end sub

sub downAnimation()
    m.titleEpisode.setFocus(true)
    m.up_DownContainerAnimation.observeField("state", "onAnimationDownState")
    m.translationInterpReccoList.keyValue = [[80, 660], [80, 500]]
    m.translationInterpContainer.keyValue = [[46, 336], [46, 176]]
    m.up_DownContainerAnimation.control = "start"
end sub

sub onAnimationUpState(event)
    state = event.getData()
    if state = "stopped"
        m.episodeShow.setFocus(true)
        m.up_DownContainerAnimation.unobserveField("state")
    end if
end sub

sub onAnimationDownState(event)
    state = event.getData()
    if state = "stopped"
        m.recommendationList.setFocus(true)
        m.up_DownContainerAnimation.unobserveField("state")
    end if
end sub


sub overwrittenContent()
    if m.top.content <> invalid
        m.id = m.top.content.objectID
    end if
    if m.top.showContent <> invalid
        m.showID = m.top.showContent.objectID
        m.showTitle = m.top.showContent.title
    end if
    if m.top.serialContent <> invalid
        m.serialTitle = m.top.serialContent.title
        m.serialID = m.top.serialContent.objectID
    end if
    if m.top.seasoneNumber <> invalid
        m.seasoneNum = m.top.seasoneNumber
    end if
end sub

sub onItemSelected()
    m.videoPlayer.showContent = true
    overwrittenContent()
    m.google = invalid
    m.google = {
        t: "screenview",
        hit_type: "vod_play",
        show_id: m.showID,
        show_name: m.showTitle,
        episode_id: m.id,
        episode_title: m.top.content.title,
        brightcove_video_id: "",
        season_id: m.serialID,
        season_title: m.serialTitle,
        season_number: m.seasoneNum,
        season_group: m.seasoneNum
        metadata: defaultMetadata()
    }
    ifEmptyContent()
    if m.top.content.id = ""
        id = m.top.content.objectID
    else
        id = m.top.content.id
    end if
    getVideoContentFor(id)
end sub

sub onItemSelectedRecommendationList()
    content = m.recommendationList.content.getChild(0).getChild(m.recommendationList.rowItemSelected[1])
    m.top.content = content
    m.videoPlayer.showContent = true
    upAnimation()
end sub

sub getVideoContentFor(idEpisode)
    m.getRequest.path = getEpisopdesByID()
    m.getRequest.pathArgument = idEpisode
    m.networkManager.request = m.getRequest
    m.networkManager.observeField("response", "onVideoContentFor")
    m.networkManager.control = "RUN"
end sub

sub sortedMediaFormat(response as object)
    videoData = {}
    links = response.data.mediaLinks
    di = CreateObject("roDeviceInfo")
    displayMode = di.GetDisplayMode()
    streamFormat = ""
    link = invalid
    if isValid(links.hls)
        link = links.hls.url
        streamFormat = "hls"
    else if isValid(links["mp4-hd"])
        di = CreateObject("roDeviceInfo")
        displayMode = di.GetDisplayMode()
        if displayMode = "1080p" or displayMode = "720p"
            link = links.["mp4-hd"].url
            streamFormat = "mp4"
        else if IsValid(links["mp4-sd"])
            link = links["mp4-sd"].url
            streamFormat = "mp4"
        else
            onVideoUrsDosentExist()
        end if
    end if
    media_format = streamFormat
    videoData["link"] = link
    videoData["media_format"] = media_format
    if link <> invalid
        showNavigationBar(false)
        playVideo(videoData)
    else
        showNavigationBar(true)
        onVideoUrsDosentExist()
    end if
end sub

sub showNavigationBar(showBar)
    m.top.hideNavbar = showBar
    m.top.hideNavbarSerials = showBar
    m.top.hideNavbarFeature = showBar
end sub

sub onVideoUrsDosentExist()
    errorScreen = CreateObject("roSgNode", "ErrorCustomDialog")
    errorScreen.translation = [(1920 - errorScreen.boundingRect().width) / 2, (1080 - errorScreen.boundingRect().height) / 2]
    errorScreen.observeField("erroBtnClicekd", "onErrorBtnClicked")
    m.top.getScene().callFunc("showError", errorScreen)

    errorScreen.setFocus(true)
end sub

sub onErrorBtnClicked()
    m.episodeShow.setFocus(true)
end sub

sub playVideo(videoFormat as object)
    videoContent = createObject("RoSGNode", "ContentNode")
    if videoFormat <> invalid
        videoContent.url = videoFormat.link
        ? "videoContent.url: " videoContent.url
        videoContent.sdbifurl = "https://storage.googleapis.com/prod-uploads-01-930013d/samples/vod.bif"
        videoContent.STREAMFORMAT = videoFormat.media_format
        m.videoPlayer.translation = [0, -140]
        m.videoPlayer.visible = true
        m.videoPlayer.setFocus(true)
        m.videoPlayer.focusKey = 0
        m.videoPlayer.content = videoContent
    else
        onVideoUrsDosentExist()
    end if
end sub

sub onVideoContentFor(event)
    responseDataRecived = event.getData()
    m.networkManager.unobserveField("response")
    m.networkManager.control = "STOP"
    sortedMediaFormat(responseDataRecived)
end sub

sub getRecommendationEpisodesContentFor(idEpisode)
    querry = {}
    media = "youtube,vimeo,jetstream,mp4-hd,mp4-sd,mp3,hls,bif"
    limit = "10"
    querry["media"] = media
    querry["limit"] = limit
    m.getRequest.path = getReleaedEpisodes()
    m.getRequest.pathArgument = idEpisode
    m.networkManager.request = m.getRequest
    m.networkManager.observeField("response", "onRecommendationEpisodesContentFor")
    m.networkManager.control = "RUN"
end sub

sub onRecommendationEpisodesContentFor(event)
    response = event.getData()
    setupRowListFor(response.arrayData)
    m.networkManager.unobserveField("response")
    m.networkManager.control = "stop"
end sub

sub setupRowListFor(recommendationEpisodes)
    if recommendationEpisodes <> invalid
        if recommendationEpisodes.count() > 0
            content = CreateObject("roSGNode", "ContentNode")
            section = content.createChild("ContentNode")
            section.title = "Recommended"
            for each episode in recommendationEpisodes
                seasonNode = section.createChild("ContentNode")
                seasonNode.title = episode.title
                seasonNode.description = episode.short_description
                seasonNode.titleSeason = "Recommendation"
                if episode.image <> invalid
                    seasonNode.HDPosterUrl = episode.image.small.url
                else
                    seasonNode.HDPosterUrl = "pkg:/images/defaultImageForCells.png"
                end if
                seasonNode.id = episode.id
            end for
            hideView(true)
            m.recommendationList.content = content
        else
            m.recommendationList.visible = false
        end if
    end if
    showLoadingIndicator(false)
end sub

sub onSentFocusToEpisodes()
    m.episodeShow.setFocus(true)

end sub

sub setupRowListForShow(episode)
    content = CreateObject("roSGNode", "ContentNode")
    section = content.createChild("ContentNode")
    episodeNode = section.createChild("ContentNode")
    if episode.SDPOSTERURL <> ""
        episodeNode.HDPosterUrl = episode.SDPOSTERURL
    else if episode.HDPOSTERURL <> ""
        episodeNode.HDPosterUrl = episode.HDPOSTERURL
    else
        episodeNode.HDPosterUrl = "pkg:/images/defaultImageForBigCells.png"
    end if
    m.episodeShow.content = content
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ? ">>> EpisodeDetails: onKeyEvent("key", "press")"
    result = false
    if press
        if key = "back"
            if m.videoPlayer.visible = true
                showNavigationBar(true)
                m.episodeShow.setFocus(true)
                m.episodesGroup.visible = true
                m.videoPlayer.visible = false
                return true
            end if
            if m.episodeShow.focusedChild <> invalid
                m.top.hide_showNavigation = true
                m.focus = false
                hideView(false)
                m.episodesGroup.visible = false
                showLoadingIndicator(false)
                return false
            else
                upAnimation()
                return true
            end if
        end if
        if key = "down"
            if m.descriptionEpisode.focusedChild = invalid and m.recommendationList.content <> invalid
                recomendCount = m.recommendationList.content.getChildCount()
                if recomendCount > 0 and m.episodeShow.hasFocus()
                    DownAnimation()
                    return true
                end if
            end if
        else if key = "up"
            if m.episodeShow.hasFocus()
                m.top.passFocusToNav = true
                m.top.passFocusToNavi = true
                m.top.passFocusToNavigation = true
                return true
            end if
            if m.descriptionEpisode.focusedChild = invalid
                if m.recommendationList.hasFocus()
                    upAnimation()
                    return true
                end if
            else
                m.descriptionEpisode.setFocus(true)
            end if
            return true
        else if key = "right"
            return true
        else if key = "left"
            return true
        end if
    end if
    return result
end function