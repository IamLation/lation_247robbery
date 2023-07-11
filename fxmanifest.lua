fx_version 'cerulean'
games {'gta5'}
lua54 'yes'

author 'iamlation'
description 'A standalone 24/7 robbery script for FiveM'
version '1.1.2'

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