GlobalState.registerCooldown = false
GlobalState.safeCooldown = false
local minutes = 60000

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
        local cooldown = math.random(Config.Registers.cooldown.min, Config.Registers.cooldown.max) * minutes
        local format = math.floor(cooldown / minutes)
        if Logs.Types.cooldown.enabled then
            local logData = {
                link = Logs.Types.cooldown.webhook,
                title = Strings.Logs.titles.cooldownA,
                message = Strings.Logs.messages.cooldownRA ..format .. ' ' ..Strings.Logs.messages.minutes,
                color = Strings.Logs.colors.red
            }
            DiscordLogs(logData)
        end
        Wait(cooldown)
        if Logs.Types.cooldown.enabled then
            local logData = {
                link = Logs.Types.cooldown.webhook,
                title = Strings.Logs.titles.cooldownI,
                message = Strings.Logs.messages.cooldownRI,
                color = Strings.Logs.colors.green
            }
            DiscordLogs(logData)
        end
        GlobalState.registerCooldown = false
    end)
end

-- Function to manage safe cooldown
local SafeCooldown = function()
    SetTimeout(2000, function()
        GlobalState.safeCooldown = true
        local cooldown = math.random(Config.Safes.cooldown.min, Config.Safes.cooldown.max) * minutes
        local format = math.floor(cooldown / minutes)
        if Logs.Types.cooldown.enabled then
            local logData = {
                link = Logs.Types.cooldown.webhook,
                title = Strings.Logs.titles.cooldownA,
                message = Strings.Logs.messages.cooldownSA ..format .. ' ' ..Strings.Logs.messages.minutes,
                color = Strings.Logs.colors.red
            }
            DiscordLogs(logData)
        end
        Wait(cooldown)
        if Logs.Types.cooldown.enabled then
            local logData = {
                link = Logs.Types.cooldown.webhook,
                title = Strings.Logs.titles.cooldownI,
                message = Strings.Logs.messages.cooldownSI,
                color = Strings.Logs.colors.green
            }
            DiscordLogs(logData)
        end
        GlobalState.safeCooldown = false
    end)
end

-- Function to check the players distance to registers/safes/etc
--- @param source number
local CheckPlayerDistance = function(source)
    if not source then return false end
    local ped = GetPlayerPed(source)
    local playerPos = GetEntityCoords(ped)
    for _, locations in pairs(Config.Locations) do
        for _, location in pairs(locations) do
            local distance = #(playerPos - location)
            if distance < 10 then
                return true
            end
        end
    end
    return false
end

-- Event to handle robbery completion
--- @param source number
--- @param type string
RegisterNetEvent('lation_247robbery:RewardRobbery', function(source, type)
    if not source or not type then return end
    local source = source
    local player = GetPlayer(source)
    if not player then return end
    local playerName = GetName(source)
    local identifier = GetIdentifier(source)
    local distance = CheckPlayerDistance(source)
    if not distance then return end
    local item = type == 'register' and Config.Registers.reward.item or Config.Safes.reward.item
    local quantity = (type == 'register') and math.random(Config.Registers.reward.min, Config.Registers.reward.max) or math.random(Config.Safes.reward.min, Config.Safes.reward.max)
    if Config.Police.risk then
        local policeCount = PlayersWithJob(Config.Police.jobs)
        local increaseFactor = 1 + (policeCount * Config.Police.percent / 100)
        quantity = quantity * increaseFactor
    end
    if type == 'register' then
        RegisterCooldown()
    else
        SafeCooldown()
    end
    AddItem(source, item, quantity)
    if Logs.Types.robbery.enabled then
        local robType = type:gsub("^%l", string.upper)
        local logData = {
            link = Logs.Types.robbery.webhook,
            title = '💰 ' ..robType.. ' ' ..Strings.Logs.titles.robbery,
            message = Strings.Logs.labels.name ..playerName..
                Strings.Logs.labels.id ..tostring(source)..
                Strings.Logs.labels.identifier ..tostring(identifier)..
                Strings.Logs.labels.message ..Strings.Logs.messages.robbery.. '$' ..GroupDigits(quantity).. ' ' ..item,
            color = Strings.Logs.colors.green
        }
        DiscordLogs(logData)
    end
end)

-- Function that gets the passed item & quantity and removes it
--- @param source number
RegisterNetEvent('lation_247robbery:BreakLockpick', function(source)
    if not source then return end
    local source = source
    local player = GetPlayer(source)
    if not player then return end
    local distance = CheckPlayerDistance(source)
    if not distance then return end
    RemoveItem(source, Config.Registers.item, 1)
end)

-- Callback used to get police count
lib.callback.register('lation_247robbery:getPoliceCount', function()
    local policeCount = PlayersWithJob(Config.Police.jobs)
    return policeCount or 0
end)