Strings = {}

Strings.Notify = {
    registerCooldown = 'Stores cannot be robbed this often - please wait and try again later',
    notEnoughPolice = 'There are not enough police in the city',
    missingItem = 'I think this would be easier with a tool..',
    lockpickBroke = 'You broke the lockpick and failed to open the register',
    robberyCancel = 'You stop robbing the register',
    failedHack = 'You failed hacking into the computer',
    wrongPin = 'You input the wrong pin and the safe remains locked',
    errorOccured = 'Something went wrong - please try again',
    tooManyHackFails = 'You\'ve failed to hack the computer too many times and failed robbing the store',
    tooManySafeFails = 'You\'ve input the wrong PIN too many times and failed robbing the safe'
}

Strings.Target = {
    registers = {
        label = 'Rob register',
        icon = 'fas fa-lock'
    },
    computers = {
        label = 'Login',
        icon = 'fas fa-computer'
    },
    safes = {
        label = 'Unlock',
        icon = 'fas fa-key'
    }
}

Strings.AlertDialog = {
    noteFound = {
        header = '**Note Found**',
        content = 'You found an interesting note under the register with nothing but the following numbers written on it: %s',
        labels = { confirm = 'Got it!' }
    },
    hacked = {
        header = '**Code Exposed**',
        content = 'You successfully hacked the computer and find the following code: %s',
        labels = { confirm = 'Got it!' }
    }
}

Strings.InputDialog = {
    questionsHeader = 'Security Questions',
    safeHeader = 'Store Safe',
    safe = {
        type = 'input', -- Do not edit
        label = 'Enter PIN',
        description = 'Input the PIN to unlock the safe',
        placeholder = '6969',
        icon = 'fas fa-lock',
        required = true -- Do not edit
    }
}

Strings.Logs = {
    register_robbed = {
        title = 'Register Robbed',
        message = '%s (identifier: %s) has successfully robbed a register for $%s'
    },
    safe_robbed = {
        title = 'Safe Robbed',
        message = '%s (identifier: %s) has successfully robbed a safe for $%s'
    }
}