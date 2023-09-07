Config = {}

-- General configs
Config.RequirePolice = true -- Set to true if you want to require police in order to rob stores (requires Config.Framework be set to 'esx' or 'qbcore' if true)
Config.PoliceCount = 0  -- If RequirePolice is true, how many must be online to rob stores?
Config.PoliceJobs = { 'police', 'sheriff' } -- Add your police job names here
Config.Dispatch = 'cd_dispatch' -- Available options: 'cd_dispatch', 'linden_outlawalert', 'ps-dispatch', 'qs-dispatch' and 'custom'

-- Register configs
Config.RegisterRobberyItem = 'advanced_lockpick' -- The item name required to rob a cash register
Config.RegisterMinCooldown = 10 -- The minimum cooldown time for robbing registers once one has been robbed
Config.RegisterMaxCooldown = 20 -- The maximum cooldown time for robbing registers once one has been robbed
Config.RegisterDiffuculty = { 'easy', 'easy', 'easy', 'easy', 'easy','easy', 'easy', 'easy', 'easy', 'easy' } -- The skillcheck difficulty, can be 'easy', 'medium' or 'hard' in any order and any quantity
Config.RegisterInput = { 'W', 'A', 'S', 'D' } -- The keys that are used for the skillcheck minigame, can be any keys
Config.RegisterRewardItem = 'black_money' -- The item that is rewarded upon a successful register robbery (Set to "markedbills" if using QBCore)
Config.RegisterRewardRandom = true -- Set true if you want to reward a random quantity of the above item, otherwise set false
Config.RegisterRewardQuantity = 1000 -- If RegisterRewardRandom = false then this is the quantity rewarded, if true then can be ignored
Config.RegisterRewardMinQuantity = 1000 -- If RegisterRewardRandom = true then this is the minimum quantity, otherwise can be ignored
Config.RegisterRewardMaxQuantity = 5000 -- If RegisterRewardRandom = true then this is the maximum quantity, otherwise can be ignored
Config.LockpickBreakChance = 50 -- The percentage chance the lockpick breaks when failing to lockpick a register
Config.CodeChance = 10 -- The percentage chance a player receives a code from the register to skip the PC hack requirement

-- Safe configs
Config.SafeMinCooldown = 10 -- The minimum cooldown time for robbing safes once one has been robbed
Config.SafeMaxCooldown = 20 -- The maximum cooldown time for robbing safes once one has been robbed
Config.MaxCodeAttempts = 3 -- The maximum amount of attempts to input the correct code to unlock safe before having to restart robbery
Config.SafeRewardItem = 'black_money' -- The item that is rewarded upon a successful safe robbery (Set to "markedbills" if using QBCore)
Config.SafeRewardRandom = true -- Set true if you want to reward a random quantity of the above item, otherwise set false
Config.SafeRewardQuantity = 2000 -- If SafeRewardRandom = false then this is the quantity rewarded, if true then can be ignored
Config.SafeRewardMinQuantity = 2000 -- If SafeRewardRandom = true then this is the minimum quantity, otherwise can be ignored
Config.SafeRewardMaxQuantity = 10000 -- If SafeRewardRandom = true then this is the maximum quantity, otherwise can be ignored

-- Computer configs
Config.MaxHackAttempts = 3 -- The maximum amount of hack attempts to get the safe code before having to restart robbery
Config.EnableQuestionnaire = true -- If true, the player will be asked a sequence of questions instead of the skillcheck below to hack the computer
Config.ComputerDifficulty = { 'easy', 'easy', 'easy', 'easy', 'easy','easy', 'easy', 'easy', 'easy', 'easy' } -- The skillcheck difficulty, can be 'easy', 'medium' or 'hard' in any order and any quantity (If EnableQuestionnaire is true, this can be ignored)
Config.ComputerInput = { 'W', 'A', 'S', 'D' } -- The keys that are used for the skillcheck minigame, can be any keys (If EnableQuestionnaire is true, this can be ignored)

-- Questionnaire configs
Config.Questions = { -- This is only used if Config.EnableQuestionnaire is true
    question1 = {
        question = 'What is a PSU?',
        icon = 'bolt'
    },
    question2 = {
        question = 'What does "HTTPS" stand for?',
        icon = 'lock'
    },
    question3 = {
        question = 'What is a GPU?',
        icon = 'desktop'
    },
    question4 = { -- This question is not typed but rather the player selects from a dropdown, the dropdown options displayed are below
        question = 'What does CTRL + A do?',
        icon = 'keyboard',
        options = {
            option1 = 'Copy text',
            option2 = 'Paste text',
            option3 = 'Select all',
            option4 = 'Print page'
        }
    },
}

Config.Answers = { -- This is only used if Config.EnableQuestionnaire is true
    question1Answer = 'power supply unit',
    question2Answer = 'hypertext transfer protocol secure',
    question3Answer = 'graphics processing unit',
    question4Answer = 3 -- Just the option number of the correct answer from above (option1 = 1, option2 = 2, etc)
}

