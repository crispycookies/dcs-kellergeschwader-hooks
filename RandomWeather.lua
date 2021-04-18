local filename = 'RandomWeather.lua'

RandomWeather = {}

function RandomWeather.LoadNextMission()
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

    log.write(filename, log.INFO, "Weather updated, loadnext mission")
    net.load_next_mission()
end

log.write(filename, log.INFO, "Loaded")