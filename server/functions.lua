-- Initialize config(s)
local sv_config = require 'config.server'
local sh_config = require 'config.shared'

-- Check to see if fm-logs or fmsdk is started
local fmlogs = GetResourceState('fm-logs') == 'started'
local fmsdk = GetResourceState('fmsdk') == 'started'

-- Log events if applicable
--- @param message string Message contents
--- @param type string Log type
function EventLog(message, type)
    if not message or not sh_config.setup.debug then return end
    if sv_config.logs.service == 'fivemanage' then
        if not fmsdk then return end
        exports.fmsdk:LogMessage(type or 'info', message)
    elseif sv_config.logs.service == 'fivemerr' then
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
function PlayerLog(source, title, message)
    if sv_config.logs.service == 'fivemanage' then
        if not fmsdk then return end
        if sv_config.logs.screenshots then
            exports.fmsdk:takeServerImage(source, {
                name = title,
                description = message,
            })
        else
            exports.fmsdk:LogMessage('info', message)
        end
    elseif sv_config.logs.service == 'fivemerr' then
        if not fmlogs then return end
        exports['fm-logs']:createLog({
            LogType = 'Player',
            Message = message,
            Resource = 'lation_247robbery',
            Source = source,
        }, { Screenshot = sv_config.logs.screenshots })
    elseif sv_config.logs.service == 'discord' then
        local embed = {
            {
                ["color"] = 16711680,
                ["title"] = "**".. title .."**",
                ["description"] = message,
                ["footer"] = {
                    ["text"] = os.date("%a %b %d, %I:%M%p"),
                    ["icon_url"] = sv_config.logs.discord.footer
                }
            }
        }
        PerformHttpRequest(sv_config.logs.discord.link, function()
        end, 'POST', json.encode({username = sv_config.logs.discord.name, embeds = embed, avatar_url = sv_config.logs.discord.image}),
        {['Content-Type'] = 'application/json'})
    end
end