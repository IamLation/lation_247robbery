Config = {}

--[[ General Configs ]]
Config.RequirePolice = true -- Set to true if you want to require police in order to rob stores
Config.PoliceCount = 0  -- If RequirePolice is true, how many must be online to rob stores?
Config.PoliceJobs = { 'police', 'sheriff' } -- Add your police job names here

--[[ Register Configs ]]
Config.RegisterRobberyItem = 'advanced_lockpick' -- The item name required to rob a cash register
Config.RegisterMinCooldown = 10 -- The minimum cooldown time for robbing registers once one has been robbed
Config.RegisterMaxCooldown = 20 -- The maximum cooldown time for robbing registers once one has been robbed
Config.RegisterDiffuculty = { 'easy', 'easy', 'easy', 'easy', 'easy','easy', 'easy', 'easy', 'easy', 'easy' } -- The skillcheck difficulty, can be 'easy', 'medium' or 'hard' in any order and any quantity
Config.RegisterInput = { 'W', 'A', 'S', 'D' } -- The keys that are used for the skillcheck minigame, can be any keys
Config.RegisterRewardItem = 'black_money' -- The item that is rewarded upon a successful register robbery
Config.RegisterRewardRandom = true -- Set true if you want to reward a random quantity of the above item, otherwise set false
Config.RegisterRewardQuantity = 1000 -- If RegisterRewardRandom = false then this is the quantity rewarded, if true then can be ignored
Config.RegisterRewardMinQuantity = 1000 -- If RegisterRewardRandom = true then this is the minimum quantity, otherwise can be ignored
Config.RegisterRewardMaxQuantity = 5000 -- If RegisterRewardRandom = true then this is the maximum quantity, otherwise can be ignored
Config.LockpickBreakChance = 50 -- The percentage chance the lockpick breaks when failing to lockpick a register
Config.CodeChance = 10 -- The percentage chance a player receives a code from the register to skip the PC hack requirement

--[[ Safe Configs ]]
Config.SafeMinCooldown = 10 -- The minimum cooldown time for robbing safes once one has been robbed
Config.SafeMaxCooldown = 20 -- The maximum cooldown time for robbing safes once one has been robbed
Config.MaxCodeAttempts = 3 -- The maximum amount of attempts to input the correct code to unlock safe before having to restart robbery
Config.SafeRewardItem = 'black_money' -- The item that is rewarded upon a successful safe robbery
Config.SafeRewardRandom = true -- Set true if you want to reward a random quantity of the above item, otherwise set false
Config.SafeRewardQuantity = 2000 -- If SafeRewardRandom = false then this is the quantity rewarded, if true then can be ignored
Config.SafeRewardMinQuantity = 2000 -- If SafeRewardRandom = true then this is the minimum quantity, otherwise can be ignored
Config.SafeRewardMaxQuantity = 10000 -- If SafeRewardRandom = true then this is the maximum quantity, otherwise can be ignored

--[[ Computer Configs ]]
Config.MaxHackAttempts = 3 -- The maximum amount of hack attempts to get the safe code before having to restart robbery

--[[ Store Location Configs, Default 24/7 ]]
Config.Locations = {
    Registers = {
        vec3(24.94561958313, -1344.9544677734, 29.611698150635), -- Innocence Blvd
        vec3(-3041.3566894531, 584.26654052734, 8.0235967636108), -- Inseno Road
        vec3(-3244.5734863281, 1000.6577758789, 12.945377349854), -- Barbareno Road
        vec3(1729.3294677734, 6417.123046875, 35.151908874512), -- Great Ocean Highway
        vec3(1698.3787841797, 4923.2553710938, 42.241004943848), -- Grape Seed Main Street
        vec3(1959.3229980469, 3742.2895507813, 32.458427429199), -- Alhambra Drive
        vec3(548.90148925781, 2668.94140625, 42.271179199219), -- Route 68
        vec3(2676.2124023438, 3280.9694824219, 55.355815887451), -- Senora Freeway
        vec3(2554.875, 381.3857421875, 108.73764801025), -- Palomino Freeway
        vec3(373.59536743164, 328.58917236328, 103.6810760498), -- Clinton Avenue
        vec3(-1820.5584716797, 793.91729736328, 138.27656555176), -- North Rockford Drive
        vec3(-47.225128173828, -1757.5423583984, 29.598356246948), -- Grove Street
        vec3(-706.71026611328, -913.56671142578, 19.392950057983), -- Ginger Street
        vec3(1164.1452636719, -322.78991699219, 69.382453918457) -- Mirror Park Blvd
    },
    Computers = {
        vec3(29.559032440186, -1338.3704833984, 29.372346878052), -- Innocence Blvd
        vec3(-3049.0339355469, 586.65185546875, 7.784245967865), -- Inseno Road
        vec3(-3250.7368164063, 1005.8194580078, 12.706026077271), -- Barbareno Road
        vec3(1736.3864746094, 6420.9741210938, 34.91255569458), -- Great Ocean Highway
        vec3(1707.3872070313, 4921.6953125, 42.072231292725), -- Grape Seed Main Street
        vec3(1960.0263671875, 3750.2978515625, 32.219074249268), -- Alhambra Drive
        vec3(545.18688964844, 2661.8115234375, 42.031826019287), -- Route 68
        vec3(2672.70703125, 3288.2045898438, 55.11646270752), -- Senora Freeway
        vec3(2548.4802246094, 386.25790405273, 108.49829864502), -- Palomino Freeway
        vec3(379.67517089844, 333.84927368164, 103.44172668457), -- Clinton Avenue
        vec3(-1828.9333496094, 797.37933349609, 138.2624206543), -- North Rockford Drive
        vec3(-44.780643463135, -1748.8189697266, 29.464208602905), -- Grove Street
        vec3(-710.47827148438, -905.28369140625, 19.271154403687), -- Ginger Street
        vec3(1158.9605712891, -315.26245117188, 69.274871826172) -- Mirror Park Blvd
    },
    Safes = {
        vec3(28.15885734558105, -1338.71923828125, 28.80680847167968), -- Innocence Blvd
        vec3(-3048.2958984375, 585.4102172851562, 7.20098972320556), -- Inseno Road
        vec3(-3250.51611328125, 1004.4418334960938, 12.1558141708374), -- Barbareno Road
        vec3(1734.9835205078125, 6421.3173828125, 34.30803680419922), -- Great Ocean Highway
        vec3(1708.1695556640625, 4920.82080078125, 41.35140991210937), -- Grape Seed Main Street
        vec3(1959.020263671875, 3749.3291015625, 31.68475151062011), -- Alhambra Drive
        vec3(546.5106201171875, 2662.32666015625, 41.50892639160156), -- Route 68
        vec3(2672.33984375, 3286.826904296875, 54.62140655517578), -- Senora Freeway
        vec3(2548.739501953125, 384.8841552734375, 107.92117309570312), -- Palomino Freeway
        vec3(378.2658081054688, 333.8557739257813, 102.9076156616211), -- Clinton Avenue
        vec3(-1829.5384521484375, 798.4634399414062, 137.5601043701172), -- North Rockford Drive
        vec3(-43.80093765258789, -1748.0804443359375, 28.77762031555175), -- Grove Street
        vec3(-710.1920776367188, -904.14013671875, 18.57401466369629), -- Ginger Street
        vec3(1159.0540771484375, -314.1202087402344, 68.56658172607422) -- Mirror Park Blvd
    }
}

--[[ String Configs ]]
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