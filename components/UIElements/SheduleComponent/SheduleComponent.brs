sub init()
    m.parsedDate = CreateObject("roDateTime")
    m.nextPoster = m.top.findNode("stateImage")
    m.currentProgress = m.top.findNode("currentProgress")
    m.title = m.top.findNode("nameStreem")  
    m.time = m.top.findNode("time")
    m.stateName = m.top.findNode("stateName")
    m.nameShow = m.top.findNode("nameShow")
    m.stateName.font = robotoBoldOfSize(20)
    m.time.font = sourceSansPro(40)
    m.nameShow.font = sourceSansPro(40)
    m.times = 0
end sub

sub calculateCount(value as integer) as string
    arrayNum = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    dateString = ""
    for each item in arrayNum
        if value = item
            dateString = "0" + StrI(value)
            result = dateString.Replace(" ", "")
            return result
            exit for
        else 
        end if
    end for
    return StrI(value)
end sub

sub showcontent(event)
    if m.top.index = 1
        m.nextPoster.uri = "pkg:/images/yellowImageStateForShedule.png"
        m.parsedDate.FromISO8601String(m.top.itemContent.begin)
        m.parsedDate.toLocalTime()
        hour = m.parsedDate.GetHours() 
        minutes = m.parsedDate.GetMinutes()
        time = calculateCount(hour) + ":" + calculateCount(minutes)
        m.time.text = time.Replace(" ", "")
        m.title.text = m.top.itemContent.title
        m.stateName.text = "NEXT"
        m.stateName.color = "#2C2E35"
        m.nameShow.text = m.top.itemContent.titleShow
    else
        m.nextPoster.uri = "pkg:/images/blueImageStateForShedule.png"
        m.parsedDate.FromISO8601String(m.top.itemContent.begin)
        m.stateName.text = "NOW"
        m.parsedDate.toLocalTime()
        hour = m.parsedDate.GetHours()
        minutes = m.parsedDate.GetMinutes()
        time = calculateCount(hour) + ":" + calculateCount(minutes)
        m.time.text = time.Replace(" ", "")
        m.title.text = m.top.itemContent.title
        m.nameShow.text = m.top.itemContent.titleShow
        calculateProgress()
    end if
end sub

sub calculateProgress()
    endTime = m.top.itemContent.end
    m.parsedDate.FromISO8601String(endTime)
    m.parsedDate.toLocalTime()
    endHour = m.parsedDate.GetHours()
    endMinutes = m.parsedDate.GetMinutes()
    beginTime = m.top.itemContent.begin
    m.parsedDate.FromISO8601String(beginTime)
    m.parsedDate.toLocalTime()
    beginHour = m.parsedDate.GetHours()
    beginMinutes = m.parsedDate.GetMinutes()
    sumaHour = endHour - beginHour
    if endMinutes = 0
        sumaMinutes = endMinutes - beginMinutes
        sumaSecMinutes = sumaMinutes * 60
        sumaSecHour = (sumaHour * 60) * 60
        sumaSeconds = sumaSecHour - sumaSecMinutes
        currentDuration = getCurrentDuration(beginHour, beginMinutes)
        parcent = (currentDuration / sumaSeconds) * 100
        setCurrentProgress(parcent)
    else
        sumaMinutes = endMinutes - beginMinutes
        sumaSecMinutes = sumaMinutes * 60
        sumaSecHour = (sumaHour * 60) * 60
        sumaSeconds = sumaSecHour + sumaSecMinutes
        currentDuration = getCurrentDuration(beginHour, beginMinutes)
        parcent = (currentDuration / sumaSeconds) * 100
        setCurrentProgress(parcent)
    end if
end sub

sub setCurrentProgress(parcent as double)
    maxWidth = 856
    widhtProgress = maxWidth * parcent / 100.0
    if widhtProgress <= maxWidth 
        m.currentProgress.width = widhtProgress
    else 
        m.currentProgress.width = 856
    end if
end sub

sub getCurrentDuration(hour as integer, minutes as integer) as integer
    currentTimes = CreateObject("roDateTime")
    currentTimes.toLocalTime()
    currentMinutes = currentTimes.GetMinutes()
    currentHour = currentTimes.GetHours() - m.times
    howMuchHourSec = ((currentHour - hour) * 60) * 60
    howMuchMinSec = (currentMinutes - minutes) * 60
    howMuchSec = howMuchHourSec + howMuchMinSec
return howMuchSec
end sub