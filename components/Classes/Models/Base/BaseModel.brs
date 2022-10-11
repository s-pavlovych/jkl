
sub init()
end sub

function mapWithBase(params)
    m.top.objectID = params["id"]
    m.top.rawData = params
end function

function getValueFor(key, ofType, inDict) as Dynamic
    if inDict <> invalid and inDict[key] <> invalid and type(inDict[key]) = ofType
      return inDict[key]
    end if
    return invalid
end function
  