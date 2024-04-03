-- Initialize variable to store progressType
local progressType = Config.ProgressType == 'bar' and 'progressBar' or 'progressCircle'

-- Initialize variables to track active locations
local activeRegister, activeComputer, activeSafe = false, false, false

-- Initialize variables to store code & pin
local generatedCode, safePin = nil, nil

-- Initialize variables to track failed attempts
local wrongPIN, failedHack = 0, 0

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

-- Function to check if player has required item & enough police (if applicable)
local CheckConditions = function()
    local hasItem = HasItem(Config.Registers.item, 1)
    if hasItem then
        if Config.Police.require then
            local policeCount = lib.callback.await('lation_247robbery:getPoliceCount', false)
            if policeCount >= Config.Police.count then
                return true
            end
            activeRegister = false
            ShowNotification(Strings.Notify.notEnoughPolice, 'error')
            return false
        end
        return true
    end
    activeRegister = false
    ShowNotification(Strings.Notify.missingItem, 'error')
    return false
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
    if not CheckConditions() then return end
    -- Collect data for dispatch
    local coords = GetEntityCoords(cache.ped)
    local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    local data = {coords = coords, street = streetName}
    local cooldown = GlobalState.registerCooldown
    -- Check cooldown status
    if cooldown then
        ShowNotification(Strings.Notify.registerCooldown, 'error')
        activeRegister = false
        return
    end
    -- Begin lockpicking emote
    local dict, anim = Config.Animations.lockpick.animDict, Config.Animations.lockpick.animClip
    lib.requestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 51, 1.0, false, false, false)
    -- Start skillcheck
    local skillcheckData = { difficulty = Config.Registers.difficulty, inputs = Config.Registers.inputs }
    local skillcheck = Minigame(skillcheckData)
    ClearPedTasks(cache.ped)
    if not skillcheck then
        -- Failed skillcheck - potential lockpick breaking
        local breakChance = math.random(1, 100)
        if breakChance <= Config.Registers.breakChange then
            TriggerServerEvent('lation_247robbery:BreakLockpick', cache.serverId)
            ShowNotification(Strings.Notify.lockpickBroke, 'error')
        end
        activeRegister = false
        return
    end
    -- Alert police
    PoliceDispatch(data)
    if lib[progressType](Config.Animations.register) then
        -- Check if they got the code to skip computer hack
        local codeChance = math.random(1, 100)
        if codeChance <= Config.Registers.noteChance then
            generatedCode = math.random(1111, 9999)
            safePin = generatedCode
            local note = lib.alertDialog({
                header = Strings.AlertDialog.noteFound.header,
                content = Strings.AlertDialog.noteFound.content ..generatedCode,
                centered = true,
                cancel = false,
                labels = Strings.AlertDialog.noteFound.labels
            })
            if note == 'confirm' then
                activeSafe = true
                TriggerServerEvent('lation_247robbery:RewardRobbery', cache.serverId, 'register')
            end
        else
            -- No code, proceed with normal robbery
            activeComputer = true
            TriggerServerEvent('lation_247robbery:RewardRobbery', cache.serverId, 'register')
        end
    else
        -- Player cancelled robbery
        activeRegister = false
        ShowNotification(Strings.Notify.robberyCancel, 'error')
    end
end

-- Function to handle hacking the computer if required
local InitiateComputerHack = function()
    activeComputer = false -- Deactive target
    if failedHack > Config.Computers.maxAttempts then
        -- Too many failed attempts
        activeRegister = false
        activeComputer = false
        failedHack = 0
        ShowNotification(Strings.Notify.tooManyHackFails, 'error')
        return
    end
    -- Load and play anim during hacking
    local dict, anim = Config.Animations.hackPC.animDict, Config.Animations.hackPC.animClip
    lib.requestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 1, 1, false, false, false)
    -- If questionnaire enabled, then proceed
    if Config.Computers.questionnaire then
        local questions = lib.inputDialog(Strings.InputDialog.questionsHeader, questionData)
        if not questions then -- No answers or nil, reset & return
            activeComputer = true
            ClearPedTasks(cache.ped)
            return
        end
        if AreAnswersCorrect(questions) then
            -- Player passed, continue
            failedHack = 0
            ClearPedTasks(cache.ped)
            generatedCode = math.random(1111, 9999)
            safePin = generatedCode
            lib.alertDialog({
                header = Strings.AlertDialog.hacked.header,
                content = Strings.AlertDialog.hacked.content ..generatedCode,
                centered = true,
                cancel = false,
                labels = Strings.AlertDialog.hacked.labels
            })
            activeSafe = true
        else
            -- Player failed, reset and track fail
            ClearPedTasks(cache.ped)
            activeComputer = true
            failedHack = failedHack + 1
            ShowNotification(Strings.Notify.failedHack, 'error')
        end
    else
        -- Questionnaire disabled, use skillCheck
        local skillcheckData = { difficulty = Config.Computers.difficulty, inputs = Config.Computers.inputs }
        local skillcheck = Minigame(skillcheckData)
        if not skillcheck then
            -- Player failed
            ClearPedTasks(cache.ped)
            activeComputer = true
            failedHack = failedHack + 1
            ShowNotification(Strings.Notify.failedHack, 'error')
            return
        end
        -- Player passed
        failedHack = 0
        ClearPedTasks(cache.ped)
        generatedCode = math.random(1111, 9999)
        safePin = generatedCode
        lib.alertDialog({
            header = Strings.AlertDialog.hacked.header,
            content = Strings.AlertDialog.hacked.content ..generatedCode,
            centered = true,
            cancel = false,
            labels = Strings.AlertDialog.hacked.labels
        })
        activeSafe = true
    end
end

-- Function to handle the safe robbery
local InitiateSafeRobbery = function()
    activeSafe = false -- Disable target option
    if wrongPIN > Config.Safes.maxAttempts then
        -- Too many failed attempts
        activeRegister = false
        activeSafe = false
        wrongPIN = 0
        ShowNotification(Strings.Notify.tooManySafeFails, 'error')
        return
    end
    local inputCode = lib.inputDialog(Strings.InputDialog.safeHeader, {Strings.InputDialog.safe})
    if not inputCode then activeSafe = true return end
    local convertedCode = tonumber(inputCode[1])
    if convertedCode ~= safePin then -- Wrong PIN
        wrongPIN = wrongPIN + 1
        activeSafe = true
        ShowNotification(Strings.Notify.wrongPin, 'error')
    elseif convertedCode == safePin then -- Correct PIN
        activeSafe = false
        wrongPIN = 0
        if lib[progressType](Config.Animations.safe) then
            activeRegister = false
            TriggerServerEvent('lation_247robbery:RewardRobbery', cache.serverId, 'safe')
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
        debug = Config.Debug,
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
        debug = Config.Debug,
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
        debug = Config.Debug,
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