-- Store configs
Config.Locations = {
    Registers = {
        vec3(24.9456, -1344.9544, 29.6116), -- Innocence Blvd
        vec3(-3041.3566, 584.2665, 8.0235), -- Inseno Road
        vec3(-3244.5734, 1000.6577, 12.9453), -- Barbareno Road
        vec3(1729.3294, 6417.1230, 35.1519), -- Great Ocean Highway
        vec3(1698.3787, 4923.2553, 42.2410), -- Grape Seed Main Street
        vec3(1959.3229, 3742.2895, 32.4584), -- Alhambra Drive
        vec3(548.9014, 2668.9414, 42.2711), -- Route 68
        vec3(2676.2124, 3280.9694, 55.3558), -- Senora Freeway
        vec3(2554.875, 381.3857, 108.7376), -- Palomino Freeway
        vec3(373.5953, 328.5891, 103.6810), -- Clinton Avenue
        vec3(-1820.5584, 793.9172, 138.2765), -- North Rockford Drive
        vec3(-47.2251, -1757.5423, 29.5983), -- Grove Street
        vec3(-706.7102, -913.5667, 19.3929), -- Ginger Street
        vec3(1164.1452, -322.7899, 69.3824) -- Mirror Park Blvd
    },
    Computers = {
        vec3(29.5590, -1338.3704, 29.3723), -- Innocence Blvd
        vec3(-3049.0339, 586.6518, 7.7842), -- Inseno Road
        vec3(-3250.736, 1005.8194, 12.7060), -- Barbareno Road
        vec3(1736.3864, 6420.9741, 34.9125), -- Great Ocean Highway
        vec3(1707.3872, 4921.6953, 42.0722), -- Grape Seed Main Street
        vec3(1960.0263, 3750.2978, 32.2190), -- Alhambra Drive
        vec3(545.1868, 2661.8115, 42.0318), -- Route 68
        vec3(2672.7070, 3288.2045, 55.1164), -- Senora Freeway
        vec3(2548.4802, 386.2579, 108.4982), -- Palomino Freeway
        vec3(379.6751, 333.8492, 103.4417), -- Clinton Avenue
        vec3(-1828.9333, 797.3793, 138.2624), -- North Rockford Drive
        vec3(-44.7806, -1748.8189, 29.4642), -- Grove Street
        vec3(-710.4782, -905.2836, 19.2711), -- Ginger Street
        vec3(1158.9605, -315.2624, 69.2748) -- Mirror Park Blvd
    },
    Safes = {
        vec3(28.1588, -1338.7192, 28.8068), -- Innocence Blvd
        vec3(-3048.2958, 585.4102, 7.2009), -- Inseno Road
        vec3(-3250.5161, 1004.4418, 12.1558), -- Barbareno Road
        vec3(1734.9835, 6421.3173, 34.3080), -- Great Ocean Highway
        vec3(1708.1695, 4920.8208, 41.3514), -- Grape Seed Main Street
        vec3(1959.0202, 3749.3291, 31.6847), -- Alhambra Drive
        vec3(546.5106, 2662.3266, 41.5089), -- Route 68
        vec3(2672.3398, 3286.8269, 54.6214), -- Senora Freeway
        vec3(2548.7395, 384.8841, 107.9211), -- Palomino Freeway
        vec3(378.2658, 333.8557, 102.9076), -- Clinton Avenue
        vec3(-1829.5384, 798.4634, 137.5601), -- North Rockford Drive
        vec3(-43.8009, -1748.0804, 28.7776), -- Grove Street
        vec3(-710.1920, -904.1401, 18.5740), -- Ginger Street
        vec3(1159.0540, -314.1202, 68.5665) -- Mirror Park Blvd
    }
}

-- String configs
Notify = {
    title = 'Convenience Store', -- The title for all notifications
    icon = 'store', -- The icon for all notifications
    position = 'top', -- The position of all notifications
    registerCooldown = 'Stores cannot be robbed this often - please wait and try again later',
    notEnoughPolice = 'There is not enough Police available in the city to do this',
    missingItem = 'You are missing a required tool to rob this register',
    lockpickBroke = 'You broke the lockpick and failed to open the register',
    robberyCancel = 'You stop robbing the register',
    failedHack = 'You failed hacking into the computer',
    wrongPin = 'You input the wrong pin and the safe remains locked',
    errorOccured = 'Something went wrong - please try again',
    tooManyHackFails = 'You\'ve failed to hack the computer too many times and failed robbing the store',
    tooManySafeFails = 'You\'ve input the wrong PIN too many times and failed robbing the safe'
}

Target = {
    debugTargets = false,
    registerLabel = 'Rob register',
    registerIcon = 'fas fa-lock',
    computerLabel = 'Login',
    computerIcon = 'fas fa-computer',
    safeLabel = 'Unlock',
    safeIcon = 'fas fa-key'
}

ProgressCircle = {
    position = 'middle', -- The position for all progressCircle's
    registerLabel = 'Grabbing cash..',
    registerDuration = 30000,
    safeLabel = 'Looting safe..',
    safeDuration = 30000
}

AlertDialog = {
    registerHeader = 'Note Found',
    registerContent = 'You found an interesting note under the register with nothing but the following numbers written on it: ',
    registerCancelButton = 'Who Cares?',
    registerConfirmButton = 'Got it',
    computerHeader = 'Code Exposed',
    computerContent = 'You successfully hacked the computer and find the following code: ',
    computerConfirmButton = 'Got it'
}

InputDialog = {
    questionsHeader = 'Security Questions',
    questionOne = 'Question #1',
    questionTwo = 'Question #2',
    questionThree = 'Question #3',
    questionFour = 'Question #4',
    safeHeader = 'Store Safe',
    safeLabel = 'Enter PIN',
    safeDescription = 'Input the PIN to unlock the safe',
    safePlaceholder = '6969',
    safeIcon = 'lock'
}