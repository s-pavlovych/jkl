function NetworkManager()
    scene = m.top.getScene()
    if isValid(scene)
        return scene.networkManager
    end if
end function

function WriteCloudLogManager()
    scene = m.top.getScene()
    if isValid(scene)
        return scene.writeCloudLog
    end if
end function

sub writeCloudLog(servirity as string, message as string)
    appInfo = CreateObject("roAppInfo")
    di = CreateObject("roDeviceInfo")
    if di.IsRIDADisabled()
        uuid = GenerateUUID()
      else
        uuid = di.GetRIDA()
      end if
    body = {
        bucket: "app_roku"
        severity: servirity,
        message: message,
        context: {
            version: appInfo.GetVersion(),
            nameDevice: di.GetModel(),
            uuid: uuid
        }
    }
    m.getChannelsRequest = CreateObject("roSGNode", "URLRequest")
    m.getChannelsRequest.method = "POST"
    m.getChannelsRequest.body = body
    m.manager = WriteCloudLogManager()
    m.manager.fullURL = "https://jstre.am/log"
    m.manager.request = m.getChannelsRequest 
    m.manager.control = "RUN"
  end sub


' ******************************************************
' Registry Helper Functions
' ******************************************************
function RegRead(key, section = invalid)
    if section = invalid then section = "Hope"
    '   reg = CreateObject("roRegistry")
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key)
        return parseJson(sec.Read(key))
    end if
    return invalid
end function

function RegReadMulti(arr, section = invalid)
    if section = invalid then section = "Hope"
    sec = CreateObject("roRegistrySection", section)
    return sec.ReadMulti(arr)
end function

function RegWrite(key, val, section = invalid)
    if section = invalid then section = "Hope"
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
end function

function RegWriteMulti(obj, section = "Hope")
    sec = CreateObject("roRegistrySection", section)
    for each key in obj
        obj[key] = FormatJson(obj[key], 1)
    end for
    sec.WriteMulti(obj)
end function

function RegDelete(key = invalid, section = "Hope")
    if key = invalid
        sec = CreateObject("roRegistry")
        sec.Delete(section)
    else
        sec = CreateObject("roRegistrySection", section)
        sec.Delete(key)
    end if
end function

' ******************************************************
' Beacons launching
' ******************************************************

function appDidLaunchBeacon()
    myScene = m.top.getScene()
    if myScene <> invalid and m.global.AppLaunchComplete = invalid
        saveInGlobal("AppLaunchComplete", true)
        myScene.signalBeacon("AppLaunchComplete")
    end if
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

function StringRemoveHTMLTags(baseStr as string) as string
    r = createObject("roRegex", "<[^<]+?>", "i")
    stringWithoutHTMLTTag = r.replaceAll(baseStr, "")
    r2 = CreateObject("roRegex", "&nbsp;", "")
    stringWithoutSpaces = r2.ReplaceAll(stringWithoutHTMLTTag, "")
    r3 = CreateObject("roRegex", "&rsquo;|&ldquo;|&rdquo;", "")
    return r3.ReplaceAll(stringWithoutSpaces, "'")
end function

function arrToXml(arr, classname, withAttributes = true)
    xml = CreateObject("roXMLElement")
    xml.SetName(classname)
    if withAttributes 'push notification witjout attributes
        xml.AddAttribute("xmlns", "go:v5:interop")
        xml.AddAttribute("xmlns:i", "http://www.w3.org/2001/XMLSchema-instance")
    end if
    for i = 0 to arr.Count() - 1
        xml.AddElementWithBody(arr[i]["name"], ToString(arr[i]["value"]))
    end for
    return xml.GenXML(false)
end function

function objectToXml(obj, classname)
    xml = CreateObject("roXMLElement")
    xml.SetName(classname)
    xml.AddAttribute("xmlns", "go:v5:interop")
    xml.AddAttribute("xmlns:i", "http://www.w3.org/2001/XMLSchema-instance")
    keyArr = []
    for each key in obj
        if obj[key] <> invalid
            keyArr.Push(key)
        end if
    end for
    keyArr.Sort()

    for i = 0 to keyArr.Count() - 1
        xml.AddElementWithBody(keyArr[i], ToString(obj[keyArr[i]]))
    end for
    return xml.GenXML(false)
end function

function arraySlice(arr, start = invalid, finish = invalid)
    if start = invalid
        start = 0
    end if
    if finish = invalid then
        finish = arr.count() - 1
    end if
    res = []
    for i = start to finish
        res.push(arr[i])
    end for
    return res
end function

function filterArr(arr, key, value)
    if arr <> invalid
        filterredArr = []
        arrCount = arr.Count() - 1
        for i = 0 to arrCount
            if arr[i][key] = value
                filterredArr.Push(arr[i])
            end if
        end for
        if (filterredArr.Count() > 0)
            return filterredArr
        else
            return invalid
        end if
    else return invalid
    end if
end function

function getDeviceInfo()
    di = CreateObject("roDeviceInfo")
    ai = CreateObject("roAppInfo")
    obj = {}
    obj.uuid = di.GetChannelClientId()
    obj.dname = di.GetModelDisplayName()
    obj.details = di.GetModelDetails()
    obj.friendlyName = di.GetFriendlyName()
    obj.model = di.GetModel().toStr()
    if obj.dname = "Roku LT"
        obj.version = {major: "9", minor: "2", revision: "6", build: "4127" }
    else
        obj.version = di.GetOSVersion()
    end if
    obj.appversion = ai.getVersion().toStr()
    obj.platform = "Roku"
    return obj
