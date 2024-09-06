Logs = {}

-- What logging service do you want to use?
-- Available options: 'fivemanage', 'fivemerr', 'discord' & 'none'
-- It is highly recommended to use a proper logging service such as Fivemanage or Fivemerr
Logs.Service = 'none'

-- Do you want to include screenshots with your logs?
-- This is only applicable to Fivemanage and Fivemerr
Logs.Screenshots = false

-- You can enable (true) or disable (false) specific player events to log here
Logs.Events = {
    -- register_robbed is when a register has been robbed.. shocker, right?
    register_robbed = false,
    -- safe_robbed is when.. come on now, you gotta know..
    safe_robbed = false
}

-- If Logs.Service = 'discord', you can customize the webhook data here
-- If not using Discord, this section can be ignored
Logs.Discord = {
    -- The name of the webhook
    name = '24/7 Robbery Logs',
    -- The webhook link
    link = '',
    -- The webhook profile image
    image = 'https://i.imgur.com/ILTkWBh.png',
    -- The webhook footer image
    footer = 'https://i.imgur.com/ILTkWBh.png'
}