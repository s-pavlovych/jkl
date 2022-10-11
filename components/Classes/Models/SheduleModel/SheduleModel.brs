function mapWith(params)
    mapWithBase(params)  
    m.top.begin = getValueFor("startsAt", "roString", params)
    m.top.end = getValueFor("endsAt", "roString", params)
    m.top.titleEpisode = getValueFor("title", "roString", params.episode)
    m.top.titleShow = getValueFor("title", "roString", params.show)
end function