-- Initialize global variables to store framework & inventory
Framework, Inventory = nil, nil

-- Initialize config(s)
local shared = require 'config.shared'

-- Get framework
local function InitializeFramework()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'esx'
    elseif GetResourceState('qbx_core') == 'started' then
        Framework = 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qb'
    elseif GetResourceState('ox_core') == 'started' then
        Ox = require '@ox_core.lib.init'
        Framework = 'ox'
    else
        -- Add custom framework here
    end
end

-- Get inventory
local function InitializeInventory()
    if GetResourceState('ox_inventory') == 'started' then
        Inventory = 'ox_inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        Inventory = 'qb-inventory'
    elseif GetResourceState('qs-inventory') == 'started' then
        Inventory = 'qs-inventory'
    elseif GetResourceState('ps-inventory') == 'started' then
        Inventory = 'ps-inventory'
    elseif GetResourceState('origen_inventory') == 'started' then
        Inventory = 'origen_inventory'
    elseif GetResourceState('codem-inventory') == 'started' then
        Inventory = 'codem-inventory'
    elseif GetResourceState('core_inventory') == 'started' then
        Inventory = 'core_inventory'
    else
        -- Add custom inventory here
    end
end

-- Get player from source
--- @param source number Player ID
function GetPlayer(source)
    if not source then return end
    if Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Framework == 'qbx' then
        return exports.qbx_core:GetPlayer(source)
    elseif Framework == 'ox' then
        return Ox.GetPlayer(source)
    else
        -- Add custom framework here
    end
end

-- Function to get a player identifier by source
--- @param source number Player ID
function GetIdentifier(source)
    local player = GetPlayer(source)
    if not player then return end
    if Framework == 'esx' then
        return player.identifier
    elseif Framework == 'qb' or Framework == 'qbx' then
        return player.PlayerData.citizenid
    elseif Framework == 'ox' then
        return player.stateId
    else
        -- Add custom framework here
    end
end

-- Function to get a player's name
--- @param source number Player ID
--- @return string
function GetName(source)
    local player = GetPlayer(source)
    if not player then return 'Unknown' end
    if Framework == 'esx' then
        return player.getName()
    elseif Framework == 'qb' or Framework == 'qbx' then
        return player.PlayerData.charinfo.firstname.. ' ' ..player.PlayerData.charinfo.lastname
    elseif Framework == 'ox' then
        return player.get('firstName').. ' ' ..player.get('lastName')
    else
        -- Add custom framework here
    end
    return 'Unknown'
end

-- Returns number of players with police job(s)
--- @return number
function GetPoliceCount()
    local count, jobs = 0, {}
    for _, job in pairs(shared.police.jobs) do
        jobs[job] = true
    end
    if Framework == 'esx' then
        for _, player in pairs(ESX.GetExtendedPlayers()) do
            if jobs[player.getJob().name] then
                count += 1
            end
        end
    elseif Framework == 'qb' then
        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local player = QBCore.Functions.GetPlayer(playerId)
            if jobs[player.PlayerData.job.name] and player.PlayerData.job.onduty then
                count += 1
            end
        end
    elseif Framework == 'qbx' then
        for job, _ in pairs(jobs) do
            count += exports.qbx_core:GetDutyCountJob(job)
        end
    elseif Framework == 'ox' then
        for _, player in pairs(Ox.GetPlayers()) do
            if jobs[player.getGroupByType('job')] then
                count += 1
            end
        end
    else
        -- Add custom framework here
    end
    return count
end

-- Returns number of specified item in players inventory
--- @param source number Player ID
--- @param item string Item to search
--- @return number
function GetItemCount(source, item)
    if not source or not item then return 0 end
    local player = GetPlayer(source)
    if not player then return 0 end
    if Inventory then
        if Inventory == 'ox_inventory' then
            return exports[Inventory]:Search(source, 'count', item) or 0
        elseif Inventory == 'core_inventory' then
            return exports[Inventory]:getItemCount(source, item)
        else
            local itemData = exports[Inventory]:GetItemByName(source, item)
            if not itemData then return 0 end
            return itemData.amount or itemData.count or 0
        end
    else
        if Framework == 'esx' then
            local itemData = player.getInventoryItem(item)
            if not itemData then return 0 end
            return itemData.count or itemData.amount or 0
        elseif Framework == 'qb' then
            local itemData = player.Functions.GetItemByName(item)
            if not itemData then return 0 end
            return itemData.amount or itemData.count or 0
        else
            -- Add custom framework here
        end
    end
    return 0
end

-- Returns correct framework money type if needed
--- @param type string Money type
--- @return string
local function ConvertMoneyType(type)
    if type == 'money' and (Framework == 'qb' or Framework == 'qbx') then
        type = 'cash'
    elseif type == 'cash' and (Framework == 'esx' or Framework == 'ox') then
        type = 'money'
    else
        -- Add custom framework here
    end
    return type
end

-- Add money to players account
--- @param source number Player ID
--- @param type string Account to add to
--- @param amount number Amount to add
function AddMoney(source, type, amount)
    local player = GetPlayer(source)
    if not player then return end
    if Framework == 'esx' then
        player.addAccountMoney(ConvertMoneyType(type), amount)
    elseif Framework == 'qb' or Framework == 'qbx' then
        player.Functions.AddMoney(ConvertMoneyType(type), amount)
    elseif Framework == 'ox' then
        if type == 'cash' or type == 'money' then
            exports.ox_inventory:AddItem(source, ConvertMoneyType(type), amount)
        else
            local accountId = Ox.GetCharacterAccount(source).id
            Ox.DepositMoney(source, accountId, amount)
        end
    else
        -- Add custom framework here
    end
end

-- Adds an item to players inventory
--- @param source number Player ID
--- @param item string Item to add
--- @param count number Quantity to add
--- @param metadata any|table Optional metadata
function AddItem(source, item, count, metadata)
    if count <= 0 then return end
    local player = GetPlayer(source)
    if not player then return end
    if Inventory then
        if Inventory == 'ox_inventory' then
            exports[Inventory]:AddItem(source, item, count, metadata)
        elseif Inventory == 'core_inventory' then
            exports[Inventory]:addItem(source, item, count, metadata)
        else
            exports[Inventory]:AddItem(source, item, count, nil, metadata)
            if Framework == 'qb' then
                TriggerClientEvent(Inventory.. ':client:ItemBox', source, QBCore.Shared.Items[item], 'add')
            end
        end
    else
        if Framework == 'esx' then
            player.addInventoryItem(item, count)
        elseif Framework == 'qb' then
            player.Functions.AddItem(item, count, nil, metadata)
        else
            -- Add custom framework here
        end
    end
end

-- Removes an item from players inventory
--- @param source number Player ID
--- @param item string Item to remove
--- @param count number Quantity to remove
function RemoveItem(source, item, count)
    local player = GetPlayer(source)
    if not player then return end
    if Inventory then
        if Inventory == 'core_inventory' then
            exports[Inventory]:removeItem(source, item, count)
        else
            exports[Inventory]:RemoveItem(source, item, count)
            if Framework == 'qb' then
                TriggerClientEvent(Inventory.. ':client:ItemBox', source, QBCore.Shared.Items[item], 'remove')
            end
        end
    else
        if Framework == 'esx' then
            player.removeInventoryItem(item, count)
        elseif Framework == 'qb' then
            player.Functions.RemoveItem(item, count)
        else
            -- Add custom framework here
        end
    end
end

-- Initialize defaults
InitializeFramework()
InitializeInventory()