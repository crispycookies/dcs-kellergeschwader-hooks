local filename = 'MessageOfTheDay.lua'
MessageOfTheDay = {}

function MessageOfTheDay.OnPlayerConnect(id)
    if DCS.isServer() then
        net.send_chat_to("Willkommen beim Kellergeschwader", id)
        net.send_chat_to("Besuche uns auf https://kellergeschwader.com")
        net.send_chat_to("Tippe '--help' für verfügbare chat Befehle", id)
    end
end

log.write(filename, log.INFO, 'Start MessageOfTheDay')