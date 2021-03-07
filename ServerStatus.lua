local filename = 'ServerStatus.lua'

ServerStatus = {}

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
    for _, playerId in pairs(net.get_player_list()) do
        if playerId ~= serverPlayerId then
            local playerInfo = net.get_player_info(playerId)
            serverStatus.players[playerId] = {}
            serverStatus.players[playerId].name = playerInfo.name
            if playerInfo.slot == '' then
                serverStatus.players[playerId].role = 'spectator'
            else
                serverStatus.players[playerId].role = slots[playerInfo.slot].type
            end
        end
    end

    local filePath = lfs.writedir() .. 'server-status.json'
    log.write(filename, log.INFO, 'Write status to ' .. filePath)
    local file = io.open(filePath,"w")
    io.write(file, net.lua2json(serverStatus))
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

log.write(filename, log.INFO, 'Loaded')