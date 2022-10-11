sub generalConfig(screenId as object)
  defineFonts()
  defineColors()
  defineAssets()
end sub

sub defineAssets()
  
end sub

function defineColors()

end function

function defineFonts()

end function

Function IsDSTNow() as integer

    dstNow = False

    tzList = {}
    ' diff - Local time minus GMT for the time zone
    ' dst  - False if the time zone never observes DST
    tzList ["US/Puerto Rico-Virgin Islands"]    = {diff: -0004,    dst: False}
    tzList ["US/Guam"]                          = {diff: -0010,   dst: False}
    tzList ["US/Samoa"]                         = {diff: -0011,   dst: True}    ' Should be 13 [Workaround Roku bug]
    tzList ["US/Hawaii"]                        = {diff: -0010,   dst: False}
    tzList ["US/Aleutian"]                      = {diff: -0010,   dst: True}
    tzList ["US/Alaska"]                        = {diff: -0009,    dst: True}
    tzList ["US/Pacific"]                       = {diff: -0008,    dst: True}
    tzList ["US/Arizona"]                       = {diff: -0007,    dst: False}
    tzList ["US/Mountain"]                      = {diff: -0007,    dst: True}
    tzList ["US/Central"]                       = {diff: -0006,    dst: True}
    tzList ["US/Eastern"]                       = {diff: -0005,    dst: True}
    tzList ["Canada/Pacific"]                   = {diff: -0008,    dst: True}
    tzList ["Canada/Mountain"]                  = {diff: -0007,    dst: True}
    tzList ["Canada/Central Standard"]          = {diff: -0006,    dst: False}
    tzList ["Canada/Central"]                   = {diff: -0006,    dst: True}
    tzList ["Canada/Eastern"]                   = {diff: -0005,    dst: True}
    tzList ["Canada/Atlantic"]                  = {diff: -0004,    dst: True}
    tzList ["Canada/Newfoundland"]              = {diff: -0003.5,  dst: True}
    tzList ["Europe/Iceland"]                   = {diff: 0000,     dst: False}
    tzList ["Europe/Ireland"]                   = {diff: 0000,     dst: True}
    tzList ["Europe/United Kingdom"]            = {diff: 0000,     dst: True}
    tzList ["Europe/Portugal"]                  = {diff: 0000,     dst: True}
    tzList ["Europe/Central European Time"]     = {diff: 0001,     dst: True}
    tzList ["Europe/Greece/Finland"]            = {diff: 0002,     dst: True}

    ' Get the Roku device's current time zone setting
    tz = CreateObject ("roDeviceInfo").GetTimeZone ()

    ' Look up in our time zone list - will return Invalid if time zone not listed
    tzEntry = tzList [tz]
    
    ' Return False if the current time zone does not ever observe DST, or if time zone was not found
    ' If tzEntry <> Invalid And tzEntry.dst
        ' Get the current time in GMT
        ' dt = CreateObject ("roDateTime")
        ' secsGmt = dt.AsSeconds ()

        ' Convert the current time to local time
        ' dt.ToLocalTime ()
        ' secsLoc = dt.AsSeconds ()

        ' Calculate the difference in seconds between local time and GMT
        ' secsDiff = secsLoc - secsGMT

        ' ' If the difference between local and GMT equals the difference in our table, then we're on standard time now
        ' dstDiff = tzEntry.diff * 60 * 60 - secsDiff
        ' If dstDiff < 0 Then dstDiff = -dstDiff

        ' dstNow = dstDiff > 1	' Use 1 sec not zero as Newfoundland time is a floating-point value
    ' Endif

    Return tzEntry.diff

End Function

function defaultMetadata()
  firstLaunchChannel = ""
  firstLaunchChannelID = ""
  di = CreateObject("roDeviceInfo")
  country = Left(di.GetCurrentLocale(), 2)
  locale = LCase(country)
  appInfo = CreateObject("roAppInfo")
  uuid = ""
  if di.IsRIDADisabled()
    uuid = GenerateUUID()
    ? "GENERATED uuid: " uuid
  else
    uuid = di.GetRIDA()
    ? "REAL uuid: " uuid
  end if  

  if  m.global.firstLaunchChannel <> invalid 
    firstLaunchChannel =  m.global.firstLaunchChannel
    firstLaunchChannelID = m.global.firstLaunchChannel.objectID
  end if
  obj = {
      cd1: appInfo.GetVersion(),
      cd2: "Roku",
      cd4: firstLaunchChannel,
      cd5: firstLaunchChannelID,
      cd6: m.global.selectedChannel.title,
      cd7: m.global.selectedChannel.objectID,
      cd8: locale,
      cd19: uuid
  }
  return obj
