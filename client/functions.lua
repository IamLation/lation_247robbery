-- Initialize config(s)
local sh_config = require 'config.shared'

-- Display a notification
--- @param message string
--- @param type string
function ShowNotification(message, type)
    if sh_config.setup.notify == 'ox_lib' then
        lib.notify({ description = message, type = type, position = 'top', icon = 'fas fa-store' })
    elseif sh_config.setup.notify == 'esx' then
        ESX.ShowNotification(message)
    elseif sh_config.setup.notify == 'qb' then
        QBCore.Functions.Notify(message, type)
    elseif sh_config.setup.notify == 'okok' then
        exports['okokNotify']:Alert('Convenience Store', message, 5000, type, false)
    elseif sh_config.setup.notify == 'sd-notify' then
        exports['sd-notify']:Notify('Convenience Store', message, type)
    elseif sh_config.setup.notify == 'wasabi_notify' then
        exports.wasabi_notify:notify('Convenience Store', message, 5000, type, false, 'fas fa-store')
    elseif sh_config.setup.notify == 'custom' then
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
function Minigame(data)
    if lib.skillCheck(data.difficulty, data.inputs) then
        return true
    end
    return false
end

-- Display a progress bar
--- @param data table
function ProgressBar(data)
    if sh_config.setup.progress == 'ox_lib' then
        -- Want to use ox_lib's progress circle instead of bar?
        -- Change "progressBar" to "progressCircle" below & done!
        if lib.progressBar({
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
    elseif sh_config.setup.progress == 'qbcore' then
        local p = promise.new()
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
            p:resolve(true)
        end,
        function()
            p:resolve(false)
        end)
        return Citizen.Await(p)
    else
        -- Add 'custom' progress bar here
    end
end

-- Send police dispatch message
--- @param data table data.coords, data.street
function PoliceDispatch(data)
    if not data then print('^1[ERROR]: Failed to retrieve dispatch data, cannot proceed^0') return end
    if sh_config.police.dispatch == 'cd_dispatch' then
        local playerData = exports['cd_dispatch']:GetPlayerInfo()
        if not playerData then
            print('^1[ERROR]: cd_dispatch failed to return playerData, cannot proceed^0')
            return
        end
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = sh_config.police.jobs,
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
    elseif sh_config.police.dispatch == 'ps-dispatch' then
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
    elseif sh_config.police.dispatch == 'qs-dispatch' then
        local playerData = exports['qs-dispatch']:GetPlayerInfo()
        if not playerData then
            print('^1[ERROR]: qs-dispatch failed to return playerData, cannot proceed^0')
            return
        end
        exports['qs-dispatch']:getSSURL(function(image)
            TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
                job = sh_config.police.jobs,
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
    elseif sh_config.police.dispatch == 'core_dispatch' then
        local gender = IsPedMale(cache.ped) and 'male' or 'female'
        TriggerServerEvent('core_dispatch:addCall', '10-88', 'Potential Store Robbery',
        {{icon = 'fa-venus-mars', info = gender}},
        {data.coords.x, data.coords.y, data.coords.z},
        'police', 30000, 52, 1, false)
    elseif sh_config.police.dispatch == 'rcore_dispatch' then
        local playerData = exports['rcore_dispatch']:GetPlayerData()
        if not playerData then
            print('^1[ERROR]: rcore_dispatch failed to return playerData, cannot proceed^0')
            return
        end
        local alert = {
            code = '10-88 - Store Robbery',
            default_priority = 'low',
            coords = playerData.coords,
            job = sh_config.police.jobs,
            text = 'An alarm has been triggered at 24/7 on ' ..playerData.street_1,
            type = 'alerts',
            blip_time = 30,
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
    elseif sh_config.police.dispatch == 'aty_dispatch' then
        TriggerEvent('aty_dispatch:SendDispatch', 'Potential Store Robbery', '10-88', 52, sh_config.police.jobs)
    elseif sh_config.police.dispatch == 'op-dispatch' then
        local job = 'police'
        local text = 'An alarm has been triggered at 24/7 on ' ..data.street
        local coords = data.coords
        local id = cache.serverId
        local title = '10-88 - Store Robbery'
        local panic = false
        TriggerServerEvent('Opto_dispatch:Server:SendAlert', job, title, text, coords, panic, id)
    elseif sh_config.police.dispatch == 'origen_police' then
        local alert = {
            coords = data.coords,
            title = '10-88 - Store Robbery',
            type = 'GENERAL',
            message = 'An alarm has been triggered at 24/7 on ' ..data.street,
            job = 'police',
        }
        TriggerServerEvent("SendAlert:police", alert)
    elseif sh_config.police.dispatch == 'emergencydispatch' then
        TriggerServerEvent('emergencydispatch:emergencycall:new', 'police', '10-88 | Potential Store Robbery', data.coords, true)
    elseif sh_config.police.dispatch == 'custom' then
        -- Add your custom dispatch system here
    else
        print('^1[ERROR]: No dispatch system was detected - please visit config/shared.lua "police" section^0')
    end
end

-- Add circle target zones
--- @param data table
function AddCircleZone(data)
    if sh_config.setup.interact == 'ox_target' then
        exports.ox_target:addSphereZone(data)
    elseif sh_config.setup.interact == 'qb-target' then
        exports['qb-target']:AddCircleZone(data.name, data.coords, data.radius, {
            name = data.name,
            debugPoly = sh_config.setup.debug}, {
            options = data.options,
            distance = 2,
        })
    elseif sh_config.setup.interact == 'interact' then
        exports.interact:AddInteraction({
            coords = data.coords,
            interactDst = 2.0,
            id = data.name,
            options = data.options
        })
    elseif sh_config.setup.interact == 'custom' then
        -- Add support for a custom target system here
    else
        print('^1[ERROR]: No interaction system was detected - please visit config/shared "setup" section^0')
    end
end