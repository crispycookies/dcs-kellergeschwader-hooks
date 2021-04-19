local filename = 'MessageOfTheDay.lua'
local messageOffset = 30
local playersToWelcome = {}

MessageOfTheDay = {}

function MessageOfTheDay.OnPlayerConnect(id)
    if DCS.isServer() then
        playersToWelcome[id] = {}
        playersToWelcome[id].joinTime = DCS.getRealTime()
        playersToWelcome[id].playerInfo = net.get_player_info(id)
    end
end

function MessageOfTheDay.OnSimulationFrame()
    local realTime = DCS.getRealTime()
    for key, player in pairs(playersToWelcome) do
        if player ~= nil and (realTime - player.joinTime) >= messageOffset then
            net.send_chat_to("Welcome to the Kellergeschwader", player.playerInfo.id)
            net.send_chat_to("Visit us on https://kellergeschwader.com", player.playerInfo.id)
            net.send_chat_to("Type '--help' for available chat commands", player.playerInfo.id)
            playersToWelcome[key] = nil
        end
    end
end

log.write(filename, log.INFO, 'Start MessageOfTheDay')