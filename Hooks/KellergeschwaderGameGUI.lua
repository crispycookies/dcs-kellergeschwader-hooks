local hooks = {}
local filename = 'KellergeschwaderGameGUI.lua'

log.write(filename, log.INFO, 'DCSCAutoEnd registered')

function hooks.onMissionLoadEnd()
    loadfile(lfs.writedir()..'Scripts\\ServerStatus.lua')()
    loadfile(lfs.writedir()..'Scripts\\RandomWeather.lua')()
    loadfile(lfs.writedir()..'Scripts\\AutoEnd.lua')()
    loadfile(lfs.writedir()..'Scripts\\ChatCommands.lua')()

    ServerStatus.OnMissionLoadEnd()
end

function hooks.onChatMessage(message, from)
    AutoEnd.OnChatMessage(message, from)
    ChatCommands.OnChatMessage(message, from)
end

function hooks.onGameEvent(eventName,arg1,arg2,arg3,arg4)
    ChatCommands.OnGameEvent(eventName,arg1,arg2,arg3,arg4)
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
end

function hooks.onPlayerDisconnect(id)
    ServerStatus.OnPlayerDisconnect(id)
end

DCS.setUserCallbacks(hooks)
log.write(filename, log.INFO, 'KellergeschwaderGameGUI registered')