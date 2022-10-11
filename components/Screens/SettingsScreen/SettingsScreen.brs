' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub init()
    registerViews()
end sub

sub registerViews()
    m.versionLabel = m.top.findNode("versionLabel")
    m.liveLogo = m.top.findNode("liveLogo")
    m.featuredLogo = m.top.findNode("featuredLogo")
    m.showsLogo = m.top.findNode("showsLogo")
    m.buttonGroup = m.top.findNode("buttonGroup")
    m.enableBackgroud = m.top.findNode("backgroundHidden")
    m.channelList = m.top.findNode("channelList")
    m.channelList.observeField("itemFocused", "setIndexPath")
    m.descriptionAlert = m.top.findNode("descriptionsAlert")
    m.descriptionAlert.font = robotoOfSize(30)
    m.titleLabel = m.top.findNode("titlelabel")
    m.mexamplePoster = m.top.findNode("examplePoster")
    m.channelList.observeField("itemSelected", "didSelectRowAt")
    m.alert = m.top.findNode("alert")
    m.alertButtons = m.top.findNode("buttonsForAlert")
    m.alertButtons.observeField("itemSelected", "selectAlert")
    m.backButton = m.top.findNode("backButton")
    m.icBackButton = m.top.findNode("icBackButton")
    m.focused = m.top.findNode("focused")
    m.channel = m.global.selectedChannel
end sub

sub updateFocus(event)
    index = event.GetData()
    if index = 0
        m.buttonGroup.visible = true
        m.alert.visible = false
        m.enableBackgroud.visible = false
        m.backButton.uri = "pkg:/images/button.png"
        m.icBackButton.uri = "pkg:/images/Icon.png"
        m.channelList.SetFocus(true)
        m.alert.visible = false
        m.enableBackgroud.visible = false
        m.google = {
            t: "screenview",
            hit_type: "screen_view_gtm",
            screen_name: "settings-affiliate",
            metadata: defaultMetadata()
        }
        sendAnalytics()

    else if index = 1
        m.buttonGroup.visible = false
        m.alert.visible = false
        m.enableBackgroud.visible = false
        m.channelList.SetFocus(false)
        m.top.setFocus(true)
        m.backButton.uri = "pkg:/images/buttonSelected.png"
        m.icBackButton.uri = "pkg:/images/IconWhite.png"
        m.alert.visible = false
        m.enableBackgroud.visible = false
    else if index = 2
        m.alert.visible = true
        m.enableBackgroud.visible = true
        m.alertButtons.SetFocus(true)
        m.alertButtons.jumpToItem = 0
    else if index = 4

    end if
end sub

sub sendAnalytics()
    m.global.RSG_analytics.trackEvent = {
        google: m.google
    }
end sub

sub setIndexPath(event)
    indexPath = event.GetData()
    content = m.channelList.content.getChild(indexPath).getChild(0)
    if content.isFeatured
        m.featuredLogo.uri = "pkg:/images/selecteFeat.png"
    else
        m.featuredLogo.uri = "pkg:/images/Vector-7.png"
    end if
    if content.isLive
        m.liveLogo.uri = "pkg:/images/liveSelected.png"
    else
        m.liveLogo.uri = "pkg:/images/liveSettings.png"
    end if
    if content.isShows
        m.showsLogo.uri = "pkg:/images/showSelected.png"
    else
        m.showsLogo.uri = "pkg:/images/show.png"
    end if
end sub


sub changeContent(event)
    m.contents = CreateObject("roSGNode", "ContentNode")
    items = m.top.content
    for each item in items
        m.childs = m.contents.createChild("ContentNode")
        addChannel(item)
    end for
    addAppVersion()
    m.channelList.content = m.contents

end sub

sub addAppVersion()
    m.child.addfield("isAppVersion", "bool", false)
    m.child.isAppVersion = true
end sub

