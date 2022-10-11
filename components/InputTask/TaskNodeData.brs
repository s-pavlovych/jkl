sub init()
    m.top.functionName = "setupContentForEpisodes"
end sub

function setupContentForEpisodes() 
    seasons = m.top.seasons
    if IsValid(seasons)
        if seasons.count() > 0
        for each seasonRow in seasons
            if seasonRow.items.count() > 0
            title = seasonRow.items[0].season.title
            m.sectionContent = m.top.content.createChild("ContentNode")
            m.sectionContent.title = title
            items =  seasonRow.items     
            for each item in items    
              seasonNode = m.sectionContent.createChild("ContentNodeShows")
              seasonNode.title = item.title
              seasonNode.objectID = item.id
              seasonNode.shortDescriptions = item.abstract
              if item.image <> invalid
                seasonNode.SDPosterUrl = item.image.small.url
              else 
                seasonNode.SDPosterUrl = "pkg:/images/defaultImageForCells.png"  
              end if
            end for
          end if
        end for
    
    end if
    end if 
 
   
end function 

  
  
  