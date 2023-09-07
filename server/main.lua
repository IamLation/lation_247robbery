GlobalState.registerCooldown = false
GlobalState.safeCooldown = false

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

-- Function that rewards the player upon a successful register robbery
lib.callback.register('lation_247robbery:registerSuccessful', function(source, verifyReward)
    local source = source
    local player = GetPlayer(source)
    local playerName = GetName(source)
    local playerId = player.source or player.PlayerData.source
    local distanceCheck = checkPlayerDistance(source)
    local rewardQuantity = nil
    if Config.RegisterRewardRandom then
        rewardQuantity = math.random(Config.RegisterRewardMinQuantity, Config.RegisterRewardMaxQuantity)
    else
        rewardQuantity = Config.RegisterRewardQuantity
    end
    if verifyReward == true then
        if distanceCheck then
            if Framework == 'qb' then
                local reward
                if Config.RegisterRewardItem == 'markedbills' then
                    reward = {worth = rewardQuantity}
                else
                    reward = rewardQuantity
                end
                AddItem(source, Config.RegisterRewardItem, reward)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Config.RegisterRewardItem], "add")
            else
                AddItem(source, Config.RegisterRewardItem, rewardQuantity)
            end
            registerCooldown()
            return true
        else
            -- Potential cheating?
            print('Player: ' ..playerName.. ' (ID: '..playerId..') has attempted to get rewarded for a register robbery despite not being within range of any 24/7.')
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
    local player = GetPlayer(source)
    local playerName = GetName(source)
    local playerId = player.source or player.PlayerData.source
    local distanceCheck = checkPlayerDistance(source)
    local rewardQuantity = nil
    if Config.SafeRewardRandom then
        rewardQuantity = math.random(Config.SafeRewardMinQuantity, Config.SafeRewardMaxQuantity)
    else
        rewardQuantity = Config.SafeRewardQuantity
    end
    if verifyReward then
        if distanceCheck then
            if Framework == 'qb' then
                local reward
                if Config.SafeRewardItem == 'markedbills' then
                    reward = {worth = rewardQuantity}
                else
                    reward = rewardQuantity
                end
                AddItem(source, Config.SafeRewardItem, reward)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Config.SafeRewardItem], "add")
            else
                AddItem(source, Config.SafeRewardItem, rewardQuantity)
            end
            safeCooldown()
            return true
        else
            -- Potential cheating?
            print('Player: ' ..playerName.. ' (ID: '..playerId..') has attempted to get rewarded for a safe robbery despite not being within range of any 24/7.')
            return false
        end
    else
        -- Potential cheating if verifyReward is false?
        print('Player: ' ..playerName.. ' (ID: '..playerId..') has attempted to get rewarded for a safe robbery despite verifyReward not being true')
        return false
    end
end)

-- Function that gets the passed item & quantity and removes it
RegisterNetEvent('lation_247robbery:removeItem')
AddEventHandler('lation_247robbery:removeItem', function(source, item, quantity)
    local source = source
    RemoveItem(source, item, quantity)
    if Framework == 'qb' then
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], "remove")
    end
end)

-- Callback used to get police count
lib.callback.register('lation_247robbery:getPoliceCount', function()
    local policeCount = PlayersWithJob(Config.PoliceJobs)
    return policeCount
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