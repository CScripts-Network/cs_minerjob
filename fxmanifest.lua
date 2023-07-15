fx_version 'adamant'
game 'gta5'
lua54 'yes'
version '1.0.0'

server_scripts({
	'config/config.lua',
	'server/main.lua',
	'config/translations.lua',
})

client_scripts({
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'config/config.lua',
	'client/main.lua',
	'config/translations.lua',
})

dependencies {
	'cs_lib'
}
