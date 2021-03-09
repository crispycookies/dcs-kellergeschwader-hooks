local filename = 'ServerStatus.lua'

ServerStatus = {}
ServerStatus.onlinePlayers = {}

function ServerStatus.writeStatus()
    log.write(filename, log.INFO, 'Collect information')

    local serverStatus = {}
    serverStatus.missionsNames = {}
    serverStatus.players = {}

    for _, missionName in pairs(net.missionlist_get().missionList) do
        table.insert(serverStatus.missionsNames, missionName)
    end

    local slots = {}
    for coalitionId, _ in pairs(DCS.getAvailableCoalitions()) do
        for _, slot in pairs(DCS.getAvailableSlots(coalitionId)) do
            slots[slot.unitId] = slot
        end
    end

    local serverPlayerId = net.get_server_id()
    local modelTime = DCS.getModelTime()
    for _, playerId in pairs(net.get_player_list()) do
        if playerId ~= serverPlayerId then
            local playerInfo = net.get_player_info(playerId)
            local player = {}
            player.id = playerId
            player.name = playerInfo.name
            if playerInfo.slot == '' then
                player.role = 'spectator'
            else
                player.role = slots[playerInfo.slot].type
            end

            player.onlineTime = modelTime - ServerStatus.onlinePlayers[playerId]
            table.insert(serverStatus.players, player)
        end
    end

    local filePath = lfs.writedir() .. 'server-status.json'
    log.write(filename, log.INFO, 'Write status to ' .. filePath)
    local file = io.open(filePath,"w")
    local jsonString = net.lua2json(serverStatus)
    jsonString = string.gsub(jsonString, "\"players\":{}", "\"players\":[]")
    io.write(file, jsonString)
    io.close(file)
    log.write(filename, log.INFO, 'Status written')
end

ServerStatus.lastCheck = -50 -- First check after 10 seconds
function ServerStatus.OnSimulationFrame()
    local modelTime = DCS.getModelTime()
    if modelTime - ServerStatus.lastCheck >= 60 then
        ServerStatus.writeStatus()
        ServerStatus.lastCheck = modelTime
    end
end

function ServerStatus.OnMissionLoadEnd()
    ServerStatus.writeStatus()
end

function ServerStatus.OnSimulationPause()
    ServerStatus.writeStatus()
end

function ServerStatus.OnPlayerConnect(id)
    ServerStatus.onlinePlayers[id] = DCS.getModelTime()
end

function ServerStatus.OnPlayerDisconnect(id)
    ServerStatus.onlinePlayers[id] = nil
end

log.write(filename, log.INFO, 'Loaded')