local filename = 'ServerStatus.lua'

ServerStatus = {}

ServerStatus.lastCheck = -590
function ServerStatus.OnSimulationFrame()
    local modelTime = DCS.getModelTime()
    if modelTime - ServerStatus.lastCheck >= 600 then
        log.write(filename, log.INFO, 'Collect information')
        ServerStatus.lastCheck = modelTime

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

        for _, playerId in pairs(net.get_player_list()) do
            local playerInfo = net.get_player_info(playerId)
            serverStatus.players[playerId] = {}
            serverStatus.players[playerId].name = playerInfo.name
            if playerInfo.slot == '' then
                serverStatus.players[playerId].role = 'spectator'
            else
                serverStatus.players[playerId].role = slots[playerInfo.slot].type
            end
        end

        local filePath = lfs.writedir() .. 'server-status.json'
        log.write(filename, log.INFO, 'Write status to ' .. filePath)
        local file = io.open(filePath,"w")
        io.write(file, net.lua2json(serverStatus))
        io.close(file)
        log.write(filename, log.INFO, 'Status written')
    end
end

log.write(filename, log.INFO, 'Loaded')