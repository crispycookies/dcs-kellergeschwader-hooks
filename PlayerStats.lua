-- local filename = 'PlayerStats.lua'

-- --- @type PLAYERFLIGHT
-- -- @field #string FlightId
-- -- @field #number LastLandingTime
-- -- @field #bool IsInAir
-- -- @field #table CSVTable
--     -- landing: PlayerUcid;MissionName;Coalition;FlightId;Airframe;Time;EventType;EventValue

-- -- @field #string playerUcid
-- -- @field #string airframe
-- -- @field #number coalitionId
-- -- @field #string missionName

-- -- @field #bool PilotDead
-- -- @field #bool Closed
-- -- @field #string closeReason

-- -- @type PLAYERFLIGHT

-- PLAYERFLIGHT = {}
-- PLAYERFLIGHT.__index = PLAYERFLIGHT
-- PLAYERFLIGHT.REASONS = {
--     LANDING = 'landing',
--     SELFKILL = 'self_kill',
--     CHANGESLOT = 'change_slot',
--     CRASH = 'crash',
--     EJECT = 'eject',
--     MISSIONEND = 'mission_end',
--     KILLED = 'KILLED'
-- }

-- --- Create new PLAYERFLIGHT
-- -- @param #PLAYERFLIGHT self
-- -- @return #PLAYERFLIGHT
-- function PLAYERFLIGHT.New(playerUcid, airframe, airdromeName, coalitionId)
--     local self = {}
--     setmetatable(self, PLAYERFLIGHT)
--     local startTime = os.time()
--     self.playerUcid = playerUcid
--     self.coalitionId = coalitionId
--     self.FlightId = playerUcid .. "" .. startTime
--     self.airframe = airframe
--     self.kills = {}
--     self.PilotDead = false
--     self.closeReason = ''
--     self.Closed = false
--     self.CSVTable = {}
--     self.missionName = DCS.getMissionName()

--     self.IsInAir = true
--     self.LastLandingTime = nil

--     self:AddTakeOff(airdromeName)
--     return self
-- end

-- function PLAYERFLIGHT:_getBaseCSVString()
--     return self.playerUcid .. ';' .. self.missionName .. ';' .. 
--         self.coalitionId .. ';' .. self.FlightId .. ';' ..
--         self.airframe .. ';' .. tostring(os.time()) .. ';'
-- end

-- --- Adds a landing to the sortie
-- -- @param #string airdrome
-- function PLAYERFLIGHT:AddLanding(airdrome)
--     if self.Closed == false then
--         local currTime = os.time()
--         self.LastLandingTime = currTime
--         self.IsInAir = false

--         local csvString = self._getBaseCSVString() .. 'landing;' .. airdrome
--         table.insert(self.CSVTable, csvString)
--     end
-- end

-- function PLAYERFLIGHT:AddTakeOff(airdrome)
--     if self.Closed == false then
--         self.IsInAir = true

--         local csvString = self._getBaseCSVString() .. 'takeoff;' .. airdrome
--         table.insert(self.CSVTable, csvString)
--     end
-- end

-- --- Adds a kill to the sortie
-- -- @param #string victimPlayerFlightId Empty string for AI
-- -- @param #string victimUnitType
-- -- @param #number victimSide
-- -- @param #string weaponName
-- function PLAYERFLIGHT:AddKill(victimPlayerFlightId, victimUnitType, victimSide, weaponName)
--     if self.Closed == false then
--         local csvString = self._getBaseCSVString() .. 'kill;' .. victimPlayerFlightId ..
--             victimUnitType .. ';' .. tostring(victimSide) .. ';' .. weaponName
--         table.insert(self.CSVTable, csvString)
--     end
-- end

-- function PLAYERFLIGHT:PilotDied()
--     if self.Closed == false then
--         self.PilotDead = true
--     end
-- end

-- function  PLAYERFLIGHT:KilledBy(victimPlayerFlightId, victimUnitType, victimSide, weaponName)
--     local csvString = self._getBaseCSVString() .. 'killed_by;' .. victimPlayerFlightId ..
--         victimUnitType .. ';' .. tostring(victimSide) .. ';' .. weaponName
--     table.insert(self.CSVTable, csvString)
-- end

-- function PLAYERFLIGHT:Close(reason)
--     if self.Closed == false then
--         self.closeReason = reason
--         self.Closed = true
--         net.send_chat("Closed: " .. reason)
--     end
-- end




-- --- @type PLAYER
-- -- @field #string Name
-- -- @field #number PlayerId
-- -- @field #string Ucid
-- -- @field #number joinTime
-- -- @field #table finishedflights
-- -- @field #PLAYERFLIGHT currentflight
-- -- @type PLAYER

