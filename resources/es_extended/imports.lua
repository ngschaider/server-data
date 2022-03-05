NGX = exports['es_extended']:getSharedObject()

if not IsDuplicityVersion() then -- Only register this event for the client
	AddEventHandler('ngx:setPlayerData', function(key, val, last)
		if GetInvokingResource() == 'es_extended' then
			NGX.PlayerData[key] = val
			if OnPlayerData ~= nil then OnPlayerData(key, val, last) end
		end
	end)
end