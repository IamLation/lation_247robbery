-- Display a notification
--- @param message string
--- @param type string
ShowNotification = function(message, type)
    if Config.Setup.notify == 'ox_lib' then
        lib.notify({ title = 'Convenience Store', description = message, type = type, position = 'top', icon = 'fas fa-store' })
    elseif Config.Setup.notify == 'esx' then
        ESX.ShowNotification(message)
    elseif Config.Setup.notify == 'qb' then
        QBCore.Functions.Notify(message, type)
    elseif Config.Setup.notify == 'okok' then
        exports['okokNotify']:Alert('Convenience Store', message, 5000, type, false)
    elseif Config.Setup.notify == 'sd-notify' then
        exports['sd-notify']:Notify('Convenience Store', message, type)
    elseif Config.Setup.notify == 'wasabi_notify' then
        exports.wasabi_notify:notify('Convenience Store', message, 5000, type, false, 'fas fa-store')
    elseif Config.Setup.notify == 'custom' then
        -- Add custom notification export/event here
    end
end

-- Display a notification from server
--- @param message string
--- @param type string
RegisterNetEvent('lation_247robbery:Notify', function(message, type)
    ShowNotification(message, type)
end)

-- Display a minigame
--- @param data table
Minigame = function(data)
    if lib.skillCheck(data.difficulty, data.inputs) then
        return true
    end
    return false
end

-- Display a progress bar
--- @param data table Config.Animations.X
ProgressBar = function(data)
    if Config.Setup.progress == 'ox_lib' then
        -- Want to use ox_lib's progress bar instead of circle?
        -- Change "progressCircle" to "progressBar" below & done!
        if lib.progressCircle({
            label = data.label,
            duration = data.duration,
            position = data.position or 'bottom',
            useWhileDead = data.useWhileDead,
            canCancel = data.canCancel,
            disable = data.disable,
            anim = {
                dict = data.anim.dict or nil,
                clip = data.anim.clip or nil,
                flag = data.anim.flag or nil
            },
            prop = {
                model = data.prop.model or nil,
                bone = data.prop.bone or nil,
                pos = data.prop.pos or nil,
                rot = data.prop.rot or nil
            }
        }) then
            return true
        end
        return false
    elseif Config.Setup.progress == 'qbcore' then
        local complete = false
        QBCore.Functions.Progressbar(data.label, data.label, data.duration, data.useWhileDead, data.canCancel, {
            disableMovement = data.disable.move,
            disableCarMovement = data.disable.car,
            disableMouse = false,
            disableCombat = data.disable.combat
        }, {
            animDict = data.anim.dict or nil,
            anim = data.anim.clip or nil,
            flags = data.anim.flag or nil
        }, {
            model = data.prop.model or nil,
            bone = data.prop.bone or nil,
            coords = data.prop.pos or nil,
            rotation = data.prop.rot or nil
        }, {},
        function()
            complete = true
        end,
        function()
            complete = false
        end)
        Wait(data.duration + 250)
        return complete
    else
        -- Add 'custom' progress bar here
    end
end

