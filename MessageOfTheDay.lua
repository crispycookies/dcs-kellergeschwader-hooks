local filename = 'MessageOfTheDay.lua'
MessageOfTheDay = {}

function MessageOfTheDay.OnPlayerConnect(id)
    if DCS.isServer() then
        net.send_chat_to("Welcome to the Kellergeschwader", id)
        net.send_chat_to("Visit us on https://kellergeschwader.com")
        net.send_chat_to("Type '--help' for available chat commands", id)
    end
end

log.write(filename, log.INFO, 'Start MessageOfTheDay')