NGX = {}
NGX.Players = {}
NGX.Jobs = {}
Core = {}
Core.ServerCallbacks = {}
Core.TimeoutCount = -1
Core.CancelledTimeouts = {}
Core.RegisteredCommands = {}
Core.Pickups = {}
Core.PickupId = 0

AddEventHandler('ngx:getSharedObject', function(cb)
	cb(NGX);
end);

exports('getSharedObject', function()
	return NGX;
end);



MySQL.ready(function()
	print('[^2INFO^7] ^5NGX^0 initialized')
	StartPayCheck()
end)

RegisterServerEvent('ngx:clientLog', function(msg)
	print(("[^2TRACE^7] %s^7"):format(msg))
end)

