-- Function to show a notification
--- @param message string
--- @param type string
ShowNotification = function(message, type)
    if Config.Notify == 'ox_lib' then
        lib.notify({ title = 'Convenience Store', description = message, type = type, position = 'top', icon = 'fas fa-store' })
    elseif Config.Notify == 'esx' then
        ESX.ShowNotification(message)
    elseif Config.Notify == 'qb' then
        QBCore.Functions.Notify(message, type)
    elseif Config.Notify == 'okok' then
        exports['okokNotify']:Alert('Convenience Store', message, 5000, type, false)
    elseif Config.Notify == 'sd-notify' then
        exports['sd-notify']:Notify('Convenience Store', message, type)
    elseif Config.Notify == 'custom' then
        -- Add custom notification export/event here
    end
end

-- Function used to handle register & computer hack minigame
--- @param data table
Minigame = function(data)
    if lib.skillCheck(data.difficulty, data.inputs) then
        return true
    end
    return false
end

-- Function used for police dispatch systems
--- @param data table data.coords & data.street
PoliceDispatch = function(data)
    if Config.Police.dispatch == 'linden_outlawalert' then
        local d = {displayCode = '10-88', description = 'Store Robbery', isImportant = 0, recipientList = Config.Police.jobs, length = '10000', infoM = 'fa-info-circle', info = 'An alarm has been triggered at 24/7'}
        local dispatchData = {dispatchData = d, caller = 'Citizen', coords = data.coords}
        TriggerServerEvent('wf-alerts:svNotify', dispatchData)
    elseif Config.Police.dispatch == 'cd_dispatch' then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = Config.Police.jobs,
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
    elseif Config.Police.dispatch == 'ps-dispatch' then
        exports['ps-dispatch']:StoreRobbery()
    elseif Config.Police.dispatch == 'qs-dispatch' then
        local playerData = exports['qs-dispatch']:GetPlayerInfo()
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = Config.Police.jobs,
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
    elseif Config.Police.dispatch == 'custom' then
        -- Add your custom dispatch system here
    else
        -- No dispatch system was found
        print('No dispatch system was identified - please update your Config.Police.dispatch')
    end
end

-- Function to add circle target zones
--- @param data table
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