-- --- PLAYER CLASS
-- -- @field #PLAYER PLAYER
-- PLAYER = {}
-- PLAYER.__index = PLAYER

-- --- Create new PLAYER
-- -- @param #PLAYER self
-- -- @param #number localPlayerId
-- -- @return #PLAYER
-- function PLAYER.New(localPlayerId)
--     local self = {}
--     setmetatable(self, PLAYER)

--     local info = net.get_player_info(localPlayerId)
--     self.Name = info.name
--     self.PlayerId = localPlayerId
--     self.Ucid = info.ucid
--     self.joinTime = os.time()
--     self.currentflight = nil
--     self.finishedflights = {}
--     self.airframe = ''
--     self.side = 0

--     return self
-- end

-- function PLAYER:TryGetLastOrActiveFlight()
--     local flightToAddKill = nil
--     if self.currentflight ~= nil then
--         flightToAddKill = self.currentflight
--     else
--         for _, v in pairs(self.finishedflights) do
--             flightToAddKill = v
--         end
--     end

--     return flightToAddKill
-- end

-- function PLAYER:ChangeSlotEvent(slotId, prevSide)
--     if self.currentflight ~= nil then
--         if self.currentflight.PilotDead == true then
--             self.currentflight.Close(PLAYERFLIGHT.REASONS.CRASH)
--         else
--             self.currentflight.Close(PLAYERFLIGHT.REASONS.CHANGESLOT)
--         end
--     end

--     local playerInfo = net.get_player_info(self.PlayerId)
--     local slots = {}
--     self.side = playerInfo.side

--     if self.side == 1 then
--         slots = DCS.getAvailableSlots('red')
--     elseif self.side == 2 then
--         slots = DCS.getAvailableSlots('blue')
--     end

--     local slotTable = {}
--     for _, slot in pairs(slots) do
--         slotTable[slot.unitId] = slot
--     end

--     self.airframe = slotTable[playerInfo.slot].type
-- end

-- function PLAYER:TakeoffEvent(unit_missionID, airdromeName)
--     if self.currentflight == nil then
--         self.currentflight = PLAYERFLIGHT.New(self.Ucid, self.airframe, airdromeName, self.side)
--     elseif self.currentflight.LastLandingTime ~= nil then
--         if os.time() - self.currentflight.LastLandingTime < 30 then
--             self.currentflight:AddTakeOff(airdromeName)
--         else
--             self.currentflight:Close(PLAYERFLIGHT.REASONS.LANDING)
--             table.insert(self.finishedflights, self.currentflight)
--             self.currentflight = PLAYERFLIGHT.New(self.Ucid, self.airframe, airdromeName, self.side)
--         end
--     else
--         log.write(filename, log.ERROR, 'Unkown takeoff constellation')
--     end
-- end

-- function PLAYER:PilotDeathEvent(unit_missionID)
--     if self.currentflight ~= nil then
--         self.currentflight:PilotDied()
--     end
-- end

-- function PLAYER:SelfKillEvent()
--     if self.currentflight ~= nil then
--         self.currentflight:Close(PLAYERFLIGHT.REASONS.SELFKILL)
--     end
-- end

-- function PLAYER:CrashEvent(unit_missionID)
--     if self.currentflight ~= nil then
--         self.currentflight:Close(PLAYERFLIGHT.REASONS.CRASH)
--     end
-- end

-- function PLAYER:EjectEvent(unit_missionID)
--     if self.currentflight ~= nil then
--         self.currentflight:Close(PLAYERFLIGHT.REASONS.EJECT)
--     end
-- end

-- function PLAYER:LandingEvent(unit_missionID, airdromeName)
--     if self.currentflight ~= nil then
--         self.currentflight:AddLanding(airdromeName)
--     end
-- end

-- function PLAYER:KillEvent(victimFlightId, victimPlayerID, victimUnitType, victimSide, weaponName)
--     local flightToAddKill = self:TryGetLastOrActiveFlight()

--     if flightToAddKill ~= nil then
--         if victimPlayerID == self.playerId then
--             flightToAddKill:PilotDied()
--             flightToAddKill:Close(PLAYERFLIGHT.REASONS.SELFKILL)
--         else
--             flightToAddKill:AddKill(victimFlightId, victimUnitType, victimSide, weaponName)
--         end
--     end
-- end

-- function PLAYER:FriendlyFireEvent(weaponName, victimPlayerID)
--     local flightToAddKill = self:TryGetLastOrActiveFlight()

