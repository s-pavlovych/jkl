
sub initAnalitics()
    defineDeviceInfo()
    initPrimalObject()
end sub

sub defineDeviceInfo()
    appInfo = CreateObject("roAppInfo")
    di = CreateObject("roDeviceInfo")
    m.appVersion = appInfo.GetVersion()
    m.appName = appInfo.GetTitle()
    m.id = appInfo.GetID()
    m.dm = di.GetDisplayMode()
end sub

sub initPrimalObject()
    m.global.addField("RSG_analytics", "node", false)
    m.global.RSG_analytics = CreateObject("roSGNode", "Roku_Analytics:AnalyticsNode")
    m.global.RSG_analytics.debug = true
    trackingID = "UA-4329911-29"
    m.global.RSG_analytics.init = {
        google : {
            trackingID : trackingID
            an : m.appName
            av : m.appVersion
            sr : m.dm,
            defaultParams : {
                an : "RokuAnalyticsClient"
            }
        }
    }
end sub