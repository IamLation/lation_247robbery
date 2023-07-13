local ox_inventory = exports.ox_inventory
GlobalState.registerCooldown = false
GlobalState.safeCooldown = false

if Config.Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
else
    -- Custom framework
end

-- Function to check the players distance to registers/safes/etc
local function checkPlayerDistance(source)
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

-- Function that gets the total number of Police online and returns it
lib.callback.register('lation_247robbery:policeCount', function(source)
    local policeCount = 0
    if Config.Framework == 'esx' then
        for _, player in pairs(ESX.GetExtendedPlayers()) do
            local job = player.getJob()
            for _, jobs in pairs(Config.PoliceJobs) do
                local jobNames = jobs
                if job.name == jobNames then
                    policeCount = policeCount + 1
                end
            end
        end
    elseif Config.Framework == 'qbcore' then
        for _, players in pairs(QBCore.Functions.GetPlayers()) do
            local player = QBCore.Functions.GetPlayer(players)
            local job = player.PlayerData.job
            for _, jobs in pairs(Config.PoliceJobs) do
                local jobNames = jobs
                if job.name == jobNames then
                    policeCount = policeCount + 1
                end
            end
        end
    else
        -- Custom framework
    end
    return policeCount
end)

-- Function that rewards the player upon a successful register robbery
lib.callback.register('lation_247robbery:registerSuccessful', function(source, verifyReward)
    local source = source
    local playerName = GetPlayerName(source)
    local distanceCheck = checkPlayerDistance(source)
    local rewardQuantity = math.random(Config.RegisterRewardMinQuantity, Config.RegisterRewardMaxQuantity)
    if verifyReward == true then
        if distanceCheck then
            if Config.Framework == 'esx' then
                local player = ESX.GetPlayerFromId(source)
                if Config.RegisterRewardRandom then
                    player.addInventoryItem(Config.RegisterRewardItem, rewardQuantity)
                else
                    player.addInventoryItem(Config.RegisterRewardItem, Config.RegisterRewardQuantity)
                end
            elseif Config.Framework == 'qbcore' then
                local Player = QBCore.Functions.GetPlayer(source)
                if Config.RegisterRewardRandom then
                    local reward = {
                        worth = rewardQuantity
                    }
                    Player.Functions.AddItem(Config.RegisterRewardItem, 1, false, reward)
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Config.RegisterRewardItem], "add")
                else
                    local reward = {
                        worth = Config.RegisterRewardQuantity
                    }
                    Player.Functions.AddItem(Config.RegisterRewardItem, 1, false, reward)
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Config.RegisterRewardItem], "add")
                end
            else
                -- Custom framework/standalone
                if Config.RegisterRewardRandom then
                    ox_inventory:AddItem(source, Config.RegisterRewardItem, rewardQuantity)
                else
                    ox_inventory:AddItem(source, Config.RegisterRewardItem, Config.RegisterRewardQuantity)
                end
            end
            registerCooldown()
            return true
        else
            -- Potential cheating if player is not nearby any of the store coords
            print('Player: ' ..playerName.. ' (ID: '..source..') has attempted to get rewarded for a register robbery despite not being within range of any 24/7.')
            return false
        end
    else
        -- Potential cheating if verifyReward is false?
        print('Player: ' ..playerName.. ' (ID: '..source..') has attempted to get rewarded for a register robbery despite verifyReward not being true')
        return false
    end
end)

-- Function that rewards the player upon a successful safe robbery
lib.callback.register('lation_247robbery:safeSuccessful', function(source, verifyReward)
    local source = source
    local playerName = GetPlayerName(source)
    local distanceCheck = checkPlayerDistance(source)
    local rewardQuantity = math.random(Config.SafeRewardMinQuantity, Config.SafeRewardMaxQuantity)
    if verifyReward == true then
        if distanceCheck then
            if Config.Framework == 'esx' then
                local player = ESX.GetPlayerFromId(source)
                if Config.SafeRewardRandom then
                    player.addInventoryItem(Config.SafeRewardItem, rewardQuantity)
                    safeCooldown()
                    return true
                else
                    player.addInventoryItem(Config.SafeRewardItem, Config.SafeRewardQuantity)
                    safeCooldown()
                    return true
                end
            elseif Config.Framework == 'qbcore' then
                local player = QBCore.Functions.GetPlayer(source)
                if Config.SafeRewardRandom then
                    local reward = {
                        worth = rewardQuantity
                    }
                    player.Functions.AddItem(Config.SafeRewardItem, 1, false, reward)
                    safeCooldown()
                    return true
                else
                    local reward = {
                        worth = Config.SafeRewardQuantity
                    }
                    player.Functions.AddItem(Config.SafeRewardItem, 1, false, reward)
                    safeCooldown()
                    return true
                end
            else
                -- Custom framework/standalone
                if Config.SafeRewardRandom then
                    ox_inventory:AddItem(source, Config.SafeRewardItem, rewardQuantity)
                    safeCooldown()
                    return true
                else
                    ox_inventory:AddItem(source, Config.SafeRewardItem, Config.SafeRewardQuantity)
                    safeCooldown()
                    return true
                end
            end
        else
            -- Potential cheating if player is not nearby any of the store coords
            print('Player: ' ..playerName.. ' (ID: '..source..') has attempted to get rewarded for a safe robbery despite not being within range of any 24/7.')
            return false
        end
    else
        -- Potential cheating if verifyReward is false?
        print('Player: ' ..playerName.. ' (ID: '..source..') has attempted to get rewarded for a safe robbery despite verifyReward not being true')
        return false
    end
end)

-- Function that gets the passed item & quantity and removes it
lib.callback.register('lation_247robbery:removeItem', function(source, item, quantity)
    local source = source
    if Config.Framework == 'esx' then
        local player = ESX.GetPlayerFromId(source)
        player.removeInventoryItem(item, quantity)
    elseif Config.Framework == 'qbcore' then
        local player = QBCore.Functions.GetPlayer(source)
        player.Functions.RemoveItem(item, quantity)
    else
        -- Custom framework/standalone
        ox_inventory:RemoveItem(source, item, quantity)
    end
end)

-- Function that handles the register cooldowns
function registerCooldown()
    GlobalState.registerCooldown = true
    local cooldown = math.random(Config.RegisterMinCooldown * 60000, Config.RegisterMaxCooldown * 60000)
    local format = cooldown / 1000 / 60
    local cooldownRound = math.floor(format)
    print('24/7 register robbery cooldown now active for ' .. cooldownRound .. ' minutes')
    Wait(cooldown)
    print('24/7 register robbery cooldown now inactive')
    GlobalState.registerCooldown = false
end

-- Function that handles the safe cooldowns
function safeCooldown()
    GlobalState.safeCooldown = true
    local cooldown = math.random(Config.SafeMinCooldown * 60000, Config.SafeMaxCooldown * 60000)
    local format = cooldown / 1000 / 60
    local cooldownRound = math.floor(format)
    print('24/7 safe robbery cooldown now active for ' .. cooldownRound .. ' minutes')
    Wait(cooldown)
    print('24/7 safe robbery cooldown now inactive')
    GlobalState.safeCooldown = false
end