-- Initialize global variables to store framework & inventory
Framework, Inventory = nil, nil

-- Get framework
InitializeFramework = function()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'esx'
    elseif GetResourceState('qbx_core') == 'started' then
        Framework = 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qb'
    else
        -- Add custom framework here
    end
end

-- Get inventory
InitializeInventory = function()
    if GetResourceState('ox_inventory') == 'started' then
        Inventory = 'ox_inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        Inventory = 'qb-inventory'
    elseif GetResourceState('qs-inventory') == 'started' then
        Inventory = 'qs-inventory'
    elseif GetResourceState('ps-inventory') == 'started' then
        Inventory = 'ps-inventory'
    elseif GetResourceState('lj-inventory') == 'started' then
        Inventory = 'lj-inventory'
    elseif GetResourceState('origen_inventory') == 'started' then
        Inventory = 'origen_inventory'
    elseif GetResourceState('codem-inventory') == 'started' then
        Inventory = 'codem-inventory'
    else
        -- Add custom inventory here
    end
end

-- Get player from source
--- @param source number Player ID
GetPlayer = function(source)
    if not source then return end
    if Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Framework == 'qbx' then
        return exports.qbx_core:GetPlayer(source)
    else
        -- Add custom framework here
    end
end

-- Function to get a player identifier by source
--- @param source number Player ID
GetIdentifier = function(source)
    local player = GetPlayer(source)
    if not player then return end
    if Framework == 'esx' then
        return player.identifier
    elseif Framework == 'qb' or Framework == 'qbx' then
        return player.PlayerData.citizenid
    else
        -- Add custom framework here
    end
end

-- Function to get a player's name
--- @param source number Player ID
--- @return string
GetName = function(source)
    local player = GetPlayer(source)
    if not player then return 'Unknown' end
    if Framework == 'esx' then
        return player.getName()
    elseif Framework == 'qb' or Framework == 'qbx' then
        return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    else
        -- Add custom framework here
    end
    return 'Unknown'
end

-- Returns number of players with police job(s)
--- @return number
GetPoliceCount = function()
    local count, jobs = 0, {}
    for _, job in pairs(Config.Police.jobs) do
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
            count = count + exports.qbx_core:GetDutyCountJob(job)
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
GetItemCount = function(source, item)
    if not source or not item then return 0 end
    local player = GetPlayer(source)
    if not player then return 0 end
    if Inventory then
        if Inventory == 'ox_inventory' then
            return exports[Inventory]:Search(source, 'count', item) or 0
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

-- Adds an item to players inventory
--- @param source number Player ID
--- @param item string Item to add
--- @param count number Quantity to add
AddItem = function(source, item, count)
    local player = GetPlayer(source)
    if not player then return end
    if Inventory then
        if Inventory == 'ox_inventory' then
            exports[Inventory]:AddItem(source, item, count)
        else
            if Config.Setup.metadata and item == 'markedbills' then
                local worth = { worth = count }
                exports[Inventory]:AddItem(source, item, 1, nil, worth)
            else
                exports[Inventory]:AddItem(source, item, count)
            end
            if Framework == 'qb' then
                TriggerClientEvent(Inventory.. ':client:ItemBox', source, QBCore.Shared.Items[item], 'add')
            end
        end
    else
        if Framework == 'esx' then
            player.addInventoryItem(item, count)
        elseif Framework == 'qb' then
            player.Functions.AddItem(item, count)
        else
            -- Add custom framework here
        end
    end
end

-- Removes an item from players inventory
--- @param source number Player ID
--- @param item string Item to remove
--- @param count number Quantity to remove
RemoveItem = function(source, item, count)
    local player = GetPlayer(source)
    if not player then return end
    if Inventory then
        exports[Inventory]:RemoveItem(source, item, count)
        if Framework == 'qb' then
            TriggerClientEvent(Inventory.. ':client:ItemBox', source, QBCore.Shared.Items[item], 'remove')
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