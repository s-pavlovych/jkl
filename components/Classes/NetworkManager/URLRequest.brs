function  getUrl(params = invalid) as String
    pathUrl= Substitute(m.top.path, m.top.pathArgument)
   
    ' pathUrl = m.top.path + "/" + m.top.pathArgument
    ? "url" pathUrl

    pathUrl += getQuerryString()  
   
    ' if m.top.path = "/seasons/{0}/episodes"
    '     pathUrl += "filter=%7B%22limit%22%3A%20100%7D"
    ' end if
    return pathUrl
end function

function getBody(params = invalid)

end function

function getHeaders(params = invalid)
    return {}
end function

function getQuerryString()
    string ="?"
    if m.top.querryParams <> invalid
    for each parmsPair in m.top.querryParams
        ?"parametr" parmsPair
     string += parmsPair + "=" + m.top.querryParams[parmsPair] + "&"
    end for
   end if    
    return string
end function

function getDefaultQuerryParams()
    ' querry = {}
    ' appInfo = CreateObject("roAppInfo")
    ' deliveryChannel = appInfo.GetValue("deliveryChannelId")
    ' querry["delivery_channel"] = deliveryChannel    
    ' querry["lang"] = getAppLanguage()
    ' querry["all"] = "true"
    ' return querry
end function
