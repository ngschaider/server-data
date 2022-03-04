ESX = {}
ESX.Players = {}
ESX.Jobs = {}
ESX.Items = {}
Core = {}
Core.UsableItemsCallbacks = {}
Core.ServerCallbacks = {}
Core.TimeoutCount = -1
Core.CancelledTimeouts = {}
Core.RegisteredCommands = {}
Core.Pickups = {}
Core.PickupId = 0

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX);
end);

exports('getSharedObject', function()
	return ESX;
end);



MySQL.ready(function()
	print('[^2INFO^7] ^5NGX^0 initialized')
	StartPayCheck()
end)

RegisterServerEvent('esx:clientLog', function(msg)
	print(("[^2TRACE^7] %s^7"):format(msg))
end)

