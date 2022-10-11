' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub Main(args as object)
    showChannelSGScreen(args)
end sub

sub showChannelSGScreen(args as object)
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    m.global = screen.getGlobalNode()
    deeplink = getDeepLinks(args)
    if deeplink <> invalid
        m.global.addField("deeplink", "assocarray", false)
        m.global.deeplink = deeplink
    end if
    loadStoredInfo()

    screen.show() ' vscode_rale_tracker_entry
    ' vscode_rdb_on_device_component_entry
    scene.observeField("exitApp", m.port)
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if msgType = "roSGNodeEvent" then
            field = msg.getField()
            if field = "exitApp" then
                return
            end if
        end if
    end while
end sub

sub loadStoredInfo()
    defaultChannel = RegRead("selectedChannel")
    if defaultChannel <> invalid
        channelModel = CreateObject("roSGNode", "Channel")
        channelModel.callFunc("mapWith", defaultChannel)
        saveInGlobal("selectedChannel", channelModel)
    end if
end sub

function RegRead(key, section = invalid)
    if section = invalid then section = "Hope"
    '   reg = CreateObject("roRegistry")
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key)
        return parseJson(sec.Read(key))
    end if
    return invalid
end function

sub saveInGlobal(key, data)
    if m.global[key] <> invalid
        m.global[key] = data
    else
        obj = {}
        obj[key] = data
        m.global.addFields(obj)
    end if
end sub

function getDeepLinks(args) as object
    deeplink = invalid
    if args.contentid <> invalid and args.mediaType <> invalid
        deeplink = {
            id: args.contentId
            type: args.mediaType
        }
    end if
    return deeplink
end function