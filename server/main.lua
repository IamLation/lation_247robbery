GlobalState.registerCooldown = false
GlobalState.safeCooldown = false

-- Function used to make numbers prettier (Credits to ESX for the function)
--- @param value number
local GroupDigits = function(value)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

-- Function to manage register cooldown
local RegisterCooldown = function()
    SetTimeout(2000, function()
        GlobalState.registerCooldown = true
        local cooldown = math.random(Config.RegisterMinCooldown * 60000, Config.RegisterMaxCooldown * 60000)
        local format = cooldown / 1000 / 60
        local cooldownRound = math.floor(format)
        DiscordLogs(
            Strings.Logs.titles.cooldownA,
            Strings.Logs.messages.cooldownRA ..cooldownRound .. ' ' ..Strings.Logs.messages.minutes,
            Strings.Logs.colors.red
        )
        Wait(cooldown)
        DiscordLogs(
            Strings.Logs.titles.cooldownI,
            Strings.Logs.messages.cooldownRI,
            Strings.Logs.colors.green
        )
        GlobalState.registerCooldown = false
    end)
end

-- Function to manage safe cooldown
local SafeCooldown = function()
    SetTimeout(2000, function()
        GlobalState.safeCooldown = true
        local cooldown = math.random(Config.SafeMinCooldown * 60000, Config.SafeMaxCooldown * 60000)
        local format = cooldown / 1000 / 60
        local cooldownRound = math.floor(format)
        DiscordLogs(
            Strings.Logs.titles.cooldownA,
            Strings.Logs.messages.cooldownSA ..cooldownRound .. ' ' ..Strings.Logs.messages.minutes,
            Strings.Logs.colors.red
        )
        Wait(cooldown)
        DiscordLogs(
            Strings.Logs.titles.cooldownI,
            Strings.Logs.messages.cooldownSI,
            Strings.Logs.colors.green
        )
        GlobalState.safeCooldown = false
    end)
end

-- Function to check the players distance to registers/safes/etc
--- @param source number
local CheckPlayerDistance = function(source)
    local ped = GetPlayerPed(source)
    local playerPos = GetEntityCoords(ped)
    for _, locations in pairs(Config.Locations) do
        for _, location in pairs(locations) do
            local distance = #(playerPos - location)
            if distance < 5 then
                return true
            end
        end
    end
    return false
end

RegisterNetEvent('lation_247robbery:RewardRobbery', function(source, type)
    local source = source
    local player = GetPlayer(source)
    if not player then return end
    local playerName = GetName(source)
    local identifier = GetIdentifier(source)
    local distance = CheckPlayerDistance(source)
    local item, quantity, value
    if distance then
        if type == 'register' then
            item = Config.RegisterRewardItem
            quantity = Config.RegisterRewardQuantity
            if Config.RegisterRewardRandom then
                quantity = math.random(Config.RegisterRewardMinQuantity, Config.RegisterRewardMaxQuantity)
            end
            value = quantity
            RegisterCooldown()
        else
            item = Config.SafeRewardItem
            quantity = Config.SafeRewardQuantity
            if Config.SafeRewardRandom then
                quantity = math.random(Config.SafeRewardMinQuantity, Config.SafeRewardMaxQuantity)
            end
            value = quantity
            SafeCooldown()
        end
        if Framework == 'qb' then
            if Config.Metadata then
                quantity = {worth = quantity}
                value = quantity.worth
            end
        end
        AddItem(source, item, quantity)
        if Config.EnableLogs then
            local robType = type:gsub("^%l", string.upper) -- Capitalizing string for logs
            DiscordLogs(
                '💰 ' ..robType.. ' ' ..Strings.Logs.titles.robbery,
                Strings.Logs.labels.name ..playerName..
                Strings.Logs.labels.id ..tostring(source)..
                Strings.Logs.labels.identifier ..tostring(identifier)..
                Strings.Logs.labels.message ..Strings.Logs.messages.robbery.. '$' ..GroupDigits(value).. ' ' ..item,
                Strings.Logs.colors.green
            )
        end
    end
end)

-- Function that gets the passed item & quantity and removes it
RegisterNetEvent('lation_247robbery:RemoveItem', function(source, item, quantity)
    local source = source
    RemoveItem(source, item, quantity)
end)

-- Callback used to get police count
lib.callback.register('lation_247robbery:getPoliceCount', function()
    local policeCount = PlayersWithJob(Config.PoliceJobs)
    return policeCount
end)