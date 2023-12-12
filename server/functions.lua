-- Function that produces Discord Webhook logs
--- @param title string Title of the log
--- @param message string Message contents
--- @param color number Decimal value embed color
DiscordLogs = function(title, message, color)
    local connect = {{["color"] = color, ["title"] = "**".. title .."**", ["description"] = message, ["footer"] = {["text"] = os.date("%a %b %d, %I:%M%p"), ["icon_url"] = Config.WebhookFooterImage}}}
    PerformHttpRequest(Config.DiscordWebhookLink, function(err, text, headers) end, 'POST', json.encode({username = Config.WebhookName, embeds = connect, avatar_url = Config.WebhookImage}), { ['Content-Type'] = 'application/json' })
end