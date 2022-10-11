sub init()
    m.top.functionName = "sendRequest"
end sub

function sendRequest()
    url = m.top.baseUrl
    request = m.top.request
    if url = invalid or request = invalid then return invalid
    if m.top.fullURL = "" 
        ' url += request.callFunc("getUrl", {})
    else 
        url = m.top.fullURL
        m.top.fullURL = ""
    end if
    if request.body = invalid 
         body = request.callFunc("getBody", {})
    else
        body = request.body
    end if

    headers = request.callFunc("getHeaders", {})     
    if request.method = "POST"
        response = postRequest(url, body, headers)
        if response = invalid 
            m.top.control = "STOP"
        end if

    else
        response = getRequest(url, headers)       
    end if
    responseModel = CreateObject("roSGNode", "URLResponse")
    responseModel.callFunc("initWithResponse", response)
    m.top.response = responseModel   
end function

function getRequest(url, headers = invalid) as object
   

    res = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    res.SetPort(port)
    res.setURL(url)
    h = getDefaultHeders()
    if headers <> invalid
        h.Append(headers)
    end if
    res.SetHeaders(h)
    res.EnableEncodings(true)
    res.SetCertificatesFile("common:/certs/ca-bundle.crt")
    res.InitClientCertificates()

    if res.AsyncGetToString()
        while true
            msg = Wait (0, port)
            if Type (msg) = "roUrlEvent"
                resJson = invalid
                if msg.GetResponseCode() = 200
                    resJson = ParseJson(msg.GetString())                            
                end if                        
                #if LOG_REQUEST_ENABLED                                           
                    ? ""
                    ? "======================GET========================== "
                    ? "URL: " url
                    ? ""
                    ? "HEADERS: " h
                    ? "=================================================== "
                    ? ""
                    ? "RESPONSE CODE: " msg.GetResponseCode().toStr()
                    ? "=================================================== "
                    ? ""
                    ? "RESPONSE: " resJson
                    ? "=================================================== "
                    ? ""
                #end if           
                return resJson
              
                exit while
            else if Type (msg) = "Invalid"
                res.AsyncCancel()
                exit while
            end if
        end while
    end if
end function

function postRequest(url, body, headers = invalid)
    http = CreateObject("roUrlTransfer")
    http.RetainBodyOnError(true)
    port = CreateObject("roMessagePort")
    http.SetPort(port)
    http.SetCertificatesFile("common:/certs/ca-bundle.crt")
    http.InitClientCertificates()
    http.setURL(url)
    http.EnableEncodings(true)

    h = getDefaultHeders()
    if headers <> invalid
        h.Append(headers)
    end if
    http.SetHeaders(h)

    body = FormatJson(body)

    if http.AsyncPostFromString(body) then
        event = Wait(35000, http.GetPort())
        if Type(event) = "roUrlEvent" then
            resJson = invalid
            if event.GetResponseCode() = 200
                resJson = ParseJson(event.GetString()) 
            else
                resJson = ParseJson(event.GetString())                    
            end if                       
            #if LOG_REQUEST_ENABLED                    
                ? ""
                ? "======================POST========================== "
                ? "URL: " url
                ? ""
                ? "BODY: " body
                ? ""
                ? "HEADERS: " h
                ? "=================================================== "
                ? ""
                ? "RESPONSE CODE: " event.GetResponseCode().toStr()
                ? "=================================================== "
                ? ""
                ? "RESPONSE: " resJson
                ? "=================================================== "
                ? ""
            #end if 
            return resJson
        else if event = invalid then
            http.asynccancel()
        else
            ? "AsyncPostFromString unknown event"
        end if
    end if
end function

function getDefaultHeders()
    headers = {}
    appInfo = CreateObject("roAppInfo")
    clientToken = appInfo.GetValue("clientToken")
    headers["ClientToken"] = clientToken
    headers["accept"] = "application/json"    
    headers["Origin"] = "app.hopeplatform.org"  
    return headers
end function
