local filename = 'SimpleServerStatus.lua'

PlayerStats = {}
PlayerStats.players = {}

function PlayerStats.getTime()
    return tostring(os.time(os.date("!*t")))
end

function PlayerStats.ConnectEvent(playerID, name)
    local info = net.get_player_info(playerID)
    PlayerStats.players[playerID] = {}
    PlayerStats.players[playerID].csvEvents = {}
    PlayerStats.players[playerID].name = info.name
    PlayerStats.players[playerID].ucid = info.ucid
    PlayerStats.players[playerID].time = PlayerStats.getTime()
end

function PlayerStats.ChangeSlotEvent(playerID, slotID, prevSide)
    local playerInfo = net.get_player_info(playerID)
    local slots = {}
    local side = playerInfo.side

    if side == 1 then
        slots = DCS.getAvailableSlots('red')
    elseif side == 2 then
        slots = DCS.getAvailableSlots('blue')
    end

    local slotTable = {}
    for _, slot in pairs(slots) do
        slotTable[slot.unitId] = slot
    end

    table.insert(PlayerStats.players[playerID].csvEvents,
        PlayerStats.getTime() .. ";change_slot;" ..
        tostring(side) .. ";" ..
        slotTable[playerInfo.slot].unitId ..';' ..
        slotTable[playerInfo.slot].type .. ';' ..
        slotTable[playerInfo.slot].role .. ';' ..
        slotTable[playerInfo.slot].groupName
    )
end

function PlayerStats.KillEvent(killerPlayerID, killerUnitType, killerSide, victimPlayerID, victimUnitType, victimSide, weaponName)
    if victimPlayerID ~= -1 then
        victimPlayerID = PlayerStats.players[victimPlayerID].Ucid
    end

    table.insert(PlayerStats.players[killerPlayerID].csvEvents,
        PlayerStats.getTime() .. ';kill;' ..
        killerUnitType .. ';' ..
        tostring(killerSide) .. ';' ..
        tostring(victimPlayerID) .. ';' ..
        victimUnitType .. ';' ..
        tostring(victimSide) .. ';' ..
        weaponName
    )
end

function PlayerStats.KilledByEvent(killerPlayerID, killerUnitType, killerSide, victimPlayerID, victimUnitType, victimSide, weaponName)
    if killerPlayerID ~= -1 then
        killerPlayerID = PlayerStats.players[killerPlayerID].Ucid
    end

    table.insert(PlayerStats.players[victimPlayerID].csvEvents,
        PlayerStats.getTime() .. ';killed_by;' ..
        killerUnitType .. ';' ..
        tostring(killerSide) .. ';' ..
        tostring(victimPlayerID) .. ';' ..
        victimUnitType .. ';' ..
        tostring(victimSide) .. ';' ..
        weaponName
    )
end

function PlayerStats.SelfKillEvent(playerID)
    if PlayerStats.players[playerID] ~= nil then
        table.insert(PlayerStats.players[playerID].csvEvents, PlayerStats.getTime() .. ';self_kill')
    end
end

function PlayerStats.CrashEvent(playerID, unit_missionID)
    if PlayerStats.players[playerID] ~= nil then
        table.insert(PlayerStats.players[playerID].csvEvents, PlayerStats.getTime() .. ';crash;'.. tostring(unit_missionID))
    end
end

function PlayerStats.EjectEvent(playerID, unit_missionID)
    if PlayerStats.players[playerID] ~= nil then
        table.insert(PlayerStats.players[playerID].csvEvents, PlayerStats.getTime() .. ';eject;' .. tostring(unit_missionID))
    end
end

function PlayerStats.TakeoffEvent(playerID, unit_missionID, airdromeName)
    if PlayerStats.players[playerID] ~= nil then
        table.insert(PlayerStats.players[playerID].csvEvents, PlayerStats.getTime() .. ';takeoff;' .. tostring(unit_missionID) .. ';' .. airdromeName)
    end
end

