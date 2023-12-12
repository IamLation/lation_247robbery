-- Initialize variables
local progressType = Config.ProgressType == 'bar' and 'progressBar' or 'progressCircle'
local activeRegister, activeComputer, activeSafe = false, false, false
local generatedCode, safePin = nil, nil
local wrongPIN, failedHack = 0, 0

-- Function to check if player has required item & enough police (if applicable)
local CheckConditions = function()
    local hasItem = HasItem(Config.RegisterRobberyItem)
    if hasItem then
        if Config.RequirePolice then
            local policeCount = lib.callback.await('lation_247robbery:getPoliceCount', false)
            if policeCount >= Config.PoliceCount then
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

-- Function to start the initial robbery process
local InitiateRegisterRobbery = function()
    if CheckConditions() then -- Ensure item & police status
        -- Collect data for dispatch
        local coords = GetEntityCoords(cache.ped)
        local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
        local data = {coords = coords, street = streetName}
        local cooldown = GlobalState.registerCooldown
        -- Check cooldown status
        if not cooldown then
            -- Begin lockpicking emote
            local dict, anim = Config.Animations.lockpick.animDict, Config.Animations.lockpick.animClip
            lib.requestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 51, 1.0, false, false, false)
            -- Start skillcheck
            local skillcheck = lib.skillCheck(Config.RegisterDiffuculty, Config.RegisterInput)
            ClearPedTasks(cache.ped)
            if skillcheck then
                -- Alert police
                PoliceDispatch(data)
                if lib[progressType](Config.Animations.register) then
                    -- Check if they got the code to skip computer hack
                    local codeChance = math.random(1, 100)
                    if codeChance <= Config.CodeChance then
                        generatedCode = math.random(1111, 9999)
                        safePin = generatedCode
                        local note = lib.alertDialog({
                            header = Strings.AlertDialog.registerHeader,
                            content = Strings.AlertDialog.registerContent ..generatedCode,
                            centered = true, cancel = false,
                            labels = {cancel = Strings.AlertDialog.registerCancelButton, confirm = Strings.AlertDialog.registerConfirmButton}
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
            else
                -- Failed skillcheck - potential lockpick breaking
                local breakChance = math.random(1, 100)
                if breakChance <= Config.LockpickBreakChance then
                    TriggerServerEvent('lation_247robbery:RemoveItem', cache.serverId, Config.RegisterRobberyItem, 1)
                    ShowNotification(Strings.Notify.lockpickBroke, 'error')
                end
                activeRegister = false
            end
        else
            -- A cooldown is currently active
            ShowNotification(Strings.Notify.registerCooldown, 'error')
            activeRegister = false
        end
    end
end

-- Function to handle hacking the computer if required
local InitiateComputerHack = function()
    activeComputer = false -- Deactive target
    if failedHack < Config.MaxHackAttempts then -- Check hack attempts
        -- Load and play anim during hacking
        local dict, anim = Config.Animations.hackPC.animDict, Config.Animations.hackPC.animClip
        lib.requestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(0) end
        TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 1, 1, false, false, false)
        -- If questionnaire enabled, then proceed
        if Config.EnableQuestionnaire then
            local questions = lib.inputDialog(Strings.InputDialog.questionsHeader, {
                {type = 'input', label = Strings.InputDialog.questionOne, description = Config.Questions.question1.question, required = true, icon = Config.Questions.question1.icon},
                {type = 'input', label = Strings.InputDialog.questionTwo, description = Config.Questions.question2.question, required = true, icon = Config.Questions.question2.icon},
                {type = 'input', label = Strings.InputDialog.questionThree, description = Config.Questions.question3.question, required = true, icon = Config.Questions.question3.icon},
                {type = 'select', label = Strings.InputDialog.questionFour, description = Config.Questions.question4.question, options = {
                    { value = '1', label = Config.Questions.question4.options.option1 },
                    { value = '2', label = Config.Questions.question4.options.option2 },
                    { value = '3', label = Config.Questions.question4.options.option3 },
                    { value = '4', label = Config.Questions.question4.options.option4 }
                }, required = true, icon = Config.Questions.question4.icon}
            })
            if not questions then -- No answers or nil, reset & return
                activeComputer = true
                ClearPedTasks(cache.ped)
                return
            end
            -- Check answers
            if string.lower(questions[1]) == string.lower(Config.Answers.question1Answer) and string.lower(questions[2]) == string.lower(Config.Answers.question2Answer)
            and string.lower(questions[3]) == string.lower(Config.Answers.question3Answer) and string.lower(questions[4]) == tostring(Config.Answers.question4Answer) then
                -- Player passed, continue
                failedHack = 0
                ClearPedTasks(cache.ped)
                generatedCode = math.random(1111, 9999)
                safePin = generatedCode
                lib.alertDialog({
                    header = Strings.AlertDialog.computerHeader,
                    content = Strings.AlertDialog.computerContent ..generatedCode,
                    centered = true,
                    cancel = false,
                    labels = {
                        confirm = Strings.AlertDialog.computerConfirmButton
                    }
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
            local skillcheck = lib.skillCheck(Config.ComputerDifficulty, Config.ComputerInput)
            if skillcheck then
                -- Player passed
                failedHack = 0
                ClearPedTasks(cache.ped)
                generatedCode = math.random(1111, 9999)
                safePin = generatedCode
                lib.alertDialog({
                    header = Strings.AlertDialog.computerHeader,
                    content = Strings.AlertDialog.computerContent ..generatedCode,
                    centered = true,
                    cancel = false,
                    labels = {
                        confirm = Strings.AlertDialog.computerConfirmButton
                    }
                })
                activeSafe = true
            else
                -- Player failed
                ClearPedTasks(cache.ped)
                activeComputer = true
                failedHack = failedHack + 1
                ShowNotification(Strings.Notify.failedHack, 'error')
            end
        end
    else
        -- Too many failed attempts
        activeRegister = false
        activeComputer = false
        failedHack = 0
        ShowNotification(Strings.Notify.tooManyHackFails, 'error')
    end
end

-- Function to handle the safe robbery
local InitiateSafeRobbery = function()
    activeSafe = false -- Disable target option
    if wrongPIN < Config.MaxCodeAttempts then -- Ensure not put wrong pin too many times
        local inputCode = lib.inputDialog(Strings.InputDialog.safeHeader, {
            {type = 'input', label = Strings.InputDialog.safeLabel, description = Strings.InputDialog.safeDescription, placeholder = Strings.InputDialog.safePlaceholder, icon = Strings.InputDialog.safeIcon, required = true, min = 4, max = 16},
        })
        if not inputCode then
            activeSafe = true
            return
        end
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
                ShowNotification('You cancelled robbing the safe', 'error')
            end
        end
    else
        -- Too many failed attempts
        activeRegister = false
        activeSafe = false
        wrongPIN = 0
        ShowNotification(Strings.Notify.tooManySafeFails, 'error')
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
                icon = Strings.Target.registerIcon,
                label = Strings.Target.registerLabel,
                canInteract = function()
                    if not activeRegister then
                        return true
                    end
                    return false
                end,
                action = function()
                    activeRegister = true
                    if CheckConditions() then
                        InitiateRegisterRobbery()
                    end
                end,
                onSelect = function()
                    activeRegister = true
                    if CheckConditions() then
                        InitiateRegisterRobbery()
                    end
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
                icon = Strings.Target.computerIcon,
                label = Strings.Target.computerLabel,
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
                icon = Strings.Target.safeIcon,
                label = Strings.Target.safeLabel,
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