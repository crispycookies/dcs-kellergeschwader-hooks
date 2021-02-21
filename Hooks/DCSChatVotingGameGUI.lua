local dcsChatVoting = {}
local filename = 'DCSChatVotingGameGUI.lua'

log.write(filename, log.INFO, 'DCSChatVoting registered')

function dcsChatVoting.onSimulationStart()
    loadfile(lfs.writedir()..'Scripts\\RandomWeather.lua')()
    loadfile(lfs.writedir()..'Scripts\\DCSChatVoting.lua')()
end

function dcsChatVoting.onGameEvent(eventName,arg1,arg2,arg3,arg4)
    DCSChatVoting.OnGameEvent(eventName,arg1,arg2,arg3,arg4)
end

function dcsChatVoting.onChatMessage(message, from)
    DCSChatVoting.OnChatMessage(message, from)
end


DCS.setUserCallbacks(dcsChatVoting)