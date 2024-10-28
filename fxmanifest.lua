fx_version "adamant"
game "gta5"
lua54 'yes'

name         'azakit_propchecker'
version      '1.0.0'
author 'Azakit'
description 'Displays prop hashes and allows selection in-game.'

-- NUI fájlok
ui_page 'index.html'

files { 
    'index.html',
    'config.lua',
    'client.lua'
}

client_scripts {
    'locales.lua',
    'config.lua',
    'client.lua'
}