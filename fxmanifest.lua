fx_version 'cerulean'
game 'gta5'

name "Brazzers Nitrous"
author "Brazzers Development | MannyOnBrazzers#6826"
version "1.0"

lua54 'yes'

ui_page 'html/index.html'

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

shared_scripts {
	'@qb-core/shared/locale.lua',
	'locales/*.lua',
	'shared/*.lua',
}

files {
    'html/*',
}

escrow_ignore {
    'client/*.lua',
	'server/*.lua',
	'locales/*.lua',
	'shared/*.lua',
	'README/*lua',
}