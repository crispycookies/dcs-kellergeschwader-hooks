local filename = 'ChatCommands.lua'

local function getPlayerCount()
    local count = 0
    for _ in pairs(net.get_player_list()) do
        count = count + 1
    end

    return count - 1
end

--- @type VOTING
-- @field #boolean VoteActive Is voting active
-- @field #number VotesNeeded Number of votes needed to execute callback
-- @field #number CurrentVotes Actual number of voted
-- @field #table PlayerIDsVoted Array of player ids already voted
-- @field #string Commands The commands as string table to listen to
-- @field #function Callback Callback if voting was successfull
-- @field #lastStartTime The DCS timer id for the voting reset
-- @type VOTING

--- VOTING CLASS
-- @field #VOTING VOTING
VOTING = {}
VOTING.__index = VOTING

--- Create new VOTING
-- @param #VOTING self
-- @param #table commands The commands as string table to listen to
-- @param #string callback Callback if voting was successfull
-- @return #VOTING
function VOTING.New(commands, callback)
    local self = {}
    setmetatable(self, VOTING)
    self.VoteActive = false
    self.VotesNeeded = 0
    self.CurrentVotes = 0
    self.PlayerIDsVoted = {}
    self.Commands = commands
    self.Callback = callback
    self.lastStartTime = nil
    return self
end

--- Check if player has already voted
-- @param #VOTING self
-- @param #number playerId The id of the player to check if he already voted
-- @return #boolean True if player has alread voted
function VOTING:_hasPlayerAlreadyVoted(playerId)
    local voted = false

    for _, v in pairs(self.PlayerIDsVoted) do
        if v == playerId then
            voted = true
        end
    end

    return voted
end

--- Resets the votinh
-- @param #VOTING self
function VOTING:Reset()
    self.VoteActive = false
    self.VotesNeeded = 0
    self.CurrentVotes = 0
    self.PlayerIDsVoted = {}
    self.lastStartTime = nil
end

--- Add connection to another battle zone
-- @param #VOTING self
-- @param #number playerId Player id voted
function VOTING:_addVote(playerId)
    if self.lastStartTime ~= nil and DCS.getRealTime() - 120 > self.lastStartTime then
        self:Reset()
    end

    if self.VoteActive == true then
        if self:_hasPlayerAlreadyVoted(playerId) == false then
            self.CurrentVotes = self.CurrentVotes + 1
            table.insert(self.PlayerIDsVoted, playerId)

            if self.CurrentVotes == self.VotesNeeded then
                self.Callback()
            else
                net.send_chat("Another " .. self.VotesNeeded - self.CurrentVotes .. " votes needed.", true)
            end
        else
            net.send_chat_to("You already voted for this.", playerId)
        end
    else
        local count = getPlayerCount()

        if count <= 1 then
            self.Callback()
        elseif count > 0 then
            self.VoteActive = true
            self.VotesNeeded = count
            self.CurrentVotes = 1
            self.PlayerIDsVoted = {playerId}
            self.lastStartTime = DCS.getRealTime()
            net.send_chat("Voting started. Enter \"" .. self.Commands .. "\" to vote for. Another " .. self.VotesNeeded - 1 .. " votes needed. Vote is active for 2 minutes.", true)
        end
    end
end

--- On chat message callback from OpenDCS
-- @param #VOTING self
-- @param #string message Message send to chat
-- @param #number from Player id sends the message
function VOTING:OnChatMessage(message, from)
    for _, command in pairs(self.Commands) do
        if message == command then
            self:_addVote(from)
            break
        end
    end
end

--- @type CHATCOMMAND
-- @field #boolean VoteActive Is voting active
-- @field #number VotesNeeded Number of votes needed to execute callback
-- @field #number CurrentVotes Actual number of voted
-- @field #table PlayerIDsVoted Array of player ids already voted
-- @field #string Commands The commands as string table to listen to
-- @field #function Callback Callback if voting was successfull
-- @field #lastStartTime The DCS timer id for the voting reset
-- @type CHATCOMMAND

--- VOTING CLASS
-- @field #VOTING VOTING
CHATCOMMAND = {}
CHATCOMMAND.__index = CHATCOMMAND

--- Create new CHATCOMMAND
-- @param #CHATCOMMAND self
-- @param #string command The commands as string table to listen to
-- @param #string callback Callback to execute. Parameter given to the callback is the requester player id
-- @return #CHATCOMMAND
function CHATCOMMAND.New(commands, callback)
    local self = {}
    setmetatable(self, CHATCOMMAND)
    self.Commands = commands
    self.Callback = callback
    return self
end

function CHATCOMMAND:OnChatMessage(message, from)
    for _, command in pairs(self.Commands) do
        if message == command then
            self.Callback(from)
            break
        end
    end
end




ChatCommands = {}
local commands = {}

table.insert(commands, VOTING.New({ "--skip", "-skip" },
    function()
        log.write(filename, log.INFO, "Skip voting successfull. Next mission will be started.")
        net.send_chat("Voting successfull. Next mission will be started.", true)
        RandomWeather.LoadNextMission()
    end))

table.insert(commands, CHATCOMMAND.New({ "--time", "-time" },
    function()
        local hoursLeft = math.floor((AutoEnd.TimeLeft) / 60 / 60)
        local minutesLeft = math.floor((AutoEnd.TimeLeft) / 60 % 60)
        local secondsLeft = math.floor((AutoEnd.TimeLeft) % 60)
        net.send_chat("Mission end in " .. hoursLeft .. "h " .. minutesLeft .. "m " .. secondsLeft .. "s", true)
    end))

table.insert(commands, VOTING.New({ "--restart", "-restart" },
    function()
        log.write(filename, log.INFO, "Restart voting successfull. Mission will be restarted.")
        net.send_chat("Voting successfull. Mission will be restarted.", true)
        
        local missionIndex = net.missionlist_get().current
        net.missionlist_run(missionIndex)
    end))

table.insert(commands, CHATCOMMAND.New({ "--mytime", "-mytime" },
    function(playerId)
        local time = os.time() - ServerStatus.OnlinePlayers[playerId].JoinTime
        local hours = string.sub("00" .. tostring(math.floor(time / 60 / 60)), -2)
        local minutes = string.sub("00" .. tostring(math.floor(time / 60 % 60)), -2)
        local seconds = string.sub("00" .. tostring(math.floor(time % 60)), -2)
        net.send_chat_to(hours .. ":" .. minutes .. ":" .. seconds .. " h", playerId)
    end))

table.insert(commands, CHATCOMMAND.New({ "--help", "-help", "--h", "-h" },
    function (playerId)
        net.send_chat_to("Available commands:", playerId)
        net.send_chat_to("--help      available commands", playerId)
        net.send_chat_to("--time      time until restart", playerId)
        net.send_chat_to("--skip       vote next mission", playerId)
        net.send_chat_to("--restart   vote mission restart", playerId)
        net.send_chat_to("--mytime  your session time", playerId)
    end))

function ChatCommands.OnChatMessage(message, from)
    if DCS.isServer() then
        for _, cmd in pairs(commands) do
            cmd:OnChatMessage(message, from)
        end
    end
end

log.write(filename, log.INFO, 'Start ChatCommands')