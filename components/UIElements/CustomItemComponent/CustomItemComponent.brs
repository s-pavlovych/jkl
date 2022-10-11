sub init()
    registerView()
end sub

sub registerView()
    m.imageForCell = m.top.findNode("imageForCell")
    m.nameLabel = m.top.findNode("nameLabel")
    m.descriptionLabel = m.top.findNode("descriptionLabel")
end sub    

sub changeFont()
    if m.nameLabel.font <> invalid
    m.nameLabel.font = getFontForChannel(m.global.selectedChannel.objectID, 29, "bold")
    m.descriptionLabel.font = getFontForChannel(m.global.selectedChannel.objectID, 23, "light") 
    end if
end sub

sub showContent()
    changeFont()
    m.nameLabel.text = m.top.itemContent.TITLE
    if m.top.itemContent.SDPOSTERURL = ""
        m.imageForCell.uri = m.top.itemContent.HDPosterUrl
    else
        m.imageForCell.uri = m.top.itemContent.SDPOSTERURL
    end if

    if m.top.itemContent.isShow = invalid
        m.nameLabel.wrap = false
        m.descriptionLabel.text = m.top.itemContent.shortDescriptions
    end if
end sub 