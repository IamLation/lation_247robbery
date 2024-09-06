-- Initialize table to store known locations & robbery states
local locations, states = {}, {}

-- Function used to make numbers prettier (Credits to ESX for the function)
--- @param value number
local GroupDigits = function(value)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

-- Builds local table containing all locations categorized
local InitializeStores = function ()
    for type, coords in pairs(Config.Locations) do
        for _, location in pairs(coords) do
            if not locations[type:lower()] then locations[type:lower()] = {} end
            locations[type:lower()][#locations[type:lower()] + 1] = location
        end
    end
end

-- Returns boolean if player is nearby defined coords based on location type
--- @param source number
--- @param location string registers, computers, safes
--- @return boolean
local IsPlayerNearby = function(source, location)
    if not source or not location then return false end
    local playerPos = GetEntityCoords(GetPlayerPed(source))
    for _, coords in pairs(locations[location]) do
        if #(playerPos - coords) <= 2.5 then
            return true
        end
    end
    return false
end

-- Returns boolean if player can start robbery
--- @param identifier string
--- @return boolean
local CanPlayerRob = function(identifier)
    if not identifier then return false end
    local currentTime = os.time()
    if not states[identifier] then return true end
    local lastCompleted = states[identifier].completed
    if lastCompleted then
        if (currentTime - lastCompleted) < Config.Setup.cooldown then
            return false
        end
    end
    return true
end

-- Callback to initialize store robbery
--- @param source number
--- @return boolean
lib.callback.register('lation_247robbery:StartRobbery', function(source)
    if not source then
        EventLog('[main.lua]: lation_247robbery:StartRobbery: unable to retrieve source', 'error')
        return false
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog('[main.lua]: lation_247robbery:StartRobbery: unable to retrieve player identifier', 'error')
        return false
    end
    local isNearRegister = IsPlayerNearby(source, 'registers')
    if not isNearRegister then
        EventLog('[main.lua]: lation_247robbery:StartRobbery: player not nearby any registers', 'error')
        return false
    end
    local hasRequiredItem = GetItemCount(source, Config.Registers.item) >= 1
    if not hasRequiredItem then
        TriggerClientEvent('lation_247robbery:Notify', source, Strings.Notify.missingItem, 'error')
        EventLog('[main.lua]: lation_247robbery:StartRobbery: player missing required item', 'error')
        return false
    end
    if Config.Police.require then
        local police = GetPoliceCount()
        if not police or police < Config.Police.count then
            TriggerClientEvent('lation_247robbery:Notify', source, Strings.Notify.notEnoughPolice, 'error')
            EventLog('[main.lua]: lation_247robbery:StartRobbery: not enough police to start robbery', 'error')
            return false
        end
    end
    if not CanPlayerRob(identifier) then
        TriggerClientEvent('lation_247robbery:Notify', source, Strings.Notify.registerCooldown, 'error')
        EventLog('[main.lua]: lation_247robbery:StartRobbery: cooldown is still active for player', 'error')
        return false
    end
    if not states[identifier] then states[identifier] = {} end
    states[identifier].state = 'in_progress'
    states[identifier].started = os.time()
    -- Fallback to reset states if not completed in a reasonable amount of time
    SetTimeout(600000, function() -- 10 minutes timeout
        if states[identifier] and states[identifier].state == 'in_progress' then
            states[identifier] = nil
        end
    end)
    return true
end)

-- Event to handle lockpick breaking chance
RegisterNetEvent('lation_247robbery:DoesLockpickBreak', function()
    if not source then
        EventLog('[main.lua]: lation_247robbery:DoesLockpickBreak: unable to retrieve source', 'error')
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog('[main.lua]: lation_247robbery:DoesLockpickBreak: unable to retrieve player identifier', 'error')
        return
    end
    if not states[identifier] or states[identifier].state ~= 'in_progress' then
        EventLog('[main.lua]: lation_247robbery:DoesLockpickBreak: robbery wasnt initiated for player', 'error')
        return
    end
    local isNearRegister = IsPlayerNearby(source, 'registers')
    if not isNearRegister then
        EventLog('[main.lua]: lation_247robbery:DoesLockpickBreak: player not nearby any registers', 'error')
        return
    end
    if math.random(100) <= Config.Registers.breakChance then
        RemoveItem(source, Config.Registers.item, 1)
        TriggerClientEvent('lation_247robbery:Notify', source, Strings.Notify.lockpickBroke, 'error')
    end
end)

-- Event to handle robbery completion and rewards
RegisterNetEvent('lation_247robbery:CompleteRegisterRobbery', function()
    if not source then
        EventLog('[main.lua]: lation_247robbery:CompleteRegisterRobbery: unable to retrieve source', 'error')
        return
    end
    local source = source
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog('[main.lua]: lation_247robbery:CompleteRegisterRobbery: unable to retrieve player identifier', 'error')
        return
    end
    local name = GetName(source)
    if not name then
        EventLog('[main.lua]: lation_247robbery:CompleteRegisterRobbery: unable to retrieve player name', 'error')
        return
    end
    if not states[identifier] or states[identifier].state ~= 'in_progress' then
        EventLog('[main.lua]: lation_247robbery:CompleteRegisterRobbery: robbery wasnt initiated for player', 'error')
        return
    end
    local isNearRegister = IsPlayerNearby(source, 'registers')
    if not isNearRegister then
        EventLog('[main.lua]: lation_247robbery:CompleteRegisterRobbery: player not nearby any registers', 'error')
        return
    end
    local data = Config.Registers.reward
    if not data then
        EventLog('[main.lua]: lation_247robbery:CompleteRegisterRobbery: unable to retrieve config data', 'error')
        return
    end
    local quantity = math.random(data.min, data.max)
    if Config.Police.risk then
        local police = GetPoliceCount()
        local increase = 1 + (police * Config.Police.percent / 100)
        quantity = math.floor(quantity * increase)
    end
    states[identifier].state = 'completed'
    states[identifier].completed = os.time()
    AddItem(source, data.item, quantity)
    if Logs.Events.register_robbed then
        local log = Strings.Logs.register_robbed.message
        local message = string.format(log, tostring(name), tostring(identifier), tostring(GroupDigits(quantity)))
        PlayerLog(source, Strings.Logs.register_robbed.title, message)
    end
end)

-- Event to handle robbery completion and rewards
RegisterNetEvent('lation_247robbery:CompleteSafeRobbery', function()
    if not source then
        EventLog('[main.lua]: lation_247robbery:CompleteSafeRobbery: unable to retrieve source', 'error')
        return
    end
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog('[main.lua]: lation_247robbery:CompleteSafeRobbery: unable to retrieve player identifier', 'error')
        return
    end
    local name = GetName(source)
    if not name then
        EventLog('[main.lua]: lation_247robbery:CompleteSafeRobbery: unable to retrieve player name', 'error')
        return
    end
    if not states[identifier] or states[identifier].state ~= 'completed' then
        EventLog('[main.lua]: lation_247robbery:CompleteSafeRobbery: player has not completed the register robbery', 'error')
        return
    end
    local isNearSafe = IsPlayerNearby(source, 'safes')
    if not isNearSafe then
        EventLog('[main.lua]: lation_247robbery:CompleteSafeRobbery: player not nearby any safes', 'error')
        return
    end
    local data = Config.Safes.reward
    if not data then
        EventLog('[main.lua]: lation_247robbery:CompleteSafeRobbery: unable to retrieve safe reward config data', 'error')
        return
    end
    local quantity = math.random(data.min, data.max)
    if Config.Police.risk then
        local police = GetPoliceCount()
        local increase = 1 + (police * Config.Police.percent / 100)
        quantity = math.floor(quantity * increase)
    end
    states[identifier].state = nil
    states[identifier].completed = os.time()
    AddItem(source, data.item, quantity)
    if Logs.Events.safe_robbed then
        local log = Strings.Logs.safe_robbed.message
        local message = string.format(log, tostring(name), tostring(identifier), tostring(GroupDigits(quantity)))
        PlayerLog(source, Strings.Logs.safe_robbed.title, message)
    end
end)

-- Populate local table with categorized coords
InitializeStores()