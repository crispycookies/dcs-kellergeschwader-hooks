local hooks = {}
local filename = 'KellergeschwaderGameGUI.lua'

log.write(filename, log.INFO, 'DCSCAutoEnd registered')
loadfile(lfs.writedir()..'Scripts\\ServerStatus.lua')()
loadfile(lfs.writedir()..'Scripts\\MessageOfTheDay.lua')()

function hooks.onMissionLoadEnd()
    loadfile(lfs.writedir()..'Scripts\\RandomWeather.lua')()
    loadfile(lfs.writedir()..'Scripts\\AutoEnd.lua')()
    loadfile(lfs.writedir()..'Scripts\\ChatCommands.lua')()

    ServerStatus.OnMissionLoadEnd()
end

function hooks.onChatMessage(message, from)
    ChatCommands.OnChatMessage(message, from)
end

function hooks.onGameEvent(eventName,arg1,arg2,arg3,arg4)
end

function hooks.onSimulationPause()
    ServerStatus.OnSimulationPause()
end

function hooks.onSimulationFrame()
    ServerStatus.OnSimulationFrame()
    AutoEnd.OnSimulationFrame()
end

function hooks.onPlayerConnect(id)
    ServerStatus.OnPlayerConnect(id)
    MessageOfTheDay.OnPlayerConnect(id)
end

function hooks.onPlayerDisconnect(id)
    ServerStatus.OnPlayerDisconnect(id)
end

DCS.setUserCallbacks(hooks)
log.write(filename, log.INFO, 'KellergeschwaderGameGUI registered')