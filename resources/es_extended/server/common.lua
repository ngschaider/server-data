NGX = {}
NGX.Players = {}
NGX.Jobs = {}
Core = {}
Core.RegisteredCommands = {}

MySQL.ready(function()
	print('[^2INFO^7] ^5NGX^0 initialized')
	StartPayCheck()
end)

RegisterServerEvent('ngx:clientLog', function(msg)
	print(("[^2TRACE^7] %s^7"):format(msg))
end)

