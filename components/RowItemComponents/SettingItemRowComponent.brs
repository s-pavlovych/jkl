' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  
sub init()
  m.countryImage = m.top.findNode("countryImage")
  m.channelName = m.top.findNode("channelName")
  m.countryName = m.top.findNode("countryName")
  m.container = m.top.findNode("container")
  m.versionLabel = m.top.findNode("versionLabel")
  m.countryName.font = robotoOfSize(25)
  m.channelName.font = robotoLightOfSize(38)
  m.hasFocus = false
end sub

sub showcontent(event)
  if m.top.itemContent.isAppVersion <> invalid and m.top.itemContent.isAppVersion
    m.device = getDeviceInfo()
    m.versionLabel.visible = true
    m.versionLabel.font = robotoBoldOfSize(22)
    m.versionLabel.color = "#a9a9a9"
    m.versionLabel.text = "v " + m.device.appversion
    m.channelName.text = m.top.itemContent.title
    country = Left(m.top.itemContent.country, 2)
    m.countryName.text = UCase(country)
    selectedChannel()
  else
    m.versionLabel.visible = false
    m.channelName.text = m.top.itemContent.title
    country = Left(m.top.itemContent.country, 2)
    m.countryName.text = UCase(country)
    selectedChannel()
  end if
end sub

sub showfocus(event)
  percent = m.top.rowFocusPercent
  if m.hasFocus
    if percent > 0.2 
       m.channelName.font = robotoOfSize(38)
       m.channelName.color = "#0646A5"
       m.countryImage.uri = "pkg:/images/countryImage1.png"
    else 
      selectedChannel()
    end if
  end if
end sub

sub selectedChannel()
  if m.global.selectedChannel.title <> m.top.itemContent.title
    m.channelName.font = robotoLightOfSize(38)
     m.channelName.color = "#2C2E35"
     m.countryImage.uri = "pkg:/images/countryImage.png"
   else
     m.channelName.font = robotoOfSize(38)
    m.channelName.color = "#0646A5"
    m.countryImage.uri = "pkg:/images/countryImage.png"
  end if
end sub

sub rowListChangeFocus(event)
  m.hasFocus = event.getData()
  if m.hasFocus = true 
      m.channelName.font = robotoOfSize(38)
      m.channelName.color = "#0646A5"
  else 
    if m.top.itemContent <> invalid
      selectedChannel()
    end if
  end if
end sub







