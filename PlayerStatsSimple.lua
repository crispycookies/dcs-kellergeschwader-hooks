local filename = 'SimpleServerStatus.lua'

PlayerStats = {}
PlayerStats.players = {}

function PlayerStats.getTime()
    return tostring(os.time(os.date("!*t")))
end

function PlayerStats.Connect(playerID, name)
    local info = net.get_player_info(playerID)
    PlayerStats.players[playerID] = {}
    PlayerStats.players[playerID].csvEvents = {}
    PlayerStats.players[playerID].name = info.name
    PlayerStats.players[playerID].ucid = info.ucid
    PlayerStats.players[playerID].time = PlayerStats.getTime()
end

function PlayerStats.ChangeSlotEvent(playerId, slotID, prevSide)
    local playerInfo = net.get_player_info(playerId)
    local slots = {}
    local side = playerInfo.side

    if self.side == 1 then
        slots = DCS.getAvailableSlots('red')
    elseif self.side == 2 then
        slots = DCS.getAvailableSlots('blue')
    end

    local slotTable = {}
    for _, slot in pairs(slots) do
        slotTable[slot.unitId] = slot
    end

    local airframe = slotTable[playerInfo.slot].type
    table.insert(PlayerStats.players[playerId].Events, PlayerStats.getTime() .. ";change_slot;" .. side .. ";" .. airframe)
end

function PlayerStats.KillEvent(killerPlayerID, killerUnitType, killerSide, victimPlayerID, victimUnitType, victimSide, weaponName)
    if victimPlayerID ~= -1 then
        victimPlayerID = PlayerStats.players[victimPlayerID].Ucid
    end

    table.insert(PlayerStats.players[killerPlayerID].Events,
        PlayerStats.getTime() .. ';kill;' ..
        victimPlayerID .. ';' ..
        victimUnitType .. ';' ..
        victimSide ';' ..
        weaponName
    )

    table.insert(PlayerStats.players[killerPlayerID].Events, PlayerStats.getTime() .. ';kill')
end

function PlayerStats.SelfKillEvent(playerId)
    table.insert(PlayerStats.players[playerId].Events, PlayerStats.getTime() .. ';self_kill')
end

function PlayerStats.CrashEvent(playerID, unit_missionID)
    table.insert(PlayerStats.players[playerID].Events, PlayerStats.getTime() .. ';crash;' .. playerID)
end

function PlayerStats.EjectEvent(playerID, unit_missionID)
    table.insert(PlayerStats.players[playerID].Events, PlayerStats.getTime() .. ';eject;' ..  playerID)
end

function PlayerStats.TakeoffEvent(playerID, unit_missionID, airdromeName)
    table.insert(PlayerStats.players[playerID].Events, PlayerStats.getTime() .. ';takeoff;' .. ';' .. airdromeName)
end

function PlayerStats.LandingEvent(playerID, unit_missionID, airdromeName)
    table.insert(PlayerStats.players[playerID].Events, PlayerStats.getTime() .. ';landing;' .. ';' .. airdromeName)
end

function PlayerStats.PilotDeathEvent(playerID, unit_missionID)
    table.insert(PlayerStats.players[playerID].Events, PlayerStats.getTime() .. ';pilot_death')
end

function PlayerStats.FriendlyFireEvent(playerID, weaponName, victimPlayerID)
    local victimUcid = PlayerStats.players[victimPlayerID].Ucid
    table.insert(PlayerStats.players[playerID].Events, PlayerStats.getTime() .. ';friendly_fire;' .. weaponName .. ';' .. victimUcid)
end

function PlayerStats.SavePlayer(player)
    local filePath = lfs.writedir() .. '\\' .. player.time .. '-[' .. player.name .. ']-[' .. player.ucid .. '].json'
    log.write(filename, log.INFO, 'Write playerStats to ' .. filePath)
    local file = io.open(filePath,"a")

    local csv = ''
    for _, line in pairs(player.csvEvents) do
        csv = csv .. line .. '\n'
    end

    io.write(file, csv)
    io.close(file)
    player.csvEvents = {}
    log.write(filename, log.INFO, 'Player stats written')
end


function PlayerStats.OnGameEvent(eventName, playerId, arg2, arg3, arg4, arg5, arg6, arg7)
    if playerId ~= -1 then
        if eventName == 'connect' then
            PlayerStats.Connect(playerId, arg2)
        elseif eventName == 'change_slot' then
            PlayerStats.ChangeSlotEvent(playerId, arg2, arg3)
        elseif eventName == 'takeoff' then
            PlayerStats.TakeoffEvent(playerId, arg2, arg3)
        elseif eventName == 'pilot_death' then
            PlayerStats.PilotDeathEvent(playerId, arg2)
        elseif eventName == "self_kill" then
            PlayerStats.SelfKillEvent(playerId)
        elseif eventName == "crash" then
            PlayerStats.CrashEvent(playerId, arg2)
        elseif eventName == "eject" then
            PlayerStats.EjectEvent(playerId, arg2)
        elseif eventName == "landing" then
            PlayerStats.LandingEvent(playerId, arg2, arg3)
        elseif eventName == "kill" then
            PlayerStats.KillEvent(playerId, arg2, arg3, arg4, arg5, arg6, arg7)
        elseif eventName == "friendly_fire" then
            PlayerStats.FriendlyFireEvent(playerId, arg2, arg3)
        elseif eventName == "disconnect" or eventName == "mission_end" then
            PlayerStats.SavePlayer(PlayerStats.players[playerId])
            PlayerStats.players[playerId] = nil
        end
    end
end

function PlayerStats.OnNetMissionEnd()
    for playerId, _ in pairs(PlayerStats.players) do
        PlayerStats.SavePlayer(PlayerStats.players[playerId])
        PlayerStats.players[playerId] = nil
    end
end

function PlayerStats.OnSimulationStop()
    for playerId, _ in pairs(PlayerStats.players) do
        PlayerStats.SavePlayer(PlayerStats.players[playerId])
        PlayerStats.players[playerId] = nil
    end
end

log.write(filename, log.INFO, 'Loaded')