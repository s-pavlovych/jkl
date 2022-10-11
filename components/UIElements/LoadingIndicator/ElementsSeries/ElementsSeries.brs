' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  
sub init()
  m.itemIcon = m.top.findNode("itemIcon")
  m.hasFocus = false
end sub

sub showcontent(event)
  itemcontent = m.top.itemContent
  if itemcontent.HDPosterUrl <> ""
    m.itemIcon.uri = itemcontent.HDPosterUrl
  else 
    m.itemIcon.uri = "pkg:/images/defaultImage.png"
  end if
end sub


sub showfocus(event)
end sub

sub rowListChangeFocus(event)
 
end sub