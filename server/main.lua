-- Initialize config(s)
local sh_config = require 'config.shared'
local sv_config = require 'config.server'

-- Initialize global state for cooldowns
GlobalState.cooldown = false
GlobalState.started = false

-- Initialize proper coordinates
local gabz = GetResourceState('cfx-gabz-247') == 'started'
local fm = GetResourceState('cfx-fm-supermarkets') == 'started'
local stores = gabz and require 'data.gabz' or fm and require 'data.fmshop' or require 'data.default'

-- Initialize table to store known locations & robbery states
local locations, states = {}, {}

-- Builds local table containing all locations categorized
local function InitializeStores()
    for type, coords in pairs(stores) do
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
local function IsPlayerNearby(source, location)
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
local function CanPlayerRob(identifier)
    if not identifier then return false end
    local currentTime = os.time()
    if sh_config.setup.global.enable then
        if GlobalState.cooldown or GlobalState.started then
            return false
        end
    end
    if not states[identifier] then return true end
    local lastCompleted = states[identifier].completed
    if lastCompleted then
        if (currentTime - lastCompleted) < sh_config.setup.cooldown then
            return false
        end
    end
    return true
end

-- Starts & ends global cooldown if enabled
local function StartCooldown()
    GlobalState.cooldown = true
    local wait = math.floor(sh_config.setup.global.duration * 1000)
    SetTimeout(wait, function()
        GlobalState.cooldown = false
    end)
end

