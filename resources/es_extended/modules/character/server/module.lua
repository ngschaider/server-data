local utils = M("utils");
local userClass = M("user");

local CreatePlayer = function(userId, firstname, lastname, dateofbirth, height)
	local characterId = MySQL.insert.await("INSERT INTO characters (user_id, firstname, lastname, dateofbirth, height) VALUES (?, ?, ?, ?, ?)", {
		userId, firstname, lastname, dateofbirth, height
	});

	return characterId;
end;

local ConstructCharacter = function(characterId)
	local results = MySQL.prepare.await("SELECT user_id, firstname, lastname, dateofbirth, height FROM characters WHERE id=?", {characterId});

	local self = {};

	self.id = results[1].id;
	self.user = userClass.GetByPlayerId(results[1].user_id);

	self.SetPosition = function(coords)
		self.user.TriggerEvent('ngx:teleport', coords);
	end;

	self.GetPosition = function(vector)
		local ped = GetPlayerPed(self.player.id);
		return GetEntityCoords(ped);
	end;
	
	self.GetName = function()
		local results = MySQL.prepare.await("SELECT firstname, lastname FROM characters WHERE id=?", {self.id});
		return results[1].firstname .. " " .. results[1].lastname;
	end;

	return self;
end

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

module.GetByPlayerId = function(playerId)
	local user = userClass.GetByPlayerId(playerId);
	return user.GetCharacter();
end;