fx_version 'cerulean'
game 'gta5'

author 'Antigravity'
description 'Ballas Gang Depot with PIN Access'
version '1.0.0'

shared_scripts {
    'config.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png',
    'html/img/*.webp',
    'html/img/*.jpg',
    'html/img/*.jpeg',
    'html/img/*.PNG',
    'html/img/*.WEBP',
    'html/img/*.JPG',
    'html/img/*.JPEG',
    'html/img/*.gif',
    'html/img/*.ico'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-input',
    'ox_inventory',
    'hyd-keypad',
    'oxmysql'
}
