NGX = NGX or {};

local serverCallbacks = {};
local lastRequestId = 0;

local function GetAndConsumeRequestId()
    lastRequestId = lastRequestId + 1;

    if lastRequestId > 65535 then
        lastRequestId = 0;
    end

    return lastRequestId;
end

NGX.TriggerServerCallback = function(name, cb, ...)
    local requestId = GetAndConsumeRequestId();
	serverCallbacks[requestId] = cb;

	TriggerServerEvent('ngx:ServerCallbackRequest', name, requestId, ...)
end

RegisterNetEvent('ngx:ServerCallbackResponse', function(requestId, ...)
	serverCallbacks[requestId](...);
	serverCallbacks[requestId] = nil;
end)



local clientCallbacks = {};

NGX.RegisterClientCallback = function(name, cb)
    clientCallbacks[name] = cb;
end

RegisterNetEvent("esx:ClientCallbackRequest", function(name, requestId, ...)
	if clientCallbacks[name] then
		clientCallbacks[name](playerId, function(...)
			TriggerServerEvent("esx:ClientCallbackResponse", requestId, ...);
		end, ...);
	else
		print("Client callback " .. name .. " not found.");
	end
end)