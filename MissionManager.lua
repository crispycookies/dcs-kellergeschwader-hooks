local filename = 'MissionManager.lua'

MissionManager = {}
local loadNextTime = 0
local loadNextMission = false
local loadNextOffset = 10

function MissionManager.LoadNextMission()
    if loadNextMission == false then
        log.write(filename, log.INFO, "Preparing to load next mission...")
        loadNextMission = true
        loadNextTime = DCS.getRealTime()
        log.write(filename, log.INFO, "Preparation finished, waiting " .. loadNextOffset .." seconds before load next mission")
    end
end

/* obviously this can be heavily optimized, e.g by just calling net.load_next_mission() but I do not care rn */
function MissionManager.OnSimulationFrame()
    if loadNextMission and (DCS.getRealTime() - loadNextTime) >= loadNextOffset then
        log.write(filename, log.INFO, "Load next mission")
        loadNextMission = false
        loadNextTime = 0
        net.load_next_mission()
    end
end

log.write(filename, log.INFO, "Loaded")