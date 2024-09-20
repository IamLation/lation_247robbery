-- Check to see if fm-logs or fmsdk is started
local fmlogs = GetResourceState('fm-logs') == 'started'
local fmsdk = GetResourceState('fmsdk') == 'started'

-- Log events if applicable
--- @param message string Message contents
--- @param type string Log type
EventLog = function(message, type)
    if not message or not Config.Setup.debug then return end
    if Logs.Service == 'fivemanage' then
        if not fmsdk then return end
        exports.fmsdk:LogMessage(type or 'info', message)
    elseif Logs.Service == 'fivemerr' then
        if not fmlogs then return end
        exports['fm-logs']:createLog({
            LogType = 'Resource',
            Resource = 'lation_247robbery',
            Level = type or 'info',
            Message = message,
        })
    else
        print(message)
    end
end

-- Log player events if applicable
--- @param source number Player ID
--- @param title string Log title
--- @param message string Message contents
PlayerLog = function(source, title, message)
    if Logs.Service == 'fivemanage' then
        if not fmsdk then return end
        if Logs.Screenshots then
            exports.fmsdk:takeServerImage(source, {
                name = title,
                description = message,
            })
        else
            exports.fmsdk:LogMessage('info', message)
        end
    elseif Logs.Service == 'fivemerr' then
        if not fmlogs then return end
        exports['fm-logs']:createLog({
            LogType = 'Player',
            Message = message,
            Resource = 'lation_247robbery',
            Source = source,
        }, { Screenshot = Logs.Screenshots })
    elseif Logs.Service == 'discord' then
        local embed = {
            {
                ["color"] = 16711680,
                ["title"] = "**".. title .."**",
                ["description"] = message,
                ["footer"] = {
                    ["text"] = os.date("%a %b %d, %I:%M%p"),
                    ["icon_url"] = Logs.Discord.footer
                }
            }
        }
        PerformHttpRequest(Logs.Discord.link, function()
        end, 'POST', json.encode({username = Logs.Discord.name, embeds = embed, avatar_url = Logs.Discord.image}), {['Content-Type'] = 'application/json'})
    end
end