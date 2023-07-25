PlayerLoaded, PlayerData = nil, {}

local invState = GetResourceState('ox_inventory')
local libState = GetResourceState('ox_lib')

-- Get framework
if GetResourceState('es_extended') == 'started' then
    ESX = exports['es_extended']:getSharedObject()
    Framework = 'esx'

    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        PlayerLoaded = true
    end)

    RegisterNetEvent('esx:onPlayerLogout', function()
        table.wipe(PlayerData)
        PlayerLoaded = false
    end)

    AddEventHandler('onResourceStart', function(resourceName)
        if GetCurrentResourceName() ~= resourceName or not ESX.PlayerLoaded then
            return
        end
        PlayerData = ESX.GetPlayerData()
        PlayerLoaded = true
    end)

elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    Framework = 'qb'

    AddStateBagChangeHandler('isLoggedIn', '', function(_bagName, _key, value, _reserved, _replicated)
        if value then
            PlayerData = QBCore.Functions.GetPlayerData()
        else
            table.wipe(PlayerData)
        end
        PlayerLoaded = value
    end)

    AddEventHandler('onResourceStart', function(resourceName)
        if GetCurrentResourceName() ~= resourceName or not LocalPlayer.state.isLoggedIn then
            return
        end
        PlayerData = QBCore.Functions.GetPlayerData()
        PlayerLoaded = true
    end)
else
    -- Add support for a custom framework here
    return
end

-- Function to show a notification
ShowNotification = function(message, type)
    if libState == 'started' then
        lib.notify({
            title = Notify.title,
            description = message,
            type = type or 'inform',
            position = Notify.position,
            icon = Notify.icon
        })
    else
        if Framework == 'esx' then
            ESX.ShowNotification(message)
        elseif Framework == 'qb' then
            QBCore.Functions.Notify(message, type)
        else
            -- Add support for a custom framework here
        end
    end
end

-- Function to check if the player has the given items and amount
HasItem = function(items, amount)
    if invState == 'started' then
        if type(items) == 'table' then
            local itemArray = {}
            if next(items, next(items)) then
                itemArray = items
            else
                for k in pairs(items) do
                    itemArray[#itemArray + 1] = k
                end
            end
            local returnedItems = exports.ox_inventory:Search('count', itemArray)
            if returnedItems then
                local count = 0
                for k, amount in pairs(items) do
                    if returnedItems[k] and returnedItems[k] >= amount then
                        count = count + 1
                    end
                end
                return count == #itemArray
            end
            return false
        else
            return exports.ox_inventory:Search('count', items) >= 1
        end
    end
    if Framework == 'esx' then
        if not ESX.GetPlayerData() or not ESX.GetPlayerData().inventory then
            return false
        end
        local inventory = ESX.GetPlayerData().inventory
        local isTable = type(items) == 'table'
        local count = 0
        for _, itemData in pairs(inventory) do
            if isTable then
                for k, amount in pairs(items) do
                    if itemData.name == k and itemData.count >= amount then
                        count = count + 1
                    end
                end
                if count == #items then
                    return true
                end
            else
                if itemData.name == items and itemData.count > 0 then
                    return true
                end
            end
        end
        return false
    elseif Framework == 'qb' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if not PlayerData or not PlayerData.items then
            return false
        end
        local isTable = type(items) == 'table'
        local count = 0
        if isTable then
            for i = 1, #items do
                local itemName, itemAmount = items[i][1], items[i][2] or amount
                local foundItem = false
                for j = 1, #PlayerData.items do
                    local itemData = PlayerData.items[j]
                    if itemData and itemData.name == itemName and itemData.amount >= itemAmount then
                        foundItem = true
                        break
                    end
                end
                if not foundItem then
                    return false
                end
            end
            return true
        else
            for i = 1, #PlayerData.items do
                local itemData = PlayerData.items[i]
                if itemData and itemData.name == items and itemData.amount >= amount then
                    return true
                end
            end
            return false
        end
    else
        -- Add support for a custom framework here
    end
end