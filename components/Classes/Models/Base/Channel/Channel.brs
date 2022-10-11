function mapWith(params)
    capota = params
    m.top.title = getValueFor("title", "roString", params)
    m.top.description = getValueFor("description", "roString", params)
    m.top.id = getValueFor("id", "roString", params)
    m.top.streams = getValueFor("appSettings", "roArray", params)
    m.top.mainLang = getValueFor("mainLanguage", "roArray", params)
    mapWithBase(params)  
  
end function

function getVideoContent(params = invalid)
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.url = m.top.streams[0].link
    videoContent.title = m.top.title
    if m.top.streams[0].media_format = "m3u8"
        videoContent.streamformat = "m3u8"
    else
        videoContent.streamformat = "m3u8"
    end if
    return videoContent
end function
