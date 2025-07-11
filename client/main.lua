-- Initialize config(s)
local shared = require 'config.shared'
local client = require 'config.client'
local icons = require 'config.icons'

-- Initialize variables to track active locations
local activeRegister, activeComputer, activeSafe = false, false, false

-- Initialize variables to store code & pin
local safePin

-- Initialize variables to track failed attempts
local wrongPIN, failedHack = 0, 0

-- Initialize table to build questionnaire if applicable
local questionData = {}

-- Build the input dialog for questionnaire if applicable
if shared.computers.questionnaire then
    for _, question in ipairs(shared.questionnaire.questions) do
        questionData[#questionData + 1] = {
            type = question.type,
            label = question.label,
            description = question.description,
            icon = question.icon,
            required = question.required
        }
        if question.type == 'select' then
            questionData[#questionData].options = question.options
        end
    end
end

-- Used to check if the answers submitted are correct
--- @param answers table
local function AreAnswersCorrect(answers)
    for question, answer in ipairs(shared.questionnaire.answers) do
        local submitted_answer = answers[question]
        if shared.questionnaire.questions[question].type == 'select' then
            if tonumber(submitted_answer) ~= answer then
                return false
            end
        else
            if string.lower(submitted_answer) ~= string.lower(answer) then
                return false
            end
        end
    end
    return true
end

-- Function to start the initial robbery process
local function InitiateRegisterRobbery()
    local canStart = lib.callback.await('lation_247robbery:StartRobbery', false)
    if not canStart then activeRegister = false return end
    local dict, anim = client.anims.lockpick.dict, client.anims.lockpick.clip
    lib.requestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 51, 1.0, false, false, false)
    local skillcheck = Minigame(shared.registers.minigame)
    ClearPedTasks(cache.ped)
    if not skillcheck then
        TriggerServerEvent('lation_247robbery:DoesLockpickBreak')
        activeRegister = false
        return
    end
    local coords = GetEntityCoords(cache.ped)
    local data = {
        coords = coords,
        street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    }
    PoliceDispatch(data)
    if ProgressBar(client.anims.register) then
        local codeChance = math.random(100)
        if codeChance <= shared.registers.noteChance then
            local generatedCode = math.random(1111, 9999)
            if safePin then safePin = nil end
            safePin = generatedCode
            local note = ShowAlert({
                header = locale('alerts.note.header'),
                content = locale('alerts.note.content', safePin),
                icon = icons.received_pin,
                centered = true,
                cancel = false,
            })
            if note == 'confirm' then
                activeSafe = true
                TriggerServerEvent('lation_247robbery:CompleteRegisterRobbery')
            end
        else
            activeComputer = true
            TriggerServerEvent('lation_247robbery:CompleteRegisterRobbery')
        end
    else
        activeRegister = false
        ShowNotification(locale('notify.cancel-rob'), 'error')
    end
end

-- Function to handle hacking the computer if required
local function InitiateComputerHack()
    activeComputer = false -- Deactive target
    if failedHack >= shared.computers.maxAttempts then
        activeRegister = false
        activeComputer = false
        failedHack = 0
        ShowNotification(locale('notify.failed-limit'), 'error')
        TriggerServerEvent('lation_247robbery:FailedRobbery')
        return
    end
    local dict, anim = client.anims.hackPC.dict, client.anims.hackPC.clip
    lib.requestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 1, 1, false, false, false)
    if shared.computers.questionnaire then
        local questions = ShowInput({ title = locale('inputs.questions.header'), options = questionData })
        if not questions then
            activeComputer = true
            ClearPedTasks(cache.ped)
            return
        end
        if AreAnswersCorrect(questions) then
            failedHack = 0
            ClearPedTasks(cache.ped)
            local generatedCode = math.random(1111, 9999)
            if safePin then safePin = nil end
            safePin = generatedCode
            ShowAlert({
                header = locale('alerts.hack.header'),
                content = locale('alerts.hack.content', safePin),
                icon = icons.received_pin,
                centered = true,
                cancel = false
            })
            activeSafe = true
        else
            ClearPedTasks(cache.ped)
            activeComputer = true
            failedHack = failedHack + 1
            ShowNotification(locale('notify.failed-hack'), 'error')
        end
    else
        local skillcheck = Minigame(shared.computers.minigame)
        if not skillcheck then
            ClearPedTasks(cache.ped)
            activeComputer = true
            failedHack = failedHack + 1
            ShowNotification(locale('notify.failed-hack'), 'error')
            return
        end
        failedHack = 0
        ClearPedTasks(cache.ped)
        local generatedCode = math.random(1111, 9999)
        if safePin then safePin = nil end
        safePin = generatedCode
        ShowAlert({
            header = locale('alerts.hack.header'),
            content = locale('alerts.hack.content', safePin),
            icon = icons.received_pin,
            centered = true,
            cancel = false
        })
        activeSafe = true
    end