function PlayerStats.LandingEvent(playerID, unit_missionID, airdromeName)
    if PlayerStats.players[playerID] ~= nil then
        table.insert(PlayerStats.players[playerID].csvEvents, PlayerStats.getTime() .. ';landing;' .. tostring(unit_missionID) .. ';' .. airdromeName)
    end
end

function PlayerStats.PilotDeathEvent(playerID, unit_missionID)
    if PlayerStats.players[playerID] ~= nil then
        table.insert(PlayerStats.players[playerID].csvEvents, PlayerStats.getTime() .. ';pilot_death;' .. tostring(unit_missionID))
    end
end

function PlayerStats.FriendlyFireEvent(playerID, weaponName, victimPlayerID)
    if PlayerStats.players[playerID] ~= nil then
        local victimUcid = PlayerStats.players[victimPlayerID].Ucid
        table.insert(PlayerStats.players[playerID].csvEvents, PlayerStats.getTime() .. ';friendly_fire;' .. weaponName .. ';' .. victimUcid)
    end
end

function PlayerStats.SavePlayer(player)
    local csv = ''
    for _, line in pairs(player.csvEvents) do
        csv = csv .. line .. '\n'
    end

    if csv ~= '' then
        local filePath = lfs.writedir() .. '\\PlayerStats\\' .. 
            player.time .. '-[' ..
            DCS.getMissionName() .. ']-[' ..
            player.name .. ']-[' ..
            player.ucid .. '].csv'
        log.write(filename, log.INFO, 'Write playerStats to ' .. filePath)

        local file = io.open(filePath,"a")
        io.write(file, csv)
        io.close(file)
        player.csvEvents = {}
        log.write(filename, log.INFO, 'Player stats written')
    end
end


function PlayerStats.OnGameEvent(eventName, playerID, arg2, arg3, arg4, arg5, arg6, arg7)
    if playerID ~= -1 then
        if eventName == 'connect' then
            PlayerStats.ConnectEvent(playerID, arg2)
        elseif eventName == 'change_slot' then
            PlayerStats.ChangeSlotEvent(playerID, arg2, arg3)
        elseif eventName == 'takeoff' then
            PlayerStats.TakeoffEvent(playerID, arg2, arg3)
        elseif eventName == 'pilot_death' then
            PlayerStats.PilotDeathEvent(playerID, arg2)
        elseif eventName == "self_kill" then
            PlayerStats.SelfKillEvent(playerID)
        elseif eventName == "crash" then
            PlayerStats.CrashEvent(playerID, arg2)
        elseif eventName == "eject" then
            PlayerStats.EjectEvent(playerID, arg2)
        elseif eventName == "landing" then
            PlayerStats.LandingEvent(playerID, arg2, arg3)
        elseif eventName == "kill" then
            PlayerStats.KillEvent(playerID, arg2, arg3, arg4, arg5, arg6, arg7)
        elseif eventName == "friendly_fire" then
            PlayerStats.FriendlyFireEvent(playerID, arg2, arg3)
        elseif eventName == "disconnect" or eventName == "mission_end" then
            if PlayerStats.players[playerID] ~= nil then
                PlayerStats.SavePlayer(PlayerStats.players[playerID])
                PlayerStats.players[playerID] = nil
            end
        end
    end

    if arg4 ~= -1 then
        PlayerStats.KilledByEvent(playerID, arg2, arg3, arg4, arg5, arg6, arg7)
    end
end

function PlayerStats.OnNetMissionEnd()
    for playerID, _ in pairs(PlayerStats.players) do
            if PlayerStats.players[playerID] ~= nil then
                PlayerStats.SavePlayer(PlayerStats.players[playerID])
                PlayerStats.players[playerID] = nil
            end
    end
end

function PlayerStats.OnSimulationStop()
    for playerID, _ in pairs(PlayerStats.players) do
            if PlayerStats.players[playerID] ~= nil then
                PlayerStats.SavePlayer(PlayerStats.players[playerID])
                PlayerStats.players[playerID] = nil
            end
    end
end

log.write(filename, log.INFO, 'Loaded')
-- PlayerStats.ConnectEvent(net.get_server_id(), 'DEBUG')
