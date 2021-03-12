local filename = 'PlayerStats.lua'

--- @type PLAYERFLIGHT
-- @field #string flightId
-- @field #string airframe
-- @field #table takeoff
    -- @field #number time
    -- @field #string airdome
-- @field #table landings (array of landings)
    -- @field #number time
    -- @field #string airdome
-- @field #table kills (array of kills)
    -- @field #string victimPlayerUcid -1 for AI
    -- @field #string victimPlayerFlightId '' for AI
    -- @field #string victimUnitType
    -- @field victimSide
    -- @field #string weaponName
-- @field #bool pilotDeath
-- @field #string closeReason
-- @field #bool closed

-- @field #number LastLandingTime

-- @type PLAYERFLIGHT

PLAYERFLIGHT = {}
PLAYERFLIGHT.__index = PLAYERFLIGHT
PLAYERFLIGHT.REASONS = {
    LANDING = 'landing',
    SELFKILL = 'self kill',
    MISS = 'miss',
    CRASH = 'crash',
    EJECT = 'eject'
}

--- Create new PLAYERFLIGHT
-- @param #PLAYERFLIGHT self
-- @return #PLAYERFLIGHT
function PLAYERFLIGHT.New(playerUcid, airframe, airdromeName)
    local self = {}
    setmetatable(self, PLAYERFLIGHT)
    local startTime = os.time()
    self.flightId = playerUcid .. "" .. startTime
    self.airframe = airframe
    self.takeoffs = {}
    self.landings = {}
    self.kills = {}
    self.pilotDead = false
    self.closeReason = ''
    self.closed = false

    self.LastLandingTime = nil

    self:AddTakeOff(airdromeName)

    return self
end

--- Adds a landing  to the sortie
-- @param #string airdrome
function PLAYERFLIGHT:AddLanding(airdrome)
    if self.closed == false then
        local currTime = os.time()
        self.LastLandingTime = currTime

        local landing = {}
        landing.time = currTime
        landing.airdome = airdrome
        table.insert(self.landings, landing)
    end
end

function PLAYERFLIGHT:AddTakeOff(airdromeName)
    local takeoff = {}
    takeoff.time = os.time()
    takeoff.airdome = airdromeName
    table.insert(self.takeoffs, takeoff)
end

function PLAYERFLIGHT:PilotDied()
    self.pilotDead = true
end

function PLAYERFLIGHT:Close(reason)
    self.closeReason = reason
    self.closed = true
end




--- @type PLAYER
-- @field #string Name
-- @field #number PlayerId
-- @field #string Ucid
-- @field #number joinTime
-- @field #table finishedflights
-- @field #PLAYERFLIGHT currentflight
-- @type PLAYER

--- PLAYER CLASS
-- @field #PLAYER PLAYER
PLAYER = {}
PLAYER.__index = PLAYER

--- Create new PLAYER
-- @param #PLAYER self
-- @param #number localPlayerId
-- @return #PLAYER
function PLAYER.New(localPlayerId)
    local self = {}
    setmetatable(self, PLAYER)

    local info = net.get_player_info(localPlayerId)
    self.Name = info.name
    self.PlayerId = localPlayerId
    self.Ucid = info.ucid
    self.joinTime = os.time()
    self.currentflight = nil
    self.finishedflights = {}
    self.airframe = ''
    self.side = 0

    return self
end

function PLAYER:changeSlotEvent(slotId, prevSide)
    local playerInfo = net.get_player_info(self.PlayerId)
    local slots = {}
    self.side = playerInfo.side

    if self.side == 1 then
        slots = DCS.getAvailableSlots('red')
    elseif self.side == 2 then
        slots = DCS.getAvailableSlots('blue')
    end

    local slotTable = {}
    for _, slot in pairs(slots) do
        slotTable[slot.unitId] = slot
    end

    self.airframe = slotTable[playerInfo.slot].type
end

