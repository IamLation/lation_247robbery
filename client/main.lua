local qtarget = exports.qtarget
local activeRegister, activeComputer, activeSafe = false, false, false
local conditionsMet, verifyReward = false, false
local generatedCode, safePin = nil, nil
local wrongPIN, failedHack = 0, 0

-- Function that checks that all conditions have been met before proceeding
function checkConditions()
    local hasItem = HasItem(Config.RegisterRobberyItem, 1)
    if hasItem then
        if Config.RequirePolice then
            local policeCount = lib.callback.await('lation_247robbery:getPoliceCount', false)
            if policeCount >= Config.PoliceCount then
                conditionsMet = true
                initiateRegisterRobbery()
            else
                conditionsMet = false
                activeRegister = false
                ShowNotification(Notify.notEnoughPolice, 'error')
            end
        else
            conditionsMet = true
            initiateRegisterRobbery()
        end
    else
        conditionsMet = false
        activeRegister = false
        ShowNotification(Notify.missingItem, 'error')
    end
end

-- Function that runs after all conditions have been met
function initiateRegisterRobbery()
    if conditionsMet then
        -- Obtain data used to send to PoliceDispatch event if needed
        local coords = GetEntityCoords(cache.ped)
        local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
        local data = {coords = coords, street = streetName}
        local cooldown = GlobalState.registerCooldown
        if cooldown == false then
            local success = lib.skillCheck(Config.RegisterDiffuculty, Config.RegisterInput)
            if success then
                PoliceDispatch(data)
                if lib.progressCircle({
                    label = ProgressCircle.registerLabel,
                    duration = ProgressCircle.registerDuration,
                    position = ProgressCircle.position,
                    useWhileDead = false,
                    canCancel = true,
                    disable = { car = true, move = true, combat = true },
                    anim = { dict = 'anim@heists@ornate_bank@grab_cash', clip = 'grab' }
                }) then
                    local codeChance = math.random(1, 100)
                    if codeChance <= Config.CodeChance then
                        generatedCode = math.random(1111, 9999)
                        safePin = generatedCode
                        local note = lib.alertDialog({
                            header = AlertDialog.registerHeader,
                            content = AlertDialog.registerContent ..generatedCode,
                            centered = true,
                            cancel = true,
                            labels = {
                                cancel = AlertDialog.registerCancelButton,
                                confirm = AlertDialog.registerConfirmButton
                            }
                        })
                        if note == 'confirm' then
                            -- Code was received, robbery proceeds
                            -- Player gets rewarded, cooldown begins
                            -- The safe becomes available, player must simply input the code to unlock
                            activeSafe = true
                            verifyReward = true
                            local reward = lib.callback.await('lation_247robbery:registerSuccessful', false, verifyReward)
                            if reward then
                                verifyReward = false
                            else
                                -- Kick/drop player? Potential cheating?
                                verifyReward = false
                            end
                        else
                            -- Player responded "Who Cares?" to the code they received, so robbery ends (meme'd)
                            -- Player is not rewarded
                            -- Cooldown is not activated
                            activeRegister = false
                        end
                    else
                        -- No code was received, player must proceed by hacking the PC
                        -- Player gets rewarded, cooldown begins
                        -- The computer becomes available, player must simply complete a hack to proceed
                        activeComputer = true
                        verifyReward = true
                        local reward = lib.callback.await('lation_247robbery:registerSuccessful', false, verifyReward)
                        if reward then
                            verifyReward = false
                        else
                            -- Kick/drop player? Potential cheating?
                            verifyReward = false
                        end
                    end
                else
                    -- Player cancelled the cash register robbery progress, so robbery ends
                    -- Player is not rewarded
                    -- Cooldown is not activated
                    activeRegister = false
                    ShowNotification(Notify.robberyCancel, 'error')
                end
            else
                -- Player failed to successfully lockpick the register, so a chance at breaking happens below
                local lockpickBreakChance = math.random(1, 100)
                if lockpickBreakChance <= Config.LockpickBreakChance then
                    TriggerServerEvent('lation_247robbery:removeItem', cache.serverId, Config.RegisterRobberyItem, 1)
                    ShowNotification(Notify.lockpickBroke, 'error')
                end
                activeRegister = false
            end
        else
            -- A cooldown is currently active, so the robbery will not proceed
            ShowNotification(Notify.registerCooldown, 'error')
            activeRegister = false
        end
    else
        return -- Conditions have not been met from the above function
    end
end

-- Function that runs after the register robbery if necessary
function initiateComputerHack()
    activeComputer = false -- Deactivates target option
    if failedHack < Config.MaxHackAttempts then -- Checks hack attempts
        lib.requestAnimDict('anim@heists@prison_heiststation@cop_reactions', 100)
        TaskPlayAnim(cache.ped, 'anim@heists@prison_heiststation@cop_reactions', 'cop_b_idle', 8.0, 8.0, -1, 1, 1, false, false, false)
        if Config.EnableQuestionnaire then
            local questions = lib.inputDialog(InputDialog.questionsHeader, {
                {type = 'input', label = InputDialog.questionOne, description = Config.Questions.question1.question, required = true, icon = Config.Questions.question1.icon},
                {type = 'input', label = InputDialog.questionTwo, description = Config.Questions.question2.question, required = true, icon = Config.Questions.question2.icon},
                {type = 'input', label = InputDialog.questionThree, description = Config.Questions.question3.question, required = true, icon = Config.Questions.question3.icon},
                {type = 'select', label = InputDialog.questionFour, description = Config.Questions.question4.question, options = {
                    { value = '1', label = Config.Questions.question4.options.option1 },
                    { value = '2', label = Config.Questions.question4.options.option2 },
                    { value = '3', label = Config.Questions.question4.options.option3 },
                    { value = '4', label = Config.Questions.question4.options.option4 }
                }, required = true, icon = Config.Questions.question4.icon}
            })
            if not questions then
                activeComputer = true
                ClearPedTasks(cache.ped)
                return
            end
            if string.lower(questions[1]) == string.lower(Config.Answers.question1Answer) and string.lower(questions[2]) == string.lower(Config.Answers.question2Answer) 
            and string.lower(questions[3]) == string.lower(Config.Answers.question3Answer) and string.lower(questions[4]) == tostring(Config.Answers.question4Answer) then 
                failedHack = 0
                ClearPedTasks(cache.ped)
                generatedCode = math.random(1111, 9999)
                safePin = generatedCode
                lib.alertDialog({
                    header = AlertDialog.computerHeader,
                    content = AlertDialog.computerContent ..generatedCode,
                    centered = true,
                    cancel = false,
                    labels = {
                        confirm = AlertDialog.computerConfirmButton
                    }
                })
                activeSafe = true
            else
                ClearPedTasks(cache.ped)
                activeComputer = true
                failedHack = failedHack + 1
                ShowNotification(Notify.failedHack, 'error')
            end
        else
            local success = lib.skillCheck(Config.ComputerDifficulty, Config.ComputerInput)
            if success then -- Player passes the hack
                failedHack = 0
                ClearPedTasks(cache.ped)
                generatedCode = math.random(1111, 9999)
                safePin = generatedCode
                lib.alertDialog({
                    header = AlertDialog.computerHeader,
                    content = AlertDialog.computerContent ..generatedCode,
                    centered = true,
                    cancel = false,
                    labels = {
                        confirm = AlertDialog.computerConfirmButton
                    }
                })
                activeSafe = true
            else -- Player failed the hack
                ClearPedTasks(cache.ped)
                activeComputer = true
                failedHack = failedHack + 1
                ShowNotification(Notify.failedHack, 'error')
            end
        end
    else -- Player has failed the hack too many times, robbery ends/restarts
        activeRegister = false
        activeComputer = false
        failedHack = 0
        ShowNotification(Notify.tooManyHackFails, 'error')
    end
end

-- Function that runs after a successful register robbery and/or computer hacking
function initiateSafeRobbery()
    activeSafe = false -- Deactivates target option 
    if wrongPIN < Config.MaxCodeAttempts then -- Checks PIN attempts
        local inputCode = lib.inputDialog(InputDialog.safeHeader, {
            {type = 'input', label = InputDialog.safeLabel, description = InputDialog.safeDescription, placeholder = InputDialog.safePlaceholder, icon = InputDialog.safeIcon, required = true, min = 4, max = 16},
        })
        if not inputCode then
            activeSafe = true
            return
        end
        local convertedCode = tonumber(inputCode[1])
        if convertedCode ~= safePin then -- Wrong PIN
            wrongPIN = wrongPIN + 1
            activeSafe = true
            ShowNotification(Notify.wrongPin, 'error')
        elseif convertedCode == safePin then -- Correct PIN
            activeSafe = false
            wrongPIN = 0
            if lib.progressCircle({
                label = ProgressCircle.safeLabel,
                duration = ProgressCircle.safeDuration,
                position = ProgressCircle.position,
                useWhileDead = false,
                canCancel = true,
                disable = { car = true, move = true, combat = true },
                anim = { dict = 'anim@heists@ornate_bank@grab_cash', clip = 'grab' }
            }) then
                activeRegister = false
                verifyReward = true
                local reward = lib.callback.await('lation_247robbery:safeSuccessful', false, verifyReward)
                if reward then
                    verifyReward = false
                else
                    -- Kick/drop player? Potential cheating?
                    verifyReward = false
                end
            else
                -- cancelled looting the safe
                -- notify of cancel
            end
        else -- Something went wrong
            ShowNotification(Notify.errorOccured, 'error')
        end
    else -- Player has input a wrong PIN too many times, robbery ends/restarts
        activeRegister = false
        activeSafe = false
        wrongPIN = 0
        ShowNotification(Notify.tooManySafeFails, 'error')
    end
end

-- Creates all the targets for the registers noted in the Config
for k, v in pairs(Config.Locations.Registers) do
    qtarget:AddCircleZone('cash_register' ..k, v, 0.35, {
        name = 'cash_register' ..k,
        debugPoly = Target.debugTargets,
    }, {
        options = {
            {
                icon = Target.registerIcon,
                label = Target.registerLabel,
                canInteract = function()
                    if activeRegister then
                        return false
                    else
                        return true
                    end
                end,
                action = function()
                    activeRegister = true
                    checkConditions()
                end
            }
        },
        distance = 2,
    })
end

-- Creates all the targets for the computers noted in the Config
for k, v in pairs(Config.Locations.Computers) do
    qtarget:AddCircleZone('computer' ..k, v, 0.35, {
        name = 'computer' ..k,
        debugPoly = Target.debugTargets,
    }, {
        options = {
            {
                icon = Target.computerIcon,
                label = Target.computerLabel,
                canInteract = function()
                    if activeComputer then
                        return true
                    else
                        return false
                    end
                end,
                action = function()
                    initiateComputerHack()
                end
            }
        },
        distance = 2,
    })
end

-- Creates all the targets for the safes noted in the Config
for k, v in pairs(Config.Locations.Safes) do
    qtarget:AddCircleZone('safe' ..k, v, 0.45, {
        name = 'safe' ..k,
        debugPoly = Target.debugTargets,
    }, {
        options = {
            {
                icon = Target.safeIcon,
                label = Target.safeLabel,
                canInteract = function()
                    if activeSafe then
                        return true
                    else
                        return false
                    end
                end,
                action = function()
                    initiateSafeRobbery()
                end
            }
        },
        distance = 2,
    })
end