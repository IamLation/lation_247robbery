Config = {} -- Do not alter

-- 🔎 Looking for more high quality scripts?
-- 🛒 Shop Now: https://lationscripts.com/github
-- 💬 Join Discord: https://discord.gg/9EbY4nM5uu
-- 😢 How dare you leave this option false?!
Config.YouFoundTheBestScripts = false

----------------------------------------------
--        🛠️ Setup the basics below
----------------------------------------------

Config.Setup = {
    -- Use only if needed, directed by support or know what you're doing
    -- Notice: enabling debug features will significantly increase resmon
    -- And should always be disabled in production
    debug = false,
    -- Set your interaction system below
    -- Available options are: 'ox_target', 'qb-target', 'interact' & 'custom'
    -- 'custom' needs to be added to client/functions.lua
    interact = 'ox_target',
    -- Set your notification system below
    -- Available options are: 'ox_lib', 'esx', 'qb', 'okok', 'sd-notify', 'wasabi_notify', 'mythic_notify' & 'custom'
    -- 'custom' needs to be added to client/functions.lua
    notify = 'ox_lib',
    -- Set your progress bar system below
    -- Available options are: 'ox_lib', 'qbcore' & 'custom'
    -- 'custom' needs to be added to client/functions.lua
    -- Any custom progress bar must also support animations
    progress = 'ox_lib',
    -- Do you want to be notified via server console if an update is available?
    -- True if yes, false if no
    version = true,
    -- 'metadata' is for QBCore users only
    -- If true, the resource will reward metadata values for 'markedbills'
    -- If false, the resource will reward the item without metadata, and just 1-to-1
    metadata = true,
    -- Once a store robbery has succesfully started a cooldown begins
    -- This is per-player and not a global cooldown (cooldown is in seconds)
    cooldown = 600,
}

----------------------------------------------
--        👮 Setup police options
----------------------------------------------

-- Manage all the police options here
Config.Police = {
    -- Do you want to require police be online in order to rob stores?
    -- Then set require = true! If false, police will not be required
    require = false,
    -- If require = true, how many must be online to rob the stores?
    count = 3,
    -- Add your police job(s) below
    jobs = { 'police', 'sheriff' },
    -- Set your dispatch system
    -- Available options: 'cd_dispatch', 'ps-dispatch', 'qs-dispatch'
    -- 'core_dispatch', 'rcore_dispatch', aty_dispatch', 'op-dispatch',
    -- 'origen_police', 'emergencydispatch' & 'custom' option
    dispatch = 'custom',
    -- Risk is a feature you can enable that will increase the players
    -- Reward payout based on the number of police online during the robbery!
    -- Do you want to enable the risk feature?
    risk = true,
    -- If risk = true, percent is how much the reward payout increases
    -- In percentage for EVERY cop online. If percent = 10 and there are
    -- 3 police online, the reward payout will increase 30%
    percent = 10
}

----------------------------------------------
--        🏪 Setup register robbery
----------------------------------------------

Config.Registers = {
    -- Set the required item name below needed to rob a cash register
    item = 'lockpick',
    -- Customize the minigame (skillcheck) difficulty below
    minigame = {
        -- Set the skillcheck difficulty levels below
        -- You can set 'easy', 'medium' or 'hard' in any order
        -- And in any amount/quantity - Learn more about the skillcheck
        -- Here: https://overextended.dev/ox_lib/Modules/Interface/Client/skillcheck
        difficulty = { 'easy', 'easy', 'easy', 'easy', 'easy','easy', },
        -- The 'inputs' are the keys that will be used for the skillcheck
        -- Minigame and can be set to any key or keys of your choice
        inputs = { 'W', 'A', 'S', 'D' }
    },
    -- After a successful register robbery, what item do you want to reward
    -- And how much of it? Set the item = 'name' below and min/max quantites
    reward = { item = 'black_money', min = 1000, max = 1000 },
    -- If a player fails to successfully lockpick the register
    -- There is a chance that their lockpick will break. In percentage,
    -- What chance do you want their lockpick to break? To never break, set 0
    -- To break every time, set 100
    breakChance = 50,
    -- After a player succesfully robs a register, there is this "noteChance" they
    -- "Find" the safe's PIN "under the register" and can skip the computer hacking
    -- Step if found. In percentage, what chance do they have to find this note?
    noteChance = 10
}

----------------------------------------------
--        🖥️ Setup computer hacking
----------------------------------------------

Config.Computers = {
    -- When a player is attempting to hack the computer how many
    -- Attempts do you want to allow? By default, after 3 failed attempts
    -- The robbery will end and not proceed any further
    maxAttempts = 3,
    -- Do you want to enable the questionnaire hack? If true, this will replace
    -- The skillcheck hack with a series of questions the player must answer correctly
    questionnaire = false,
    -- Customize the minigame (skillcheck) difficulty below
    minigame = {
        -- Set the skillcheck difficulty levels below
        -- You can set 'easy', 'medium' or 'hard' in any order
        -- And in any amount/quantity - Learn more about the skillcheck
        -- Here: https://overextended.dev/ox_lib/Modules/Interface/Client/skillcheck
        difficulty = { 'easy', 'easy', 'easy', 'easy', 'easy','easy', },
        -- The 'inputs' are the keys that will be used for the skillcheck
        -- Minigame and can be set to any key or keys of your choice
        inputs = { 'W', 'A', 'S', 'D' }
    },
}

