local dcsServerStatus = {}
local filename = 'DCSServerStatusGameGUI.lua'

log.write(filename, log.INFO, 'DCSServerStatus registered')

function dcsServerStatus.onMissionLoadEnd()
    loadfile(lfs.writedir()..'Scripts\\ServerStatus.lua')()
    ServerStatus.OnMissionLoadEnd()
end

function dcsServerStatus.onSimulationPause()
    ServerStatus.OnSimulationPause()
end

function dcsServerStatus.onSimulationFrame()
    ServerStatus.OnSimulationFrame()
end


DCS.setUserCallbacks(dcsServerStatus)