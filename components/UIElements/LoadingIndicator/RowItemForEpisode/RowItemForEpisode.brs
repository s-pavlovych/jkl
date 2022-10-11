sub init()
    m.imageEpisode = m.top.findNode("imageEpisodes")
    m.imagePlay = m.top.findNode("imagePlay")
    m.backgroundPlay = m.top.findNode("backgroundPlay")
    m.focus = false
    
end sub    

sub showContent()
    m.imageEpisode.uri = m.top.itemContent.HDPosterUrl
    m.imagePlay.translation = [m.backgroundPlay.width / 2 -  m.imagePlay.width/2 + 4 ,  m.backgroundPlay.height / 2 - m.imagePlay.height/2 ]
end sub    



