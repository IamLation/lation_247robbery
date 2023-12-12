local libState = GetResourceState('ox_lib')

-- Function to show a notification
ShowNotification = function(message, type)
    if libState == 'started' then
        lib.notify({
            title = Strings.Notify.title,
            description = message,
            type = type or 'inform',
            position = Strings.Notify.position,
            icon = Strings.Notify.icon
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

-- Function used for police dispatch systems
PoliceDispatch = function(data)
    if Config.Dispatch == 'linden_outlawalert' then
        local d = {displayCode = '10-88', description = 'Store Robbery', isImportant = 0, recipientList = Config.PoliceJobs, length = '10000', infoM = 'fa-info-circle', info = 'An alarm has been triggered at 24/7'}
        local dispatchData = {dispatchData = d, caller = 'Citizen', coords = data.coords}
        TriggerServerEvent('wf-alerts:svNotify', dispatchData)
    elseif Config.Dispatch == 'cd_dispatch' then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = Config.PoliceJobs,
            coords = data.coords,
            title = '10-88 - Store Robbery',
            message = 'An alarm has been triggered at 24/7 on ' ..data.street,
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = 51,
                scale = 1.0,
                colour = 1,
                flashes = false,
                text = '10-88 | Store Robbery',
                time = 5,
                radius = 0,
            }
        })
    elseif Config.Dispatch == 'ps-dispatch' then
        exports['ps-dispatch']:StoreRobbery()
    elseif Config.Dispatch == 'qs-dispatch' then
        local playerData = exports['qs-dispatch']:GetPlayerInfo()
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = Config.PoliceJobs,
            callLocation = playerData.coords,
            callCode = { code = '10-88', snippet = 'Store Robbery' },
            message = 'An alarm has been triggered at 24/7 on ' ..playerData.street_1,
            flashes = false,
            image = nil,
            blip = {
                sprite = 488,
                scale = 1.5,
                colour = 1,
                flashes = true,
                text = 'Store Robbery',
                time = (6 * 60 * 1000),
            }
        })
    elseif Config.Dispatch == 'custom' then
        -- Add your custom dispatch system here
    else
        -- No dispatch system was found
        print('No dispatch system was identified - please update your Config.Dispatch')
    end
end

-- Function to add circle target zones
AddCircleZone = function(data)
    if Config.Target == 'ox_target' then
        exports.ox_target:addSphereZone(data)
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:AddCircleZone(data.name, data.coords, data.radius, {
            name = data.name,
            debugPoly = Config.Debug}, {
            options = data.options,
            distance = 2,
        })
    elseif Config.Target == 'qtarget' then
        exports.qtarget:AddCircleZone(data.name, data.coords, data.radius, {
            name = data.name,
            debugPoly = Config.Debug}, {
            options = data.options,
            distance = 2,
        })
    elseif Config.Target == 'custom' then
        -- Add support for a custom target system here
    else
        print('No target system defined in the config file.')
    end
end