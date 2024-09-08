-- Initialize variables to track active locations
local activeRegister, activeComputer, activeSafe = false, false, false

-- Initialize variables to store code & pin
local safePin

-- Initialize variables to track failed attempts
local wrongPIN, failedHack = 1, 1

-- Initialize table to build questionnaire if applicable
local questionData = {}

-- Build the input dialog for questionnaire if applicable
if Config.Computers.questionnaire then
    for _, question in ipairs(Config.Questionnaire.questions) do
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
--- @param submittedAnswers table
local AreAnswersCorrect = function(submittedAnswers)
    for questionIndex, correctAnswer in ipairs(Config.Questionnaire.answers) do
        local submittedAnswer = submittedAnswers[questionIndex]
        if Config.Questionnaire.questions[questionIndex].type == 'select' then
            if tonumber(submittedAnswer) ~= correctAnswer then
                return false
            end
        else
            if string.lower(submittedAnswer) ~= string.lower(correctAnswer) then
                return false
            end
        end
    end
    return true
end

-- Function to start the initial robbery process
local InitiateRegisterRobbery = function()
    local canStart = lib.callback.await('lation_247robbery:StartRobbery', false)
    if not canStart then activeRegister = false return end
    local dict, anim = Config.Animations.lockpick.animDict, Config.Animations.lockpick.animClip
    lib.requestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 51, 1.0, false, false, false)
    local skillcheck = Minigame(Config.Registers.minigame)
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
    if ProgressBar(Config.Animations.register) then
        local codeChance = math.random(100)
        if codeChance <= Config.Registers.noteChance then
            local alert = Strings.AlertDialog.noteFound
            local generatedCode = math.random(1111, 9999)
            if safePin then safePin = nil end
            safePin = generatedCode
            local note = lib.alertDialog({
                header = alert.header,
                content = string.format(alert.content, tostring(safePin)),
                centered = true,
                cancel = false,
                labels = { confirm = alert.labels.confirm }
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
        ShowNotification(Strings.Notify.robberyCancel, 'error')
    end
end

-- Function to handle hacking the computer if required
local InitiateComputerHack = function()
    activeComputer = false -- Deactive target
    if failedHack > Config.Computers.maxAttempts then
        activeRegister = false
        activeComputer = false
        failedHack = 0
        ShowNotification(Strings.Notify.tooManyHackFails, 'error')
        return
    end
    local dict, anim = Config.Animations.hackPC.animDict, Config.Animations.hackPC.animClip
    lib.requestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 1, 1, false, false, false)
    if Config.Computers.questionnaire then
        local questions = lib.inputDialog(Strings.InputDialog.questionsHeader, questionData)
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
            local alert = Strings.AlertDialog.hacked
            lib.alertDialog({
                header = alert.header,
                content = string.format(alert.content, tostring(safePin)),
                centered = true,
                cancel = false,
                labels = { confirm = alert.labels.confirm }
            })
            activeSafe = true
        else
            ClearPedTasks(cache.ped)
            activeComputer = true
            failedHack = failedHack + 1
            ShowNotification(Strings.Notify.failedHack, 'error')
        end
    else
        local skillcheck = Minigame(Config.Computers.minigame)
        if not skillcheck then
            ClearPedTasks(cache.ped)
            activeComputer = true
            failedHack = failedHack + 1
            ShowNotification(Strings.Notify.failedHack, 'error')
            return
        end
        failedHack = 0
        ClearPedTasks(cache.ped)
        local generatedCode = math.random(1111, 9999)
        if safePin then safePin = nil end
        safePin = generatedCode
        local alert = Strings.AlertDialog.hacked
        lib.alertDialog({
            header = alert.header,
            content = string.format(alert.content, tostring(safePin)),
            centered = true,
            cancel = false,
            labels = { confirm = alert.labels.confirm }
        })
        activeSafe = true
    end
end

-- Function to handle the safe robbery
local InitiateSafeRobbery = function()
    activeSafe = false
    if wrongPIN > Config.Safes.maxAttempts then
        activeRegister = false
        activeSafe = false
        wrongPIN = 0
        ShowNotification(Strings.Notify.tooManySafeFails, 'error')
        return
    end
    local inputCode = lib.inputDialog(Strings.InputDialog.safeHeader, {Strings.InputDialog.safe})
    if not inputCode then activeSafe = true return end
    local convertedCode = tonumber(inputCode[1])
    if convertedCode ~= safePin then
        wrongPIN = wrongPIN + 1
        activeSafe = true
        ShowNotification(Strings.Notify.wrongPin, 'error')
    elseif convertedCode == safePin then
        activeSafe = false
        wrongPIN = 0
        if ProgressBar(Config.Animations.safe) then
            activeRegister = false
            TriggerServerEvent('lation_247robbery:CompleteSafeRobbery')
            safePin = nil
        else
            activeSafe = true
        end
    end
end

-- Create all the targets for the cash registers
for key, coords in pairs(Config.Locations.Registers) do
    local data = {
        name = 'cash_register' ..key,
        coords = coords,
        radius = 0.35,
        debug = Config.Setup.debug,
        options = {
            {
                icon = Strings.Target.registers.icon,
                label = Strings.Target.registers.label,
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

-- Creates all the targets for the computers
for key, coords in pairs(Config.Locations.Computers) do
    local data = {
        name = 'computer' ..key,
        coords = coords,
        radius = 0.35,
        debug = Config.Setup.debug,
        options = {
            {
                icon = Strings.Target.computers.icon,
                label = Strings.Target.computers.label,
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

-- Creates all the targets for the safes
for key, coords in pairs(Config.Locations.Safes) do
    local data = {
        name = 'safe' ..key,
        coords = coords,
        radius = 0.45,
        debug = Config.Setup.debug,
        options = {
            {
                icon = Strings.Target.safes.icon,
                label = Strings.Target.safes.label,
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