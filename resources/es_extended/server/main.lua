SetMapName('San Andreas')
SetGameType('NGX')

ESX = {};
ESX.Players = {};

RegisterNetEvent('ngx:OnPlayerJoined', function()
	local clientId = source;
	ESX.Players[clientId] = ConstructPlayer(clientId);
end)

RegisterNetEvent("ngx:OnCharacterSwitched", function(clientId, characterId)
	if characterId then
		ESX.Players[player].character = ConstructCharacter(clientId, characterId);
	else
		ESX.Players[player].character = nil;
	end
end);

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
	deferrals.defer()
	local clientId = source;
	local identifier = ESX.GetIdentifier(playerId);

	if identifier then
		if ESX.GetPlayerFromIdentifier(identifier) then
			deferrals.done(('There was an error loading your character!\nError code: identifier-active\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same account.\n\nYour identifier: %s'):format(identifier))
		else
			deferrals.done()
		end
	else
		deferrals.done('There was an error loading your character!\nError code: identifier-missing\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.')
	end
end)

ESX.RegisterServerCallback("ngx:GetPlayerData", function(clientId, cb, key, ...)
	local player = ESX.GetPlayerFromId(clientId);
	
	local whitelist = {"characters"};

	if not ESX.Table.Contains(whitelist, key) then
		return;
	end

	-- concatenate "get" and `key` with the first letter uppercased
	local functionName = "get" .. key:gsub("^%l", string.upper);

	cb(player[functionName](...));
end);

ESX.RegisterServerCallback("ngx:GetCharacterData", function(clientId, cb, key, ...)
	local player = ESX.GetPlayerFromId(clientId);

	if not player.character then 
		cb(nil);
		return;
	end

	local whitelist = {"job", "name", "account", "accounts"};

	if not ESX.Table.Contains(whitelist, key) then
		return;
	end

	-- concatenate "get" and `key` with the first letter uppercased
	local functionName = "get" .. key:gsub("^%l", string.upper);

	cb(player.character[functionName](...));
end);