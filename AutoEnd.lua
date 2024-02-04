local filename = 'AutoEnd.lua'
local totalTime = 43200

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

        if AutoEnd.msg2HoursLeftSend == false and AutoEnd.TimeLeft <= 7200 then
            AutoEnd.msg2HoursLeftSend = true
            net.send_chat("Mission end in 2 hours", true)
        elseif AutoEnd.msg1HourLefSend == false and AutoEnd.TimeLeft <= 3600 then
            AutoEnd.msg1HourLefSend = true
            net.send_chat("Mission end in 1 hour", true)
        elseif AutoEnd.msg30MinLeftSend == false and AutoEnd.TimeLeft <= 1800 then
            AutoEnd.msg30MinLeftSend = true
            net.send_chat("Mission end in 30 minutes", true)
        elseif AutoEnd.msg15MinLeftSend == false and AutoEnd.TimeLeft <= 900 then
            AutoEnd.msg15MinLeftSend = true
            net.send_chat("Mission end in 15 minutes", true)
        elseif AutoEnd.msg5MinLeftSend == false and AutoEnd.TimeLeft <= 300 then
            AutoEnd.msg5MinLeftSend = true
            net.send_chat("Mission end in 5 minutes", true)
        elseif AutoEnd.restarted == false and AutoEnd.TimeLeft <= 0 then
            AutoEnd.restarted = true
            net.send_chat("Mission end", true)
            net.load_next_mission()
        end
    end
end

log.write(filename, log.INFO, 'Start AutoEnd')