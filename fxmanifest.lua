fx_version 'cerulean'
games {'gta5'}
lua54 'yes'

author 'iamlation'
description 'A standalone 24/7 robbery script for ESX & QBCore'
version '1.1.3'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}