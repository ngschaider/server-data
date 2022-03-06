local utils = M("utils");
local callbacks = M("callbacks");

NGX.Players = {};

callbacks.RegisterServerCallback("ngx:GetCharacterData", function(clientId, cb, key, ...)
	local player = NGX.GetPlayerFromId(clientId);

	if not player.character then 
		cb(nil);
		return;
	end

	local whitelist = {"job", "name", "account", "accounts"};

	if not utils.table.Contains(whitelist, key) then
		return;
	end

	-- concatenate "get" and `key` with the first letter uppercased
	local functionName = "get" .. key:gsub("^%l", string.upper);

	cb(player.character[functionName](...));
end);

module.create = function()
    local playerId = MySQL.insert.await("INSERT INTO players (identifier) VALUES (?)", {identifier});

	return playerId;
end



local constructPlayer = function(clientId)
	local identifier = utils.GetIdentifier(playerId);

	local results = MySQL.prepare.await("SELECT id, identifier FROM players WHERE identifier=?", {identifier});
	if #results > 0 then
		self.id = results[1].id;
	else
		self.id = CreatePlayer(clientId);
	end

	local self = {};
	self.identifier = identifier;
	self.clientId = clientId;
	self.character = nil; -- the character the user is currently logged into

	self.triggerEvent = function(eventName, ...)
		TriggerClientEvent(eventName, self.clientId, ...);
	end;
	
	self.setCharacter = function(character)
		self.character = character;
	end;
	
	self.getCurrentCharacter = function()
		return self.character;
	end;

	self.getCharacters = function()
		local characters = MySQL.prepare.await("SELECT * FROM characters WHERE player_id=?", {self.id});
	end;

	self.kick = function(reason)
		DropPlayer(self.clientId, reason);
	end;

	self.getIdentifier = function()
		return self.identifier;
	end;

	self.showNotification = function(msg)
		self.triggerEvent('ngx:showNotification', msg)
	end;

	self.showHelpNotification = function(msg, thisFrame, beep, duration)
		self.triggerEvent('ngx:showHelpNotification', msg, thisFrame, beep, duration)
	end;

	return self;
end
