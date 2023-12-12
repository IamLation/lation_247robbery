fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'iamlation'
description 'A 24/7 robbery script for FiveM'
version '1.2.0'

client_scripts {
    'bridge/client.lua',
    'client/*.lua'
}

server_scripts {
    'bridge/server.lua',
    'server/*.lua'
}

shared_scripts {
    'config.lua',
    'strings.lua',
    '@ox_lib/init.lua'
}