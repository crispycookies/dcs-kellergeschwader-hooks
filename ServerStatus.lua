local filename = 'ServerStatus.lua'

log.write(filename, log.INFO, 'Init serverStatus')
ServerStatus = {}
ServerStatus.OnlinePlayers = {}
ServerStatus.OnlinePlayers[net.get_server_id()] = {}
ServerStatus.OnlinePlayers[net.get_server_id()].JoinTime = os.time()
ServerStatus.lastCheck = -50 -- First check after 10 seconds

function ServerStatus.writeStatus()
    log.write(filename, log.INFO, 'Collect information')

    local serverStatus = {}
    serverStatus.mission_names = {}
    serverStatus.players = {}
    serverStatus.current_mission = {}
    serverStatus.current_mission.mission_time_remaining = math.floor(AutoEnd.TimeLeft)

    for _, missionName in pairs(net.missionlist_get().missionList) do
        table.insert(serverStatus.mission_names, missionName)
    end

    local slots = {}
    for coalitionId, _ in pairs(DCS.getAvailableCoalitions()) do
        for _, slot in pairs(DCS.getAvailableSlots(coalitionId)) do
            slots[slot.unitId] = slot
        end
    end

    local serverPlayerId = net.get_server_id()
    local currentTime = os.time()
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

            player.online_time = math.floor(currentTime - ServerStatus.OnlinePlayers[playerId].JoinTime)
            table.insert(serverStatus.players, player)
        end
    end

    local options = DCS.getCurrentMission().mission
    serverStatus.weather = {}
    serverStatus.weather.wind = options.weather.wind
    serverStatus.weather.season = options.weather.season
    serverStatus.weather.clouds = options.weather.clouds
    serverStatus.current_mission.map = options.theatre
    serverStatus.current_mission.date = options.date
    serverStatus.current_mission.mission = DCS.getMissionFilename()
    serverStatus.current_mission.time = options.start_time + math.floor(DCS.getModelTime())

    local filePath = lfs.writedir() .. 'server-status.json'
    log.write(filename, log.INFO, 'Write status to ' .. filePath)
    local file = io.open(filePath,"w")
    local jsonString = net.lua2json(serverStatus)
    jsonString = string.gsub(jsonString, "\"players\":{}", "\"players\":[]")
    io.write(file, jsonString)
    io.close(file)
    log.write(filename, log.INFO, 'Status written')
end

function ServerStatus.OnSimulationFrame()
    local modelTime = DCS.getModelTime()
    if modelTime - ServerStatus.lastCheck >= 60 then
        ServerStatus.writeStatus()
        ServerStatus.lastCheck = modelTime
    end
end

function ServerStatus.OnMissionLoadEnd()
    ServerStatus.writeStatus()
    ServerStatus.lastCheck = -50
end

function ServerStatus.OnSimulationPause()
    ServerStatus.writeStatus()
end

function ServerStatus.OnPlayerConnect(id)
    ServerStatus.OnlinePlayers[id] = {}
    ServerStatus.OnlinePlayers[id].JoinTime = os.time()
end

function ServerStatus.OnPlayerDisconnect(id)
    ServerStatus.OnlinePlayers[id] = nil
end

log.write(filename, log.INFO, 'Loaded')