-- Callback to initialize store robbery
--- @param source number
--- @return boolean
lib.callback.register('lation_247robbery:StartRobbery', function(source)
    if not source then
        EventLog('[main.lua]: lation_247robbery:StartRobbery: unable to retrieve source', 'error')
        return false
    end
    local source = source
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
    local hasRequiredItem = GetItemCount(source, sh_config.registers.item) >= 1
    if not hasRequiredItem then
        TriggerClientEvent('lation_247robbery:Notify', source, locale('notify.missing-item'), 'error')
        EventLog('[main.lua]: lation_247robbery:StartRobbery: player missing required item', 'error')
        return false
    end
    if sh_config.police.count > 0 then
        local police = GetPoliceCount()
        if not police or police < sh_config.police.count then
            TriggerClientEvent('lation_247robbery:Notify', source, locale('notify.no-police'), 'error')
            EventLog('[main.lua]: lation_247robbery:StartRobbery: not enough police to start robbery', 'error')
            return false
        end
    end
    if not CanPlayerRob(identifier) then
        TriggerClientEvent('lation_247robbery:Notify', source, locale('notify.cooldown'), 'error')
        EventLog('[main.lua]: lation_247robbery:StartRobbery: cooldown is still active (for player or global)', 'error')
        return false
    end
    GlobalState.started = true
    if not states[identifier] then states[identifier] = {} end
    states[identifier].state = 'in_progress'
    states[identifier].started = os.time()
    -- Fallback to reset states if not completed in a reasonable amount of time
    SetTimeout(600000, function() -- 10 minute timeout
        if states[identifier] and states[identifier].state == 'in_progress' then
            states[identifier] = nil
        end
        if GlobalState.started then
            GlobalState.started = false
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
    local source = source
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog('[main.lua]: lation_247robbery:DoesLockpickBreak: unable to retrieve player identifier', 'error')
        return
    end
    if sh_config.setup.global.enable then
        if not GlobalState.started then
            EventLog('[main.lua]: lation_247robbery:RegisterIncomplete: global state wasnt initiated', 'error')
            return
        end
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
    if math.random(100) <= sh_config.registers.breakChance then
        RemoveItem(source, sh_config.registers.item, 1)
        TriggerClientEvent('lation_247robbery:Notify', source, locale('notify.item-broke'), 'error')
    end
    if GlobalState.started then GlobalState.started = false end
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
    if sh_config.setup.global.enable then
        if not GlobalState.started then
            EventLog('[main.lua]: lation_247robbery:CompleteRegisterRobbery: global state wasnt initiated', 'error')
            return
        end
    end
    local isNearRegister = IsPlayerNearby(source, 'registers')
    if not isNearRegister then
        EventLog('[main.lua]: lation_247robbery:CompleteRegisterRobbery: player not nearby any registers', 'error')
        return
    end
    local police = sh_config.police.risk and GetPoliceCount() or 0
    local items = {}
    for _, add in pairs(sh_config.registers.reward) do
        if math.random(100) <= add.chance then
            local quantity = math.random(add.min, add.max)
            if police > 0 then
                local increase = 1 + (police * sh_config.police.percent / 100)
                quantity = math.floor(quantity * increase)
            end
            if add.metadata then
                AddItem(source, add.item, quantity, add.metadata)
            else
                if add.item == 'cash' or add.item == 'money' or add.item == 'bank' then
                    AddMoney(source, add.item, quantity)
                else
                    AddItem(source, add.item, quantity)
                end
            end
            items[#items + 1] = { item = add.item, quantity = quantity }
        end
    end
    local rewards = ''
    for _, reward in ipairs(items) do
        rewards = rewards .. 'x' .. reward.quantity .. ' ' ..reward.item .. ', '
    end
    rewards = rewards:sub(1, -3)
    states[identifier].state = 'completed'
    states[identifier].completed = os.time()
    if sv_config.logs.events.register_robbed and #items > 0 then
        ---@diagnostic disable-next-line: undefined-field
        PlayerLog(source, locale('logs.register-robbed-title'), locale('logs.register-robbed-message', name, identifier, rewards))
    end
end)

-- Event to handle robbery completion and rewards
RegisterNetEvent('lation_247robbery:CompleteSafeRobbery', function()
    if not source then
        EventLog('[main.lua]: lation_247robbery:CompleteSafeRobbery: unable to retrieve source', 'error')
        return
    end
    local source = source
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
    if sh_config.setup.global.enable then
        if not GlobalState.started then
            EventLog('[main.lua]: lation_247robbery:CompleteSafeRobbery: global state wasnt initiated', 'error')
            return
        end
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
    local police = sh_config.police.risk and GetPoliceCount() or 0
    local items = {}
    for _, add in pairs(sh_config.safes.reward) do
        if math.random(100) <= add.chance then
            local quantity = math.random(add.min, add.max)
            if police > 0 then
                local increase = 1 + (police * sh_config.police.percent / 100)
                quantity = math.floor(quantity * increase)
            end
            if add.metadata then
                AddItem(source, add.item, quantity, add.metadata)
            else
                if add.item == 'cash' or add.item == 'money' or add.item == 'bank' then
                    AddMoney(source, add.item, quantity)
                else
                    AddItem(source, add.item, quantity)
                end
            end
            items[#items + 1] = { item = add.item, quantity = quantity }
        end
    end
    local rewards = ''
    for _, reward in ipairs(items) do
        rewards = rewards .. 'x' .. reward.quantity .. ' ' ..reward.item .. ', '
    end
    rewards = rewards:sub(1, -3)
    GlobalState.started = false
    states[identifier].state = nil
    states[identifier].completed = os.time()
    StartCooldown()
    if sv_config.logs.events.safe_robbed and #items > 0 then
        ---@diagnostic disable-next-line: undefined-field
        PlayerLog(source, locale('logs.safe-robbed-title'), locale('logs.safe-robbed-message', name, identifier, rewards))
    end
end)

-- Event to handle failed robbery
RegisterNetEvent('lation_247robbery:FailedRobbery', function()
    if not source then
        EventLog('[main.lua]: lation_247robbery:FailedRobbery: unable to retrieve source', 'error')
        return
    end
    local source = source
    local identifier = GetIdentifier(source)
    if not identifier then
        EventLog('[main.lua]: lation_247robbery:FailedRobbery: unable to retrieve player identifier', 'error')
        return
    end
    local name = GetName(source)
    if not name then
        EventLog('[main.lua]: lation_247robbery:FailedRobbery: unable to retrieve player name', 'error')
        return
    end
    if sh_config.setup.global.enable then
        if not GlobalState.started then
            EventLog('[main.lua]: lation_247robbery:FailedRobbery: global state wasnt initiated', 'error')
            return
        end
    end
    if not states[identifier] or states[identifier].state ~= 'completed' then
        EventLog('[main.lua]: lation_247robbery:FailedRobbery: robbery wasnt initiated for player', 'error')
        return
    end
    local isNearRegister = IsPlayerNearby(source, 'computers')
    if not isNearRegister then
        EventLog('[main.lua]: lation_247robbery:CompleteRegisterRobbery: player not nearby any registers', 'error')
        return
    end
    GlobalState.started = false
    states[identifier].state = nil
    states[identifier].completed = os.time()
    StartCooldown()
end)

InitializeStores()