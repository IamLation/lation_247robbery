local qtarget = exports.qtarget
local ox_inventory = exports.ox_inventory
local activeRegister = false
local activeComputer = false
local activeSafe = false
local conditionsMet = false
local generatedCode = nil
local safePin = nil
local wrongPIN = 0
local failedHack = 0
local verifyReward = false

if Config.Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
else
    -- Custom framework
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

-- Function that checks that all conditions have been met before proceeding
function checkConditions()
    if Config.Framework == 'esx' then
        local hasItem = ESX.SearchInventory(Config.RegisterRobberyItem, 1)
        if hasItem >= 1 then
            if Config.RequirePolice then
                local policeCount = lib.callback.await('lation_247robbery:policeCount', false)
                if policeCount >= Config.PoliceCount then
                    conditionsMet = true
                    initiateRegisterRobbery()
                else
                    conditionsMet = false
                    activeRegister = false
                    lib.notify({ id = 'policeMissing', title = Notify.title, description = Notify.notEnoughPolice, icon = Notify.icon, type = 'error', position = Notify.position })
                end
            else
                conditionsMet = true
                initiateRegisterRobbery()
            end
        else
            conditionsMet = false
            activeRegister = false
            lib.notify({ id = 'itemMissing', title = Notify.title, description = Notify.missingItem, icon = Notify.icon, type = 'error', position = Notify.position })
        end
    elseif Config.Framework == 'qbcore' then
        local hasItem = QBCore.Functions.HasItem(Config.RegisterRobberyItem)
        if hasItem then
            if Config.RequirePolice then
                local policeCount = lib.callback.await('lation_247robbery:policeCount', false)
                if policeCount >= Config.PoliceCount then
                    conditionsMet = true
                    initiateRegisterRobbery()
                else
                    conditionsMet = false
                    activeRegister = false
                    lib.notify({ id = 'policeMissing', title = Notify.title, description = Notify.notEnoughPolice, icon = Notify.icon, type = 'error', position = Notify.position })
                end
            else
                conditionsMet = true
                initiateRegisterRobbery()
            end
        else
            conditionsMet = false
            activeRegister = false
            lib.notify({ id = 'itemMissing', title = Notify.title, description = Notify.missingItem, icon = Notify.icon, type = 'error', position = Notify.position })
        end
    else
        -- Custom framework/standalone
        local hasItem = ox_inventory:Search('count', Config.RegisterRobberyItem)
        if hasItem >= 1 then
            if Config.RequirePolice then
                local policeCount = lib.callback.await('lation_247robbery:policeCount', false)
                if policeCount >= Config.PoliceCount then
                    conditionsMet = true
                    initiateRegisterRobbery()
                else
                    conditionsMet = false
                    activeRegister = false
                    lib.notify({ id = 'policeMissing', title = Notify.title, description = Notify.notEnoughPolice, icon = Notify.icon, type = 'error', position = Notify.position })
                end
            else
                conditionsMet = true
                initiateRegisterRobbery()
            end
        else
            conditionsMet = false
            activeRegister = false
            lib.notify({ id = 'itemMissing', title = Notify.title, description = Notify.missingItem, icon = Notify.icon, type = 'error', position = Notify.position })
        end
    end
end