-- Function used for police dispatch systems
-- Can get coords & street name with data.coords & data.street if needed
--- @param data table
PoliceDispatch = function(data)
    if not data then print('Failed to retrieve dispatch data, cannot proceed.') return end
    if Config.Police.dispatch == 'cd_dispatch' then
        local playerData = exports['cd_dispatch']:GetPlayerInfo()
        if not playerData then
            print('cd_dispatch failed to return playerData, cannot proceed.')
            return
        end
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = Config.Police.jobs,
            coords = playerData.coords,
            title = '10-88 - Store Robbery',
            message = 'An alarm has been triggered at 24/7 on ' ..playerData.street,
            flash = 0,
            unique_id = playerData.unique_id,
            sound = 1,
            blip = {
                sprite = 52,
                scale = 1.0,
                colour = 1,
                flashes = false,
                text = '10-88 - Store Robbery',
                time = 5,
                radius = 0,
            }
        })
    elseif Config.Police.dispatch == 'ps-dispatch' then
        local alert = {
            coords = data.coords,
            message = 'An alarm has been triggered at 24/7 on ' ..data.street,
            dispatchCode = '10-88',
            description = 'Store Robbery',
            radius = 0,
            sprite = 52,
            color = 1,
            scale = 1.0,
            length = 3
        }
        exports["ps-dispatch"]:CustomAlert(alert)
    elseif Config.Police.dispatch == 'qs-dispatch' then
        local playerData = exports['qs-dispatch']:GetPlayerInfo()
        if not playerData then
            print('qs-dispatch failed to return playerData, cannot proceed.')
            return
        end
        exports['qs-dispatch']:getSSURL(function(image)
            TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
                job = Config.Police.jobs,
                callLocation = playerData.coords,
                callCode = { code = '10-88', snippet = 'Store Robbery' },
                message = 'An alarm has been triggered at 24/7 on ' ..playerData.street_1,
                flashes = false,
                image = image or nil,
                blip = {
                    sprite = 52,
                    scale = 1.0,
                    colour = 1,
                    flashes = false,
                    text = '10-88 - Store Robbery',
                    time = (30 * 1000),
                }
            })
        end)
    elseif Config.Police.dispatch == 'core_dispatch' then
        local gender = IsPedMale(cache.ped) and 'male' or 'female'
        TriggerServerEvent('core_dispatch:addCall', '10-88', 'Potential Store Robbery',
        {{icon = 'fa-venus-mars', info = gender}},
        {data.coords.x, data.coords.y, data.coords.z},
        'police', 30000, 52, 1, false)
    elseif Config.Police.dispatch == 'rcore_dispatch' then
        local playerData = exports['rcore_dispatch']:GetPlayerData()
        exports['screenshot-basic']:requestScreenshotUpload('InsertWebhookLinkHERE', "files[]", function(val)
            local image = json.decode(val)
            local alert = {
                code = '10-88 - Store Robbery',
                default_priority = 'low',
                coords = playerData.coords,
                job = Config.Police.jobs,
                text = 'An alarm has been triggered at 24/7 on ' ..playerData.street_1,
                type = 'alerts',
                blip_time = 30,
                image = image.attachments[1].proxy_url,
                blip = {
                    sprite = 52,
                    colour = 1,
                    scale = 1.0,
                    text = '10-88 - Store Robbery',
                    flashes = false,
                    radius = 0,
                }
            }
            TriggerServerEvent('rcore_dispatch:server:sendAlert', alert)
        end)
    elseif Config.Police.dispatch == 'aty_dispatch' then
        TriggerEvent('aty_dispatch:SendDispatch', 'Potential Store Robbery', '10-88', 52, Config.Police.jobs)
    elseif Config.Police.dispatch == 'op-dispatch' then
        local job = 'police'
        local text = 'An alarm has been triggered at 24/7 on ' ..data.street
        local coords = data.coords
        local id = cache.serverId
        local title = '10-88 - Store Robbery'
        local panic = false
        TriggerServerEvent('Opto_dispatch:Server:SendAlert', job, title, text, coords, panic, id)
    elseif Config.Police.dispatch == 'origen_police' then
        local alert = {
            coords = data.coords,
            title = '10-88 - Store Robbery',
            type = 'GENERAL',
            message = 'An alarm has been triggered at 24/7 on ' ..data.street,
            job = Config.Police.jobs,
        }
        TriggerServerEvent("SendAlert:police", alert)
    elseif Config.Police.dispatch == 'emergencydispatch' then
        TriggerServerEvent('emergencydispatch:emergencycall:new', Config.Police.jobs, '10-88 | Potential Store Robbery', data.coords, true)
    elseif Config.Police.dispatch == 'custom' then
        -- Add your custom dispatch system here
    else
        print('No dispatch system was identified - please update your Config.Police.dispatch')
    end
end

-- Function to add circle target zones
--- @param data table
AddCircleZone = function(data)
    if Config.Setup.interact == 'ox_target' then
        exports.ox_target:addSphereZone(data)
    elseif Config.Setup.interact == 'qb-target' then
        exports['qb-target']:AddCircleZone(data.name, data.coords, data.radius, {
            name = data.name,
            debugPoly = Config.Setup.debug}, {
            options = data.options,
            distance = 2,
        })
    elseif Config.Setup.interact == 'interact' then
        exports.interact:AddInteraction({
            coords = data.coords,
            interactDst = 2.0,
            id = data.name,
            options = data.options
        })
    elseif Config.Setup.interact == 'textui' then
        -- Coming soon..
    elseif Config.Setup.interact == 'custom' then
        -- Add support for a custom target system here
    else
        print('No interaction system defined in the config file.')
    end
end