----------------------------------------------
--        🔐 Setup safe robbery
----------------------------------------------

Config.Safes = {
    -- When a player is attempting to hack the safe (inputting the PIN) how
    -- Many attempts do you want to allow? By default, after 3 failed attempts
    -- The robbery will end and not proceed (they will not be rewarded)
    maxAttempts = 3,
    -- After a successful safe robbery, what item do you want to reward
    -- And how much of it? Set the item = 'name' below and min/max quantites
    reward = { item = 'black_money', min = 2000, max = 7000 },
}

----------------------------------------------
--        ❓ Setup questionnaire
----------------------------------------------

-- Create, edit & manage all the questionnaire related options here if enabled
-- You can create as many questions and answers as you wish
Config.Questionnaire = {
    questions = {
        [1] = {
            type = 'input',
            label = 'Question #1',
            description = 'What is a PSU?',
            icon = 'fas fa-bolt',
            required = true
        },
        [2] = {
            type = 'input',
            label = 'Question #2',
            description = 'What does "HTTPS" stand for?',
            icon = 'fas fa-lock',
            required = true
        },
        [3] = {
            type = 'input',
            label = 'Question #3',
            description = 'What is a GPU?',
            icon = 'fas fa-desktop',
            required = true
        },
        [4] = {
            type = 'select',
            label = 'Question #4',
            description = 'What does CTRL + A do?',
            icon = 'fas fa-keyboard',
            required = true,
            options = {
                { value = 1, label = 'Copy text' },
                { value = 2, label = 'Paste text' },
                { value = 3, label = 'Select all' },
                { value = 4, label = 'Print page' },
            }
        },
        -- Add more questions here, following the same format as above
        -- Be sure to increment the numbers correctly, [5], [6], etc
    },
    -- All the answers to the above questions must be placed here
    -- Put the answers in the same order the questions are above
    -- The answer to question [3] above should be [3] here as well
    -- Note: answers to type = 'select' should be the value numer
    answers = {
        [1] = 'power supply unit',
        [2] = 'hypertext transfer protocol secure',
        [3] = 'graphics processing unit',
        [4] = 3
    }
}

----------------------------------------------
--    💃 Customize animations and props
----------------------------------------------

Config.Animations = {
    lockpick = {
        animDict = 'missheistfbisetup1',
        animClip = 'hassle_intro_loop_f'
    },
    register = {
        label = 'Grabbing cash..',
        duration = 30000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'anim@heists@ornate_bank@grab_cash', clip = 'grab' },
        prop = { model = 'p_ld_heist_bag_s', bone = 40269, pos = vec3(0.0454, 0.2131, -0.1887), rot = vec3(66.4762, 7.2424, -71.9051) }
    },
    hackPC = {
        animDict = 'anim@heists@prison_heiststation@cop_reactions',
        animClip = 'cop_b_idle'
    },
    safe = {
        label = 'Looting safe..',
        duration = 30000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'anim@heists@ornate_bank@grab_cash', clip = 'grab' },
        prop = { model = 'p_ld_heist_bag_s', bone = 40269, pos = vec3(0.0454, 0.2131, -0.1887), rot = vec3(66.4762, 7.2424, -71.9051) }
    }
}

Config.Blip = {
    BlipName = "Shop Robbery",
    Enable = false,
    Options = {
        Sprite = 156,
        Color = 0,
        Scale = 0.9,
        Display = 4
    }
}

-- Store configs
Config.Locations = {
    Blips ={
        {coords=vec3(24.9456, -1344.9544, 29.6116), enableblip=true}, -- Innocence Blvd
        {coords=vec3(-3041.3566, 584.2665, 8.0235), enableblip=true}, -- Inseno Road
        {coords=vec3(-3244.5734, 1000.6577, 12.9453), enableblip=true},-- Barbareno Road
        {coords=vec3(1729.3294, 6417.1230, 35.1519), enableblip=true},-- Great Ocean Highway
        {coords=vec3(1698.3787, 4923.2553, 42.2410), enableblip=true},-- Grape Seed Main Street
        {coords=vec3(1959.3229, 3742.2895, 32.4584), enableblip=true},-- Alhambra Drive
        {coords=vec3(548.9014, 2668.9414, 42.2711), enableblip=true},-- Route 68
        {coords=vec3(2676.2124, 3280.9694, 55.3558), enableblip=true},-- Senora Freeway
        {coords=vec3(2554.875, 381.3857, 108.7376), enableblip=true},-- Palomino Freeway
        {coords=vec3(373.5953, 328.5891, 103.6810), enableblip=true},-- Clinton Avenue
        {coords=vec3(-1820.5584, 793.9172, 138.2765), enableblip=true}, -- North Rockford Drive
        {coords=vec3(-47.2251, -1757.5423, 29.5983), enableblip=true},-- Grove Street
        {coords=vec3(-706.7102, -913.5667, 19.3929), enableblip=true},-- Ginger Street
        {coords=vec3(1164.1452, -322.7899, 69.3824), enableblip=true},-- Mirror Park Blvd

    },
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