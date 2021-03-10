local filename = 'AutoEnd.lua'
AutoEnd = {}

local msg2HoursLeftSend = false
local msg1HourLefSend = false
local msg30MinLeftSend = false
local msg15MinLeftSend = false
local msg5MinLeftSend = false
local restarted = false
local totalTime = 21600

AutoEnd.TimeLeft = totalTime

function AutoEnd.OnSimulationFrame()
    if DCS.isMultiplayer() and DCS.isServer() then        
        local modelTime = DCS.getModelTime()
        AutoEnd.TimeLeft = totalTime - modelTime

        -- after 4 hours
        if msg2HoursLeftSend == false and modelTime >= 14400 then
            msg2HoursLeftSend = true
            net.send_chat("Mission end in 2 hours", true)
        -- after 5 hours
        elseif msg1HourLefSend == false and modelTime >= 18000 then
            msg1HourLefSend = true
            net.send_chat("Mission end in 1 hour", true)
        -- after 5 hour 30 min
        elseif msg30MinLeftSend == false and modelTime >= 19800 then
            msg30MinLeftSend = true
            net.send_chat("Mission end in 30 minutes", true)
        -- after 5 hours 45 min
        elseif msg15MinLeftSend == false and modelTime >= 20700 then
            msg15MinLeftSend = true
            net.send_chat("Mission end in 15 minutes", true)
        -- after 5 hours 55 min
        elseif msg5MinLeftSend == false and modelTime >= 21300 then
            msg5MinLeftSend = true
            net.send_chat("Mission end in 5 minutes", true)
        -- after 6 hours
        elseif restarted == false and modelTime >= totalTime then
            net.send_chat("Mission end", true)
            restarted = true
            RandomWeather.LoadNextMission()
        end
    end
end

log.write(filename, log.INFO, 'Start AutoEnd')