sub addChannel(item)
    m.child = m.childs.createChild("ContentNode")
    m.child.title = item.title
    m.child.addfield("isFeatured", "bool", false)
    m.child.addfield("isLive", "bool", false)
    m.child.addfield("isShows", "bool", false)
    m.child.addfield("country", "string", false)
    m.child.isShows = item.rawData.appSettings.videoOnDemand.enabled
    m.child.country = item.rawData.mainLanguage
    m.child.isLive = item.rawData.appSettings.livestream.enabled
    m.child.isFeatured = item.rawData.appSettings.schedule.enabled
end sub

sub reloadData()
    scene = m.top.getScene()
    scene.callFunc("showLaunchScreen", {})
end sub

sub selectAlert()
    if m.alertButtons.itemFocused = 0
        content = m.channelList.content.getChild(m.itemRowSelected)
        m.alert.visible = false
        nameChannel = content.getChild(0).title
        message = "Channel changed" + " " + nameChannel
        writeCloudLog("INFO", message)
        m.enableBackgroud.visible = false
        m.channelList.SetFocus(true)
        m.buttonGroup.visible = false
        channelSave = []
        item = m.top.content[m.itemRowSelected]

        channelModel = CreateObject("roSGNode", "Channel")
        channel = item.rawData
        channelModel.callFunc("mapWith", channel)
        channelSave.push(channelModel)


        selectedChannelAnalytics(LCase(channelSave[0].TITLE))
        saveInGlobal("selectedChannel", channelSave[0])
        RegWrite("selectedChannel", FormatJson(channelSave[0].rawData))
        reloadData()
    else
        m.alert.visible = false
        m.enableBackgroud.visible = false
        m.top.focusKey = 0
        m.channelList.SetFocus(true)
    end if
end sub

sub didSelectRowAt(value)
    index = value.GetData()
    preservedChannel = m.global.selectedChannel.title
    selectedChannel = m.channelList.content.getChild(index).getChild(0).TITLE
    if preservedChannel <> selectedChannel
        m.top.resetScreens = true
        m.itemRowSelected = index
        items = m.channelList.content.getChild(m.itemRowSelected).getChild(0)
        m.descriptionAlert.text = tr("We'll refresh the app with content from ") + items.TITLE
        m.top.focusKey = 2
    end if
end sub

sub selectedChannelAnalytics(channel as string)
    if m.channel <> invalid
        m.google = invalid
        m.google = {
            t: "screenview",
            hit_type: "live_stream_change",
            live_stream_name: "previous channel name " + LCase(m.channel.title),
            live_stream_name: "next channel name " + channel,
            metadata: defaultMetadata()
        }

        m.google = {
            t: "screenview",
            hit_type: "affiliate_change",
            affiliate_change: channel,
            metadata: defaultMetadata()
        }
    end if

    sendAnalytics()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ? ">>> SettingsScreen: onKeyEvent("key", "press")"
    result = false
    if press
        if key = "OK"
            if m.top.focusKey = 1
                m.backButton.uri = "pkg:/images/button.png"
                m.icBackButton.uri = "pkg:/images/Icon.png"
                result = false
            else
                result = true
            end if
        end if
        if key = "back"
            if m.top.focusKey = 2
                m.top.focusKey = 0
                result = true
            else if m.top.focusKey = 1
                m.top.focusKey = 0
                result = true
            else if m.top.focusKey = 0
                m.buttonGroup.visible = false
                result = false
            end if
        else if key = "down"
            if m.top.focusKey = 1
                result = true
            end if
            result = true
        else if key = "right"
            if m.top.focusKey = 1
                m.top.focusKey = 0
                result = true
            else
                result = true
            end if
        else if key = "left"
            if m.top.focusKey = 0
                m.top.focusKey = 1
                result = true
            end if
        else if key = "up"
            if m.top.focusKey = 1
                m.backButton.uri = "pkg:/images/button.png"
                m.icBackButton.uri = "pkg:/images/Icon.png"
            end if
            result = false
        end if
        return result
    end if
end function
