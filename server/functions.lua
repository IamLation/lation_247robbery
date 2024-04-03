-- Function that produces Discord Webhook logs
--- @param data table
DiscordLogs = function(data)
    local embed = {{["color"] = data.color, ["title"] = "**".. data.title .."**", ["description"] = data.message, ["footer"] = {["text"] = os.date("%a %b %d, %I:%M%p"), ["icon_url"] = Logs.Footer}}}
    PerformHttpRequest(data.link, function(err, text, headers) end, 'POST', json.encode({username = Logs.Name, embeds = embed, avatar_url = Logs.Image}), { ['Content-Type'] = 'application/json' })
end