end function

function sortArray(list, property, ascending=true) as dynamic
    for i = 1 to list.count() - 1
        value = list[i]
        j = i - 1

        while j >= 0
            if (ascending and list[j][property] < value[property]) or (not ascending and list[j][property] > value[property]) then 
                exit while
            end if

            list[j + 1] = list[j]
            j = j - 1
        end while

        list[j + 1] = value
    next
    return list
end function

function HttpEncode(str as string) as string
    http = CreateObject("roUrlTransfer")
    return http.Escape(str)
end function

function findArrIndex(arr, key, value, key2 = invalid)
    if arr <> invalid
        if key2 <> invalid
            for i = 0 to arr.Count() - 1
                if arr[i][key][key2] = value
                    return i
                end if
            end for
        else
            for i = 0 to arr.Count() - 1
                if arr[i][key] = value
                    return i
                end if
            end for
        end if
    end if
    return invalid
end function

' ******************************************************
' Replace substrings in a string. Return new string
' ******************************************************
function strReplace(basestr as string, oldsub as string, newsub as string) as string
    newstr = ""

    i = 1
    while i <= Len(basestr)
        x = InStr(i, basestr, oldsub)
        if x = 0 then
            newstr = newstr + Mid(basestr, i)
            exit while
        end if

        if x > i then
            newstr = newstr + Mid(basestr, i, x - i)
            i = x
        end if

        newstr = newstr + newsub
        i = i + Len(oldsub)
    end while

    return newstr
end function

' ******************************************************
' % function
' ******************************************************
function isFixDividing(a as float, b as integer)
    if b = 0
        return false
    else
        result = a / b
        cint = Fix(result)
        part = result - cint
        return part = 0
    end if
end function

' ******************************************************
' Max function (largest from values)
' ******************************************************
function max(a, b)
    if a < b then
        return b
    else
        return a
    end if
end function

' ******************************************************
' Min function (minimum from values)
' ******************************************************
function min(a, b)
    if a > b then
        return b
    else
        return a
    end if
end function

' ******************************************************
' Floor function (from float to int)
' ******************************************************
function floor(value) as integer
    integ = Int(value)
    if integ = value then
        return value
    else
        return integ
    end if
end function

' ******************************************************
' ToString
' ******************************************************

function ToString(variable as dynamic) as string
    if Type(variable) = "roInt" or Type(variable) = "roInteger" or Type(variable) = "roFloat" or Type(variable) = "Float" then
        return Str(variable).Trim()
    else if Type(variable) = "roBoolean" or Type(variable) = "Boolean" then
        if variable = true then
            return "True"
        end if
        return "False"
    else if Type(variable) = "roString" or Type(variable) = "String" then
        return variable
    else
        return Type(variable)
    end if
end function

' ******************************************************
' Print XML
' ******************************************************

sub PrintXML(element as object, depth as integer)
    ? tab(depth * 3); "Name: "; element.GetName()
    if not element.GetAttributes().IsEmpty() then
        ? tab(depth * 3); "Attributes: ";
        for each a in element.GetAttributes()
            ? a; "="; Left(element.GetAttributes()[a], 20);
            if element.GetAttributes().IsNext() then ? ", ";
        end for
        ?
    end if
    if element.GetText() <> invalid then
        ? tab(depth * 3); "Contains Text: "; Left(element.GetText(), 40)
    end if
    if element.GetChildElements() <> invalid
        ? tab(depth * 3); "Contains roXMLList:"
        for each e in element.GetChildElements()
            PrintXML(e, depth + 1)
        end for
    end if
end sub

' ******************************************************
' Type check
' ******************************************************

function IsXmlElement(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifXMLElement") <> invalid
end function

function IsFunction(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifFunction") <> invalid
end function

function IsBoolean(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifBoolean") <> invalid
end function

function IsInteger(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifInt") <> invalid and (Type(value) = "roInt" or Type(value) = "roInteger" or Type(value) = "Integer")
end function

function IsFloat(value as dynamic) as boolean
    return IsValid(value) and (GetInterface(value, "ifFloat") <> invalid or (Type(value) = "roFloat" or Type(value) = "Float"))
end function

function IsDouble(value as dynamic) as boolean
    return IsValid(value) and (GetInterface(value, "ifDouble") <> invalid or (Type(value) = "roDouble" or Type(value) = "roIntrinsicDouble" or Type(value) = "Double"))
end function

function IsList(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifList") <> invalid
end function

function IsArray(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifArray") <> invalid
end function

function IsAssociativeArray(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifAssociativeArray") <> invalid
end function

function IsString(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifString") <> invalid
end function

function IsDateTime(value as dynamic) as boolean
    return IsValid(value) and (GetInterface(value, "ifDateTime") <> invalid or Type(value) = "roDateTime")
end function

function IsValid(value as dynamic) as boolean
    return Type(value) <> "<uninitialized>" and value <> invalid
end function

function createQueryParams(baseUrl, obj)
    url = baseUrl + "?"
    for each item in obj.items()
        if item.value <> invalid
            url += item.key
            url += "="
            url += item.value
            url = url + "&"
        end if
    end for
    return url
end function

function contains(arr as object, value as string) as boolean
    for each entry in arr
        if entry = value
            return true
        end if
    end for
    return false
end function

function getIndex(arr, value)
    i = 0
    for each item in arr
        if item = value
            return i
        end if
        i++
    end for
    return invalid
end function