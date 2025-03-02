fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Your Name'
description 'Vehicle Black Market Script for FiveM'
version '2.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/scripts.js',
    'html/styles.css'
}

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'vehiclelist.lua',
    'server.lua'
}

data_file 'DLC_ITYP_REQUEST' 'stream/ytyp/*'