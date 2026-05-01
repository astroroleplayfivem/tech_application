fx_version 'cerulean'
games { 'gta5' }

author 'TshentroTech & Opie Winters'
description 'Job Application Form'
version '2.0.0'

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua",
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/styles.css',
    'ui/script.js',
    'ui/translations.js',
}

lua54 "yes"