function PLAYER:takeoffEvent(unit_missionID, airdromeName)
    if self.currentflight == nil then
        self.currentflight = PLAYERFLIGHT.New(self.Ucid, self.airframe, airdromeName)
    elseif self.currentflight.LastLandingTime ~= nil then
        if os.time() - self.currentflight.LastLandingTime < 30 then
            self.currentflight:AddTakeOff(airdromeName)
        else
            self.currentflight:Close('landing')
            table.insert(self.finishedflights, self.currentflight)
            self.currentflight = PLAYERFLIGHT.New(self.Ucid, self.airframe, airdromeName)
        end
    else
        log.write(filename, log.ERROR, 'Unkown takeoff constellation')
    end
end

function PLAYER:pilotDeathEvent(unit_missionID)
    if self.currentflight ~= nil then
        self.currentflight:PilotDied()
    end
end

function PLAYER:selfKillEvent()
    if self.currentflight ~= nil then
        self.currentflight:Close()
    end
end

function PLAYER:crashEvent(unit_missionID)
    if self.currentflight ~= nil then
        self.currentflight:Close()
    end
end

function PLAYER:ejectEvent(unit_missionID)
    if self.currentflight ~= nil then
        self.currentflight:Close()
    end
end

function PLAYER:landingEvent(unit_missionID, airdromeName)
    if self.currentflight ~= nil then
        self.currentflight:AddLanding(airdromeName)
    end
end

function PLAYER:killEvent(killerPlayerID, killerUnitType, killerSide, victimPlayerID, victimUnitType, victimSide, weaponName)
    net.send_chat()
    if victimPlayerID == self.playerId then
        -- self kill / do nothing
    end
end

function PLAYER:friendlyFireEvent(weaponName, victimPlayerID)
    if victimPlayerID == self.playerId then
        -- self kill 
    end
end

function PLAYER:missionEndEvent()
    if self.currentflight ~= nil then
        self.currentflight:Close()
    end
end


--- OnGameEvent
-- @param #PLAYER self
function PLAYER:OnGameEvent(eventName, arg2, arg3, arg4, arg5, arg6, arg7)
    if eventName == 'change_slot' then
        self:changeSlotEvent(arg2, arg3)
    elseif eventName == 'takeoff' then
        self:takeoffEvent(arg2, arg3)
    elseif eventName == 'pilot_death' then
        self:pilotDeathEvent(arg2)
    elseif eventName == "self_kill" then
        self:selfKillEvent()
    elseif eventName == "crash" then
        self:crashEvent(arg2)
    elseif eventName == "eject" then
        self:ejectEvent(arg2)
    elseif eventName == "landing" then
        self:landingEvent(arg2, arg3)
    elseif eventName == "kill" then
        self:kill(arg2, arg3, arg4, arg5, arg6, arg7)
    elseif eventName == "friendly_fire" then
    end
end





PlayerStats = {}
PlayerStats.players = {}

function PlayerStats.OnPlayerConnect(id)
    net.send_chat("Player connected", true)
end

function PlayerStats.OnMissionLoadEnd()
    local players = net.get_player_list()
    for _, playerId in pairs(players) do
        local player = PLAYER.New(playerId)
        PlayerStats.players[playerId] = player
    end
end

function PlayerStats.OnPlayerDisconnect(id)
    PlayerStats.players[id] = nil
end

function PlayerStats.OnSimulationStop()
end

function PlayerStats.OnGameEvent(eventName, playerId, arg2, arg3, arg4, arg5, arg6, arg7)
    if playerId ~= -1 then
        net.send_chat(eventName .. ' from ' .. tostring(playerId), true)
        if eventName ~= 'mission_end' then
            PlayerStats.players[playerId]:OnGameEvent(eventName, arg2, arg3, arg4, arg5, arg6, arg7)
        end
    end
end

log.write(filename, log.INFO, 'Loaded')
