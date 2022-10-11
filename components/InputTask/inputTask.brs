sub init()
  m.top.functionName = "listenInput"
end sub

function listenInput()
    port=createobject("romessageport")
    InputObject=createobject("roInput")
    InputObject.setmessageport(port)
    while true
      msg=port.waitmessage(500)
      if type(msg)="roInputEvent" then
        if msg.isInput()
          inputData = msg.getInfo()
          if inputData.DoesExist("mediaType") and inputData.DoesExist("contentID")
            deeplink = {
                id: inputData.contentID
                type: inputData.mediaType
            }
            m.top.inputData = deeplink
          end if
        end if
      end if
    end while
end function
