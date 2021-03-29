local filename = 'AutoEnd.lua'
local totalTime = 21600

AutoEnd = {}
AutoEnd.msg2HoursLeftSend = false
AutoEnd.msg1HourLefSend = false
AutoEnd.msg30MinLeftSend = false
AutoEnd.msg15MinLeftSend = false
AutoEnd.msg5MinLeftSend = false
AutoEnd.restarted = false
AutoEnd.TimeLeft = totalTime

function AutoEnd.OnMissionLoadEnd()
    AutoEnd.TimeLeft = totalTime
    AutoEnd.msg2HoursLeftSend = false
    AutoEnd.msg1HourLefSend = false
    AutoEnd.msg30MinLeftSend = false
    AutoEnd.msg15MinLeftSend = false
    AutoEnd.msg5MinLeftSend = false
    AutoEnd.restarted = false
end

function AutoEnd.OnSimulationFrame()
    if DCS.isMultiplayer() and DCS.isServer() then        
        local modelTime = DCS.getModelTime()
        AutoEnd.TimeLeft = totalTime - modelTime

        -- after 4 hours
        if AutoEnd.msg2HoursLeftSend == false and modelTime >= 14400 then
            AutoEnd.msg2HoursLeftSend = true
            net.send_chat("Mission end in 2 hours", true)
        -- after 5 hours
        elseif AutoEnd.msg1HourLefSend == false and modelTime >= 18000 then
            AutoEnd.msg1HourLefSend = true
            net.send_chat("Mission end in 1 hour", true)
        -- after 5 hour 30 min
        elseif AutoEnd.msg30MinLeftSend == false and modelTime >= 19800 then
            AutoEnd.msg30MinLeftSend = true
            net.send_chat("Mission end in 30 minutes", true)
        -- after 5 hours 45 min
        elseif AutoEnd.msg15MinLeftSend == false and modelTime >= 20700 then
            AutoEnd.msg15MinLeftSend = true
            net.send_chat("Mission end in 15 minutes", true)
        -- after 5 hours 55 min
        elseif AutoEnd.msg5MinLeftSend == false and modelTime >= 21300 then
            AutoEnd.msg5MinLeftSend = true
            net.send_chat("Mission end in 5 minutes", true)
        -- after 6 hours
        elseif AutoEnd.restarted == false and modelTime >= totalTime then
            AutoEnd.restarted = true
            net.send_chat("Mission end", true)
            RandomWeather.LoadNextMission()
        end
    end
end

log.write(filename, log.INFO, 'Start AutoEnd')