end function

sub getFontForChannel(id as string, size, style) as object
  if id = "622891edf21f105fa15fc872" or id = "6221de9475f26bdfcff46d23" or id = "6256a7d0ddf35e2e4955fc64"
    ' return chine two jupan font
    return dFHeiStdW7(size)
  else if id = "62289440f21f105fa15fca70"
    'return arabic font
    return tradoPro(size)
  else
    if style = "light"
      return robotoLightOfSize(size)
    else
      return robotoBoldOfSize(size)
    end if
  end if
end sub

sub robotoBoldOfSize(size) as object
  font  = CreateObject("roSGNode", "Font")
  font.uri = "pkg:/fonts/Roboto-Bold.ttf"
  font.size = size
  return font
end sub

sub sourceSansPro(size) as object
  font  = CreateObject("roSGNode", "Font")
  font.uri = "pkg:/fonts/SourceSansPro-Semibold.ttf"
  font.size = size
  return font
end sub

sub dFHeiStdW7(size) as object
  font  = CreateObject("roSGNode", "Font")
  font.uri = "pkg:/fonts/MPLUS1p-Regular.ttf"
  font.size = size
  return font
end sub

sub tradoPro(size) as object
  font  = CreateObject("roSGNode", "Font")
  font.uri = "pkg:/fonts/trado.ttf"
  font.size = size
  return font
end sub

sub dFHeiStdW3(size) as object
  font  = CreateObject("roSGNode", "Font")
  font.uri = "pkg:/fonts/MPLUS1p-Regular.ttf"
  font.size = size
  return font
end sub

sub robotoLightOfSize(size) as object
  font  = CreateObject("roSGNode", "Font")
  font.uri = "pkg:/fonts/Roboto-Light.ttf"
  font.size = size
  return font
end sub

sub robotoOfSize(size) as object
  font  = CreateObject("roSGNode", "Font")
  font.uri = "pkg:/fonts/Roboto-Regular.ttf"
  font.size = size
  return font
end sub

function getBaseURL()
  ' return "https://hopechannel.io/api"
  return "https://frontend-api.hopeplatform.org/v1/media-library"
end function

function getAppLanguage()
  deviceInfo = CreateObject("roDeviceInfo")
  locale =  deviceInfo.GetCurrentLocale()
  'TODO internal localisation
  return locale
end function

Function GenerateUUID() As String
    stored = RegRead("UUID")
    if stored <> invalid then return stored
    new = GetRandomHexString(8) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(12)
    valueObject = {
      "UUID" : new
    }
    RegWriteMulti(valueObject)
    return new
End Function

Function GetRandomHexString(length As Integer) As String
    hexChars = "0123456789ABCDEF"
    hexString = ""
    for i = 1 to length
        hexString = hexString + hexChars.Mid(Rnd(16) - 1, 1)
    next
    return hexString
End Function

'API PATH FUNCTIONS

function getChannelsList()
  return "/channels"
end function

function getChannelById()
  return "/channels/{0}"
end function

function getListShows()
  return "/channels/{0}/shows"
end function

function getRelatedShows()
  return "/shows/{0}/related"
end function

function getShowById()
  return "shows/{0}"
end function 

function getShowsPathFormat()
  return "/channels/{0}/shows"
end function

function getListSeasons()
  return "/shows/{0}/seasons"
end function

function getEpisopdesByID()
  return "/episodes/{0}"
end function

function getSeasonById()
   return "/seasons/{0}"
end function 

function getShowEpisodes()
  return "/shows/{0}/episodes"
end function 

function getEpisodeById()
  return "/seasons/{0}/episodes"
end function

function getShowsInfo()
   return "/shows/{0}/"
end function 

function getSeasonEpisodes()
    return "/seasons/{0}/episodes"
end function

function getShowInfo()
    return "/shows/{0}"
end function

function getCollectionIdPath() 
    return "/collections/{0}/"
end function 

function getEpisodesPathFormat()
  return "/shows/{0}/episodes"
end function

function getReleaedEpisodes()
  return "/episodes/{0}/related"
end function

function getListCollections()
   return "/channels/{0}/collections"
end function 

function getListBroadCast()
   return "/channels/{0}/broadcasts"
end function 

function getShowsEpisodes()
   return "/shows/{0}/episodes"
end function 

