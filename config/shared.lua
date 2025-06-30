return {

    -- 🔎 Looking for more high quality scripts?
    -- 🛒 Shop Now: https://lationscripts.com
    -- 💬 Join Discord: https://discord.gg/9EbY4nM5uu
    -- 😢 How dare you leave this option false?!
    YouFoundTheBestScripts = false,

    ----------------------------------------------
    --        🛠️ Setup the basics below
    ----------------------------------------------

    setup = {
        -- Use only if needed, directed by support or know what you're doing
        -- Notice: enabling debug features will significantly increase resmon
        -- And should always be disabled in production
        debug = false,
        -- Set your interaction system below
        -- Available options are: 'ox_target', 'qb-target', 'interact' & 'custom'
        -- 'custom' needs to be added to client/functions.lua
        interact = 'ox_target',
        -- Set your notification system below
        -- Available options are: 'lation_ui', 'ox_lib', 'esx', 'qb', 'okok', 'sd-notify', 'wasabi_notify', 'mythic_notify' & 'custom'
        -- 'custom' needs to be added to client/functions.lua
        notify = 'ox_lib',
        -- Set your progress bar system below
        -- Available options are: 'lation_ui', 'ox_lib', 'qbcore' & 'custom'
        -- 'custom' needs to be added to client/functions.lua
        -- Any custom progress bar must also support animations
        progress = 'ox_lib',
        -- Set your minigame (skillcheck) system below
        -- Available options are: 'lation_ui', 'ox_lib' & 'custom'
        minigame = 'ox_lib',
        -- Set your alert & input dialog system below
        -- Available options are: 'lation_ui', 'ox_lib' & 'custom'
        dialogs = 'ox_lib',
        -- Do you want to be notified via server console if an update is available?
        -- True if yes, false if no
        version = true,
        -- Once a store robbery has succesfully started a cooldown begins
        -- This is per-player and not a global cooldown (cooldown is in seconds)
        cooldown = 600,
        -- By default, the player-based cooldowns are overridden by this global cooldown
        -- This will prevent robberies at all stores by any player until the cooldown expires
        -- If you prefer a more flexible player-based cooldown option, just disable global
        -- The duration variable here is also in seconds like above
        global = { enable = true, duration = 600 }
    },

    ----------------------------------------------
    --        👮 Setup police options
    ----------------------------------------------

    police = {
        -- How many police must be online in order to start a robbery?
        count = 0,
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
    },

    ----------------------------------------------
    --        🏪 Setup register robbery
    ----------------------------------------------

    registers = {
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
        -- After a successful register robbery, what item(s) do you want to reward?
        -- { item = 'some_item', min = 1, max = 1, chance = 100, metadata = { ['key'] = value } }
        -- The metadata table is optional
        -- The 'item' can also be an account, such as 'cash' or 'bank'
        reward = {
            { item = 'black_money', min = 750, max = 1250, chance = 100 },
            -- { item = 'markedbills', min = 1, max = 1, chance = 100, metadata = { ['worth'] = math.random(750, 1250) } }
            -- Add or remove items as you wish following the same format
        },
        -- If a player fails to successfully lockpick the register
        -- There is a chance that their lockpick will break. In percentage,
        -- What chance do you want their lockpick to break? To never break, set 0
        -- To break every time, set 100
        breakChance = 50,
        -- After a player succesfully robs a register, there is this "noteChance" they
        -- "Find" the safe's PIN "under the register" and can skip the computer hacking
        -- Step if found. In percentage, what chance do they have to find this note?
        noteChance = 10
    },

    ----------------------------------------------
    --        🖥️ Setup computer hacking
    ----------------------------------------------

    computers = {
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
    },

    ----------------------------------------------
    --        🔐 Setup safe robbery
    ----------------------------------------------

    safes = {
        -- When a player is attempting to hack the safe (inputting the PIN) how
        -- Many attempts do you want to allow? By default, after 3 failed attempts
        -- The robbery will end and not proceed (they will not be rewarded)
        maxAttempts = 3,
        -- After a successful register robbery, what item(s) do you want to reward?
        -- { item = 'some_item', min = 1, max = 1, chance = 100, metadata = { ['key'] = value } }
        -- The metadata table is optional
        -- The 'item' can also be an account, such as 'cash' or 'bank'
        reward = {
            { item = 'black_money', min = 2000, max = 7000, chance = 100 },
            -- { item = 'markedbills', min = 1, max = 1, chance = 100, metadata = { ['worth'] = math.random(2000, 7000) } }
            -- Add or remove items as you wish following the same format
        },
    },

    ----------------------------------------------
    --     ❓ Setup optional questionnaire
    ----------------------------------------------

    questionnaire = {
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

}