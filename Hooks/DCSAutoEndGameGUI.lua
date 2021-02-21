local dcsAutoEnd = {}
local filename = 'DCSAutoEndGameGUI.lua'

log.write(filename, log.INFO, 'DCSCAutoEnd registered')

function dcsAutoEnd.onSimulationStart()
    loadfile(lfs.writedir()..'Scripts\\RandomWeather.lua')()
    loadfile(lfs.writedir()..'Scripts\\DCSAutoEnd.lua')()
end

function dcsAutoEnd.onSimulationFrame()
    DCSAutoEnd.OnSimulationFrame()
end

function dcsAutoEnd.onChatMessage(message, from)
    DCSAutoEnd.OnChatMessage(message, from)
end

DCS.setUserCallbacks(dcsAutoEnd)