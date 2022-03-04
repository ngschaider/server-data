ESX = ESX or {};

local serverCallbacks = {};
local lastRequestId = 0;

local function GetAndConsumeRequestId()
    lastRequestId = lastRequestId + 1;

    if lastRequestId > 65535 then
        lastRequestId = 0;
    end

    return lastRequestId;
end

ESX.TriggerServerCallback = function(name, cb, ...)
    local requestId = GetAndConsumeRequestId();
	serverCallbacks[requestId] = cb;

	TriggerServerEvent('esx:ServerCallbackRequest', name, requestId, ...)
end

RegisterNetEvent('esx:ServerCallbackResponse', function(requestId, ...)
	serverCallbacks[requestId](...);
	serverCallbacks[requestId] = nil;
end)



local clientCallbacks = {};

ESX.RegisterClientCallback = function(name, cb)
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