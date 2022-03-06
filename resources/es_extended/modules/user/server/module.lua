local utils = M("utils");
local callbacks = M("callbacks");

local users = {};

local CreateUser = function()
    local userId = MySQL.insert.await("INSERT INTO players (identifier) VALUES (?)", {identifier});

	return ConstructUser(userId);
end

local ConstructUser = function(userId)
	local self = {};

	local results = MySQL.prepare.await("SELECT identifier FROM players WHERE id=?", {userId});

	self.identifier = results[1].identifier;
	self.id = userId;
	self.character = nil;

	self.TriggerEvent = function(eventName, ...)
		TriggerClientEvent(eventName, self.playerId, ...);
	end;
	
	self.SetCharacter = function(character)
		self.character = character;
	end;
	
	self.GetCurrentCharacter = function()
		return self.character;
	end;

	self.GetCharacters = function()
		return MySQL.prepare.await("SELECT * FROM characters WHERE user_id=?", {self.id});
	end;

	self.Kick = function(reason)
		DropPlayer(self.playerId, reason);
	end;

	self.GetIdentifier = function()
		return self.identifier;
	end;

	self.ShowNotification = function(msg)
		self.TriggerEvent('ngx:ShowNotification', msg)
	end;

	self.ShowHelpNotification = function(msg, thisFrame, beep, duration)
		self.TriggerEvent('ngx:ShowHelpNotification', msg, thisFrame, beep, duration)
	end;

	return self;
end;

module.GetByUserId = function(userId)
	if not players[userId] then
		players[userId] = ConstructPlayer(userId);
	end

	return players[userId];
end;

module.GetByIdentifier = function(identifier)
	local results = MySQL.prepare.await("SELECT id FROM users WHERE identifier=?", {identifier});

	if utils.table.Size(results) > 0 then
		return module.GetByUserId(results[1].id);
	else
		return CreatePlayer(identifier);
	end
end;

module.GetByPlayerId = function(playerId)
	local identifier = utils.GetIdentifier(playerId);
	return module.GetByIdentifier(identifier);
end;