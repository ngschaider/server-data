fx_version 'cerulean'

game 'gta5'

description 'NGX'

version '1.0.0'

server_scripts {
	'@oxmysql/lib/MySQL.lua',

	"boot/sh_modules.lua",
	"boot/sh_main.lua",
	
	--"server/callbacks.lua",
	--'server/common.lua',
	--'server/classes/player.lua',
	--'server/functions.lua',
	--'server/paycheck.lua',
	--'server/main.lua',
	--'server/commands.lua',

	--'shared/modules/math.lua',
	--'shared/modules/table.lua',
	--'shared/functions.lua'
}

client_scripts {
	"@NativeUI/NativeUI.lua",

	"boot/sh_modules.lua",
	"boot/sh_main.lua",

	--"client/callbacks.lua",
	--'client/common.lua',
	--"client/character_selection.lua",
	--'client/functions.lua',
	--'client/wrapper.lua',
	--'client/main.lua',

	--'client/modules/death.lua',
	--'client/modules/scaleform.lua',
	--'client/modules/streaming.lua',

	--'shared/modules/math.lua',
	--'shared/modules/table.lua',
	--'shared/functions.lua'
}

ui_page {
	'html/ui.html'
}

files {
	"modules.json",

	'imports.lua',
	'locale.js',
	--'html/ui.html',

	--'html/css/app.css',

	--'html/js/mustache.min.js',
	--'html/js/wrapper.js',
	--'html/js/app.js',

	--'html/fonts/pdown.ttf',
	--'html/fonts/bankgothic.ttf',

	--'html/img/accounts/bank.png',
	--'html/img/accounts/black_money.png',
	--'html/img/accounts/money.png'
}

dependencies {
	'oxmysql',
}
