Strings = {}

Strings.Notify = {
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

Strings.Target = {
    registerLabel = 'Rob register',
    registerIcon = 'fas fa-lock',
    computerLabel = 'Login',
    computerIcon = 'fas fa-computer',
    safeLabel = 'Unlock',
    safeIcon = 'fas fa-key'
}

Strings.AlertDialog = {
    registerHeader = 'Note Found',
    registerContent = 'You found an interesting note under the register with nothing but the following numbers written on it: ',
    registerCancelButton = 'Who Cares?',
    registerConfirmButton = 'Got it',
    computerHeader = 'Code Exposed',
    computerContent = 'You successfully hacked the computer and find the following code: ',
    computerConfirmButton = 'Got it'
}

Strings.InputDialog = {
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

Strings.Logs = {
    colors = {
        green = 65280,
        red = 16711680,
        yellow = 16776960,
    },
    labels = {
        name = '**Player Name**: ',
        id = '\n **Player ID**: ',
        identifier = '\n **Identifier**: ',
        message = '\n **Message**: '
    },
    titles = {
        robbery = 'Robbery',
        cooldownA = '🔒 Cooldown Active',
        cooldownI = '🔓 Cooldown Inactive'
    },
    messages = {
        minutes = 'minutes',
        robbery = ' Has successfully completed a robbery and has received: ',
        cooldownRA = 'The register cooldown is now active for ',
        cooldownRI = 'The register cooldown is now inactive',
        cooldownSA = 'The safe cooldown is now active for ',
        cooldownSI = 'The safe cooldown is now inactive'
    }
}