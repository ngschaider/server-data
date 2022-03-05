NGX = NGX or {};

local serverCallbacks = {};

NGX.RegisterServerCallback = function(name, cb)
	serverCallbacks[name] = cb;
end

RegisterNetEvent('esx:ServerCallbackRequest', function(name, requestId, ...)
	local playerId = source;

	if serverCallbacks[name] then
		serverCallbacks[name](playerId, function(...)
			TriggerClientEvent('esx:ServerCallbackResponse', playerId, requestId, ...);
		end, ...);
	else
		print("Server callback " .. name .. " not found.");
	end
end)


local clientCallbacks = {};
local lastRequestId = 0;

local function GetAndConsumeRequestId()
    lastRequestId = lastRequestId + 1;

    if lastRequestId > 65535 then
        lastRequestId = 0;
    end

    return lastRequestId;
end

NGX.TriggerClientCallback = function(name, clientId, cb, ...)
    local requestId = GetAndConsumeRequestId();
	clientCallbacks[requestId] = cb;

	TriggerClientEvent("esx:ClientCallbackRequest", clientId, name, requestId, ...)
end;

RegisterNetEvent("esx:ClientCallbackResponse", function(requestId, ...)
	clientCallbacks[requestId](...);
	clientCallbacks[requestId] = nil;
end)