--     if flightToAddKill ~= nil then
--         if victimPlayerID == self.playerId then
--             self.currentflight:PilotDied()
--             self.currentflight:Close(PLAYERFLIGHT.REASONS.SELFKILL)
--         end
--     end
-- end

-- function PLAYER:MissionEndEvent()
--     if self.currentflight ~= nil then
--         self.currentflight:Close(PLAYERFLIGHT.REASONS.MISSIONEND)
--     end
-- end

-- function PLAYER:KilledBy(victimPlayerFlight, victimUnitType, victimSide, weaponName)
--     if self.currentflight ~= nil then
--         self.currentflight:KilledBy(victimPlayerFlight.id, victimUnitType, victimSide, weaponName)
--         self.currentflight:Close(PLAYERFLIGHT.REASONS.KILLED)
--     end
-- end

-- function PLAYER:Close(playerFlightReason)
--     if self.currentflight ~= nil and self.currentflight.Closed == false then
--         self.currentflight.Close(playerFlightReason)
--     end
-- end




-- PlayerStats = {}
-- PlayerStats.players = {}

-- function PlayerStats.OnPlayerConnect(playerId)
--     local player = PLAYER.New(playerId)
--     PlayerStats.players[playerId] = player
-- end

-- function PlayerStats.OnMissionLoadEnd()
--     local players = net.get_player_list()
--     for _, playerId in pairs(players) do
--         local player = PLAYER.New(playerId)
--         PlayerStats.players[playerId] = player
--     end
-- end

-- function PlayerStats.OnPlayerDisconnect(playerId)
--     PlayerStats.players[playerId]:Close(PLAYERFLIGHT.REASONS.CHANGESLOT)
--     PlayerStats.savePlayer(PlayerStats.players[playerId])
--     PlayerStats.players[playerId] = nil
-- end

-- function PlayerStats.OnSimulationStop()
--     for _, player in pairs(PlayerStats.players) do
--         PlayerStats.savePlayer(player)
--     end
-- end

-- function PlayerStats.OnGameEvent(eventName, playerId, arg2, arg3, arg4, arg5, arg6, arg7)
--     net.send_chat(eventName .. ' from ' .. tostring(playerId), true)
--     if playerId ~= -1 then
--         local player = PlayerStats.players[playerId]
--         if eventName == 'change_slot' then
--             player:ChangeSlotEvent(arg2, arg3)
--         elseif eventName == 'takeoff' then
--             player:TakeoffEvent(arg2, arg3)
--         elseif eventName == 'pilot_death' then
--             player:PilotDeathEvent(arg2)
--         elseif eventName == "self_kill" then
--             player:SelfKillEvent()
--         elseif eventName == "crash" then
--             player:CrashEvent(arg2)
--         elseif eventName == "eject" then
--             player:EjectEvent(arg2)
--         elseif eventName == "landing" then
--             player:LandingEvent(arg2, arg3)
--         elseif eventName == "kill" then
--             if arg4 ~= -1 then
--                 local victimFlight = PlayerStats.players[arg4]:TryGetLastOrActiveFlight()
--                 if victimFlight then
--                     player:KillEvent(victimFlight.FlightId, arg4, arg5, arg6, arg7)
--                 else
--                     player:KillEvent('', arg4, arg5, arg6, arg7)
--                 end

--                 local flight = PlayerStats.players[playerId]:TryGetLastOrActiveFlight()
--                 if flight ~= nil then
--                     PlayerStats.players[arg4]:KilledBy(flight.FlightId, arg2, arg3, arg7)
--                 end
--             else
--                 player:KillEvent('', arg4, arg5, arg6, arg7)
--             end
--         elseif eventName == "friendly_fire" then
--             player:FriendlyFireEvent(arg2, arg3)
--         end

--     end

--     if eventName == 'kill' and arg4 ~= -1 then
--         PlayerStats.players[arg4]:KilledBy('', arg2, arg3, arg7)
--     end
-- end

-- function PlayerStats.savePlayer(player)
--     local date = os.date("*t", os.time())
--     local filePath = lfs.writedir() .. tostring(date.year) .. '-' .. tostring(date.month) .. '-' .. tostring(date.day) .. '.json'
--     log.write(filename, log.INFO, 'Write playerStats to ' .. filePath)
--     local file = io.open(filePath,"a")

--     local csv = ''
--     for _, line in pairs(player.CSVTable) do
--         csv = csv .. line .. '\n'
--     end

--     io.write(file, csv)
--     io.close(file)
--     log.write(filename, log.INFO, 'Player stats written')
-- end

-- log.write(filename, log.INFO, 'Loaded')
