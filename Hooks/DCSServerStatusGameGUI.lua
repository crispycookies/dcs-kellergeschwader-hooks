local dcsServerStatus = {}
local filename = 'DCSServerStatusGameGUI.lua'

log.write(filename, log.INFO, 'DCSServerStatus registered')

function dcsServerStatus.onSimulationStart()
    loadfile(lfs.writedir()..'Scripts\\ServerStatus.lua')()
end

function dcsServerStatus.onSimulationFrame()
    ServerStatus.OnSimulationFrame()
end


DCS.setUserCallbacks(dcsServerStatus)