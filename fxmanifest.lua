fx_version 'cerulean'
games {'gta5'}
lua54 'yes'

author 'iamlation'
description 'A 24/7 robbery script for FiveM'
version '1.1.0'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}