end

-- Function to handle the safe robbery
local function InitiateSafeRobbery()
    activeSafe = false
    if wrongPIN >= shared.safes.maxAttempts then
        activeRegister = false
        activeSafe = false
        wrongPIN = 0
        ShowNotification(locale('notify.failed-limit'), 'error')
        TriggerServerEvent('lation_247robbery:FailedRobbery')
        return
    end
    local inputCode = ShowInput({
        title = locale('inputs.safe.header'),
        options = {
            {
                type = 'input',
                label = locale('inputs.safe.label'),
                description = locale('inputs.safe.desc'),
                placeholder = locale('inputs.safe.placeholder'),
                icon = icons.safe_pin,
                required = true
            }
        }
    })
    if not inputCode then activeSafe = true return end
    local convertedCode = tonumber(inputCode[1])
    if convertedCode ~= safePin then
        wrongPIN = wrongPIN + 1
        activeSafe = true
        ShowNotification(locale('notify.wrong-pin'), 'error')
    elseif convertedCode == safePin then
        activeSafe = false
        wrongPIN = 0
        if ProgressBar(client.anims.safe) then
            activeRegister = false
            TriggerServerEvent('lation_247robbery:CompleteSafeRobbery')
            safePin = nil
        else
            activeSafe = true
        end
    end
end

-- Create interactions
AddEventHandler('lation_247robbery:onPlayerLoaded', function()
    local gabz = GetResourceState('cfx-gabz-247') == 'started'
    local fm = GetResourceState('cfx-fm-supermarkets') == 'started'
    local coords = gabz and require 'data.gabz' or fm and require 'data.fmshop' or require 'data.default'
    for key, coord in pairs(coords.registers) do
        local data = {
            name = 'cash_register' ..key,
            coords = coord,
            radius = 0.35,
            debug = shared.setup.debug,
            options = {
                {
                    label = locale('target.register'),
                    icon = icons.register,
                    iconColor = icons.register_color,
                    canInteract = function()
                        if not activeRegister then
                            return true
                        end
                        return false
                    end,
                    action = function()
                        activeRegister = true
                        InitiateRegisterRobbery()
                    end,
                    onSelect = function()
                        activeRegister = true
                        InitiateRegisterRobbery()
                    end,
                    distance = 2
                }
            }
        }
        AddCircleZone(data)
    end
    for key, coord in pairs(coords.computers) do
        local data = {
            name = 'computer' ..key,
            coords = coord,
            radius = 0.35,
            debug = shared.setup.debug,
            options = {
                {
                    label = locale('target.computer'),
                    icon = icons.computer,
                    iconColor = icons.computer_color,
                    canInteract = function()
                        if activeComputer then
                            return true
                        end
                        return false
                    end,
                    action = InitiateComputerHack,
                    onSelect = InitiateComputerHack,
                    distance = 2
                }
            }
        }
        AddCircleZone(data)
    end
    for key, coord in pairs(coords.safes) do
        local data = {
            name = 'safe' ..key,
            coords = coord,
            radius = 0.45,
            debug = shared.setup.debug,
            options = {
                {
                    label = locale('target.safe'),
                    icon = icons.safe,
                    iconColor = icons.safe_color,
                    canInteract = function()
                        if activeSafe then
                            return true
                        end
                        return false
                    end,
                    action = InitiateSafeRobbery,
                    onSelect = InitiateSafeRobbery,
                    distance = 2
                }
            }
        }
        AddCircleZone(data)
    end
end)