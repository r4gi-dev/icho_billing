fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'icho'
description 'QBCore billing script using ox_lib'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/init.lua',
    'locales/en.lua',
    'locales/ja.lua',
    'shared/locale.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/modules/core.lua',
    'client/modules/history.lua',
    'client/modules/create.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/modules/core.lua',
    'server/modules/database.lua',
    'server/modules/payments.lua',
    'server/modules/events.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'ox_lib',
    'oxmysql'
}
