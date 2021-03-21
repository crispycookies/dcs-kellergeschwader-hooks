local filename = 'KellergeschwaderGameGUI.lua'
log.set_output("KellergeschwaderHooks", '', log.ALL, log.FULL)
-- log.set_output("KellergeschwaderHooks", 'ChatCommands.lua', log.ALL, log.FULL)

log.write(filename, log.INFO, 'KellergeschwaderGameGUI loaded')
local hooks = {}

function hooks.onNetMissionChanged()
    loadfile(lfs.writedir()..'Scripts\\ServerStatus.lua')()
    loadfile(lfs.writedir()..'Scripts\\MessageOfTheDay.lua')()
    loadfile(lfs.writedir()..'Scripts\\RandomWeather.lua')()
    loadfile(lfs.writedir()..'Scripts\\AutoEnd.lua')()
    loadfile(lfs.writedir()..'Scripts\\ChatCommands.lua')()
    loadfile(lfs.writedir()..'Scripts\\PlayerStatsSimple.lua')()
end

function hooks.onMissionLoadEnd()
    ServerStatus.OnMissionLoadEnd()
end

function hooks.onChatMessage(message, from)
    ChatCommands.OnChatMessage(message, from)
end

function hooks.onGameEvent(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    PlayerStats.OnGameEvent(eventName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

function hooks.onSimulationPause()
    ServerStatus.OnSimulationPause()
end

function hooks.onSimulationFrame()
    if ServerStatus ~= nil then
        ServerStatus.OnSimulationFrame()
    end

    if AutoEnd ~= nil then
        AutoEnd.OnSimulationFrame()
    end
end

function hooks.onPlayerConnect(id)
    ServerStatus.OnPlayerConnect(id)
end

function hooks.onNetMissionEnd()
    PlayerStats.OnNetMissionEnd()
end

function hooks.onPlayerDisconnect(id)
    ServerStatus.OnPlayerDisconnect(id)
end

function hooks.onSimulationStop()
    PlayerStats.OnSimulationStop()
end

DCS.setUserCallbacks(hooks)
log.write(filename, log.INFO, 'Hooks registered')