Logs = {}

-- General webhook configurations
Logs.Name = '247 Robbery' -- Name for the webhook
Logs.Image = 'https://i.ibb.co/xg69C7Z/ILTkWBh.png' -- Image for the webhook
Logs.Footer = 'https://i.ibb.co/xg69C7Z/ILTkWBh.png' -- Footer image for the webhook

Logs.Types = {
    robbery = {
        enabled = false, -- Enable this log?
        webhook = '' -- Webhook link
    },
    cooldown = {
        enabled = false,
        webhook = ''
    }
}