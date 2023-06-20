local ox_inventory = exports.ox_inventory
GlobalState.registerCooldown = false
GlobalState.safeCooldown = false

-- Function that gets the total number of Police online and returns it
lib.callback.register('lation_247robbery:policeCount', function(policeCount)
    local policeCount = 0
    for _, player in pairs(ESX.GetExtendedPlayers()) do
    local job = player.getJob()
        for _, jobs in pairs(Config.PoliceJobs) do
            local jobNames = jobs
            if job.name == jobNames then 
                policeCount = policeCount + 1
            end
        end
    end
    return policeCount
end)

-- Function that rewards the player upon a successful register robbery
lib.callback.register('lation_247robbery:registerSuccessful', function()
    local source = source
    local ped = ESX.GetPlayerFromId(source)
    if Config.RegisterRewardRandom then
        local rewardQuantity = math.random(Config.RegisterRewardMinQuantity, Config.RegisterRewardMaxQuantity)
        ox_inventory:AddItem(ped.source, Config.RegisterRewardItem, rewardQuantity)
        -- Reward more/another item here, etc
    else
        ox_inventory:AddItem(ped.source, Config.RegisterRewardItem, Config.RegisterRewardQuantity)
        -- Reward more/another item here, etc
    end
    registerCooldown()
end)

-- Function that rewards the player upon a successful safe robbery
lib.callback.register('lation_247robbery:safeSuccessful', function()
    local source = source
    local ped = ESX.GetPlayerFromId(source)
    if Config.SafeRewardRandom then
        local rewardQuantity = math.random(Config.SafeRewardMinQuantity, Config.SafeRewardMaxQuantity)
        ox_inventory:AddItem(ped.source, Config.SafeRewardItem, rewardQuantity)
        -- Reward more/another item here, etc
    else
        ox_inventory:AddItem(ped.source, Config.SafeRewardItem, Config.SafeRewardQuantity)
        -- Reward more/another item here, etc
    end
    safeCooldown()
end)

-- Function that gets the passed item & quantity and removes it
lib.callback.register('lation_247robbery:removeItem', function(source, item, quantity)
    ox_inventory:RemoveItem(source, item, quantity)
end)

-- Function that handles the register cooldowns
function registerCooldown()
    GlobalState.registerCooldown = true
    local cooldown = math.random(Config.RegisterMinCooldown * 60000, Config.RegisterMaxCooldown * 60000)
    local format = cooldown / 1000 / 60
    print('24/7 register robbery cooldown now active for ' .. ESX.Math.Round(format) .. ' minutes')
    Wait(cooldown)
    print('24/7 register robbery cooldown now inactive')
    GlobalState.registerCooldown = false
end

-- Function that handles the safe cooldowns
function safeCooldown()
    GlobalState.safeCooldown = true
    local cooldown = math.random(Config.SafeMinCooldown * 60000, Config.SafeMaxCooldown * 60000)
    local format = cooldown / 1000 / 60
    print('24/7 safe robbery cooldown now active for ' .. ESX.Math.Round(format) .. ' minutes')
    Wait(cooldown)
    print('24/7 safe robbery cooldown now inactive')
    GlobalState.safeCooldown = false
end