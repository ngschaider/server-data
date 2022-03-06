local serverCallbacks = {};

module.RegisterServerCallback = function(name, cb)
	serverCallbacks[name] = cb;
end

RegisterNetEvent('ngx:ServerCallbackRequest', function(name, requestId, ...)
	local playerId = source;

	if serverCallbacks[name] then
		serverCallbacks[name](playerId, function(...)
			TriggerClientEvent('ngx:ServerCallbackResponse', playerId, requestId, ...);
		end, ...);
	else
		print("Server callback " .. name .. " not found.");
	end
end)


local clientCallbacks = {};
local lastRequestId = 0;

local GetAndConsumeRequestId = function()
    lastRequestId = lastRequestId + 1;

    if lastRequestId > 65535 then
        lastRequestId = 0;
    end

	if clientCallbacks[lastRequestId] then
		print("overriding client callback with request id " .. lastRequestId);
	end

    return lastRequestId;
end

module.TriggerClientCallback = function(name, clientId, cb, ...)
    local requestId = GetAndConsumeRequestId();
	clientCallbacks[requestId] = cb;

	TriggerClientEvent("ngx:ClientCallbackRequest", clientId, name, requestId, ...)
end;

RegisterNetEvent("ngx:ClientCallbackResponse", function(requestId, ...)
	clientCallbacks[requestId](...);
	clientCallbacks[requestId] = nil;
end)
