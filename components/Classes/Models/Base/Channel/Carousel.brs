function mapWith(params)
    mapWithBase(params)  
    m.top.title = getValueFor("title", "roString", params)
    m.top.image = getValueFor("small", "roAssociativeArray", params.image)
end function