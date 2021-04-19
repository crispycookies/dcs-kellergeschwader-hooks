local filename = 'RandomWeather.lua'

RandomWeather = {}
local loadNextTime = 0
local loadNextMission = false
local loadNextOffset = 30

function RandomWeather.LoadNextMission()
    if loadNextMission == false then
        log.write(filename, log.INFO, "Start randomizing weather...")
        local missionList = net.missionlist_get()
        local missionCount = 0

        for _ in pairs(missionList.missionList) do
            missionCount = missionCount + 1
        end

        local nextMissionIndex = missionList.listStartIndex + 1
        if nextMissionIndex > missionCount then
            nextMissionIndex = 1
        end

        log.write(filename, log.INFO, "Update weather on " .. missionList.missionList[nextMissionIndex])

        local command = [[""]] .. lfs.writedir() .. [[Scripts\dcs-random-go-weather\DCSRandomGoWeather.exe" "-m ]] .. missionList.missionList[nextMissionIndex] .. [[""]]
        os.execute(command)
        loadNextMission = true
        loadNextTime = DCS.getRealTime()
        log.write(filename, log.INFO, "Weather updated, wait " .. loadNextOffset .." seconds before load next mission")
    end
end

function RandomWeather.OnSimulationFrame()
    if loadNextMission and (DCS.getRealTime() - loadNextTime) >= loadNextOffset then
        log.write(filename, log.INFO, "Load next mission")
        loadNextMission = false
        loadNextTime = 0
        net.load_next_mission()
    end
end

log.write(filename, log.INFO, "Loaded")