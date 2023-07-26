local invState = GetResourceState('ox_inventory')

-- Get framework
if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
    Framework = 'esx'
elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    Framework = 'qb'
else
    -- Add support for a custom framework here
    return
end

-- Get player from source
GetPlayer = function(source)
    if Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    else
        -- Add support for a custom framework here
    end
end

-- Function to get a players name
GetName = function(source)
    local player = GetPlayer(source)
    if player then
        if Framework == 'esx' then
            return player.getName()
        elseif Framework == 'qb' then
            return player.PlayerData.charinfo.firstname..' '..player.PlayerData.charinfo.lastname
        end
    end
end

-- Function to add an item to inventory
AddItem = function(source, item, count, slot, metadata)
    local player = GetPlayer(source)
    if invState == 'started' then
        return exports.ox_inventory:AddItem(source, item, count, metadata, slot)
    else
        if Framework == 'esx' then
            return player.addInventoryItem(item, count, metadata, slot)
        elseif Framework == 'qb' then
            player.Functions.AddItem(item, 1, false, count)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add')
        else
            -- Add support for a custom framework here
        end
    end
end

-- Function to remove an item from inventory
RemoveItem = function(source, item, count, slot, metadata)
    local player = GetPlayer(source)
    if invState == 'started' then
        return exports.ox_inventory:RemoveItem(source, item, count, metadata, slot)
    else
        if Framework == 'esx' then
            return player.removeInventoryItem(item, count, metadata, slot)
        elseif Framework == 'qb' then
            player.Functions.RemoveItem(item, count, slot, metadata)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "remove")
        else
            -- Add support for a custom framework here
        end
    end
end

PlayersWithJob = function(jobName)
    local jobCount = 0
    if Framework == 'esx' then
        for _, player in pairs(ESX.GetExtendedPlayers()) do
            local job = player.getJob()
            for _, jobs in pairs(jobName) do
                local jobNames = jobs
                if job.name == jobNames then
                    jobCount = jobCount + 1
                end
            end
        end
    elseif Framework == 'qb' then
        for _, players in pairs(QBCore.Functions.GetPlayers()) do
            local player = QBCore.Functions.GetPlayer(players)
            local job = player.PlayerData.job
            for _, jobs in pairs(jobName) do
                local jobNames = jobs
                if job.name == jobNames then
                    jobCount = jobCount + 1
                end
            end
        end
    else
        -- Add support for a custom framework here
    end
    return jobCount
end