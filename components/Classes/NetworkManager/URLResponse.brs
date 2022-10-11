function initWithResponse(response)
    if IsAssociativeArray(response)
        m.top.data = response
    else
        m.top.arrayData = response
    end if    
end function