-- Function that runs after all conditions have been met
function initiateRegisterRobbery()
    if conditionsMet then
        local cooldown = GlobalState.registerCooldown
        if cooldown == false then
            local success = lib.skillCheck(Config.RegisterDiffuculty, Config.RegisterInput)
            if success then
                -- Add your dispatch system/notification here
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
                    lib.notify({ id = 'robberyCancel', title = Notify.title, description = Notify.robberyCancel, icon = Notify.icon, type = 'error', position = Notify.position })
                end
            else
                -- Player failed to successfully lockpick the register, so a chance at breaking happens below
                local lockpickBreakChance = math.random(1, 100)
                if lockpickBreakChance <= Config.LockpickBreakChance then
                    lib.callback('lation_247robbery:removeItem', false, source, Config.RegisterRobberyItem, 1)
                    lib.notify({ id = 'lockpickBroke', title = Notify.title, description = Notify.lockpickBroke, icon = Notify.icon, type = 'error', position = Notify.position })
                end
                activeRegister = false
            end
        else
            -- A cooldown is currently active, so the robbery will not proceed
            lib.notify({ id = 'registerCooldown', title = Notify.title, description = Notify.registerCooldown, icon = Notify.icon, type = 'error', position = Notify.position })
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
        TaskPlayAnim(cache.ped, 'anim@heists@prison_heiststation@cop_reactions', 'cop_b_idle', 8.0, 8.0, -1, 1, 1, 0, 0, 0)
        if Config.EnableQuestionnaire then
            local questions = lib.inputDialog('Security Questions', {
                {type = 'input', label = 'Question #1', description = Config.Questions.question1.question, required = true, icon = Config.Questions.question1.icon},
                {type = 'input', label = 'Question #2', description = Config.Questions.question2.question, required = true, icon = Config.Questions.question2.icon},
                {type = 'input', label = 'Question #3', description = Config.Questions.question3.question, required = true, icon = Config.Questions.question3.icon},
                {type = 'select', label = 'Question #4', description = Config.Questions.question4.question, options = {
                    { value = '1', label = Config.Questions.question4.options.option1 },
                    { value = '2', label = Config.Questions.question4.options.option2 },
                    { value = '3', label = Config.Questions.question4.options.option3 },
                    { value = '4', label = Config.Questions.question4.options.option4 }
                }, required = true, icon = Config.Questions.question4.icon}
            })
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
                lib.notify({ id = 'failedHack', title = Notify.title, description = Notify.failedHack, icon = Notify.icon, type = 'error', position = Notify.position })
                -- Add another dispatch notification here, if desired
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
                lib.notify({ id = 'failedHack', title = Notify.title, description = Notify.failedHack, icon = Notify.icon, type = 'error', position = Notify.position })
                -- Add another dispatch notification here, if desired
            end
        end
    else -- Player has failed the hack too many times, robbery ends/restarts
        activeRegister = false
        activeComputer = false
        failedHack = 0
        lib.notify({ id = 'tooManyHackFails', title = Notify.title, description = Notify.tooManyHackFails, icon = Notify.icon, type = 'error', position = Notify.position })
    end
end

-- Function that runs after a successful register robbery and/or computer hacking
function initiateSafeRobbery()
    activeSafe = false -- Deactivates target option 
    if wrongPIN < Config.MaxCodeAttempts then -- Checks PIN attempts
        local inputCode = lib.inputDialog('Store Safe', {
            {type = 'input', label = 'Enter PIN', description = 'Input the PIN to unlock the safe', placeholder = '6969', icon = 'lock', required = true, min = 4, max = 16},
        })
        local convertedCode = tonumber(inputCode[1])
        if convertedCode ~= safePin then -- Wrong PIN
            wrongPIN = wrongPIN + 1
            activeSafe = true
            lib.notify({ id = 'wrongPIN', title = Notify.title, description = Notify.wrongPin, icon = Notify.icon, type = 'error', position = Notify.position })
            -- Add another dispatch notification here, if desired for player inputting wrong PIN on safe
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
            lib.notify({ id = 'wrongPIN', title = Notify.title, description = Notify.errorOccured, icon = Notify.icon, type = 'error', position = Notify.position })
        end
    else -- Player has input a wrong PIN too many times, robbery ends/restarts
        activeRegister = false
        activeSafe = false
        wrongPIN = 0
        lib.notify({ id = 'tooManyFails', title = Notify.title, description = Notify.tooManySafeFails, icon = Notify.icon, type = 'error', position = Notify.position })
    end
end