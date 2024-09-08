fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'iamlation'
description 'FiveM\'s most popular 24/7 store robbery script'
version '1.4.1'

client_scripts {
    'bridge/client.lua',
    'client/*.lua'
}

server_scripts {
    'bridge/server.lua',
    'server/*.lua',
    'logs.lua'
}

shared_scripts {
    'config.lua',
    'strings.lua',
    '@ox_lib/init.lua'
}