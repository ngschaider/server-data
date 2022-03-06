local serverCallbacks = {};
local lastRequestId = 0;

local GetAndConsumeRequestId = function()
    lastRequestId = lastRequestId + 1;

    if lastRequestId > 65535 then
        lastRequestId = 0;
    end

	if serverCallbacks[lastRequestId] then
		print("overriding server callback with request id " .. lastRequestId);
	end

    return lastRequestId;
end;

module.TriggerServerCallback = function(name, cb, ...)
    local requestId = GetAndConsumeRequestId();
	serverCallbacks[requestId] = cb;

	TriggerServerEvent('ngx:ServerCallbackRequest', name, requestId, ...);
end;

RegisterNetEvent('ngx:ServerCallbackResponse', function(requestId, ...)
	serverCallbacks[requestId](...);
	serverCallbacks[requestId] = nil;
end);


local clientCallbacks = {};

module.RegisterClientCallback = function(name, cb)
    clientCallbacks[name] = cb;
end;

RegisterNetEvent("ngx:ClientCallbackRequest", function(name, requestId, ...)
	if clientCallbacks[name] then
		clientCallbacks[name](playerId, function(...)
			TriggerServerEvent("ngx:ClientCallbackResponse", requestId, ...);
		end, ...);
	else
		print("Client callback " .. name .. " not found.");
	end
end);