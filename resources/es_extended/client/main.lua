local game = M("game");

local cam = nil;

RegisterNetEvent('ngx:playerLoaded', function(xPlayer, isNew, skin)
	FreezeEntityPosition(PlayerPedId(), true)
		
	TriggerServerEvent('ngx:onPlayerSpawn')
	TriggerEvent('ngx:onPlayerSpawn')
	
	TriggerEvent('skinchanger:loadSkin', skin)

	TriggerEvent('ngx:loadingScreenOff')
	ShutdownLoadingScreen()
	ShutdownLoadingScreenNui()
	FreezeEntityPosition(PlayerPedId(), false)
	
	SetCanAttackFriendly(PlayerPedId(), true, false);
	NetworkSetFriendlyFireOption(true);
end)

RegisterNetEvent('ngx:onPlayerLogout', function()
	NGX.PlayerLoaded = false
end)

AddEventHandler('playerSpawned', onPlayerSpawn)
AddEventHandler('ngx:onPlayerSpawn', onPlayerSpawn)

RegisterNetEvent('ngx:teleport', function(coords)
	game.Teleport(PlayerPedId(), coords)
end)

RegisterNetEvent('ngx:spawnVehicle', function(vehicle)
	NGX.TriggerServerCallback("ngx:isUserAdmin", function(admin)
		if admin then
			local model = (type(vehicle) == 'number' and vehicle or GetHashKey(vehicle))

			if IsModelInCdimage(model) then
				local ped = PlayerPedId();

				local playerCoords = GetEntityCoords(ped);
				local playerHeading = GetEntityHeading(ped);

				game.SpawnVehicle(model, playerCoords, playerHeading, function(vehicle)
					TaskWarpPedIntoVehicle(ped, vehicle, -1)
				end)
			else
				NGX.ShowNotification('Invalid vehicle model.')
			end
		end
	end)
end)

RegisterNetEvent('ngx:registerSuggestions', function(registeredCommands)
	for name,command in pairs(registeredCommands) do
		if command.suggestion then
			TriggerEvent('chat:addSuggestion', ('/%s'):format(name), command.suggestion.help, command.suggestion.arguments)
		end
	end
end)

RegisterNetEvent('ngx:deleteVehicle', function(radius)
	if radius and tonumber(radius) then
		radius = tonumber(radius) + 0.01
		local vehicles = NGX.Game.GetVehiclesInArea(GetEntityCoords(PlayerPedId()), radius)

		for k,entity in ipairs(vehicles) do
			local attempt = 0

			while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
				Wait(100)
				NetworkRequestControlOfEntity(entity)
				attempt = attempt + 1
			end

			if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
				NGX.Game.DeleteVehicle(entity)
			end
		end
	else
		local vehicle, attempt = NGX.Game.GetVehicleInDirection(), 0

		if IsPedInAnyVehicle(PlayerPedId(), true) then
			vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
		end

		while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
			Wait(100)
			NetworkRequestControlOfEntity(vehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
			NGX.Game.DeleteVehicle(vehicle)
		end
	end
end)

-- disable wanted level
ClearPlayerWantedLevel(PlayerId())
SetMaxWantedLevel(0)

----- Admin commnads from ngx_adminplus

RegisterNetEvent("ngx:tpm", function()
	local PlayerPedId = PlayerPedId
	local GetEntityCoords = GetEntityCoords
	local GetGroundZFor_3dCoord = GetGroundZFor_3dCoord

	NGX.TriggerServerCallback("ngx:isUserAdmin", function(admin)
		if admin then
			local blipMarker = GetFirstBlipInfoId(8)
			if not DoesBlipExist(blipMarker) then
					NGX.ShowNotification('No Waypoint Set.', true, false, 140)
					return 'marker'
			end
	
			-- Fade screen to hide how clients get teleported.
			DoScreenFadeOut(650)
			while not IsScreenFadedOut() do
					Wait(0)
			end
	
			local ped, coords = PlayerPedId(), GetBlipInfoIdCoord(blipMarker)
			local vehicle = GetVehiclePedIsIn(ped, false)
			local oldCoords = GetEntityCoords(ped)
	
			-- Unpack coords instead of having to unpack them while iterating.
			-- 825.0 seems to be the max a player can reach while 0.0 being the lowest.
			local x, y, groundZ, Z_START = coords['x'], coords['y'], 850.0, 950.0
			local found = false
			if vehicle > 0 then
					FreezeEntityPosition(vehicle, true)
			else
					FreezeEntityPosition(ped, true)
			end
	
			for i = Z_START, 0, -25.0 do
					local z = i
					if (i % 2) ~= 0 then
							z = Z_START - i
					end
	
					NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
					local curTime = GetGameTimer()
					while IsNetworkLoadingScene() do
							if GetGameTimer() - curTime > 1000 then
									break
							end
							Wait(0)
					end
					NewLoadSceneStop()
					SetPedCoordsKeepVehicle(ped, x, y, z)
	
					while not HasCollisionLoadedAroundEntity(ped) do
							RequestCollisionAtCoord(x, y, z)
							if GetGameTimer() - curTime > 1000 then
									break
							end
							Wait(0)
					end
	
					-- Get ground coord. As mentioned in the natives, this only works if the client is in render distance.
					found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
					if found then
							Wait(0)
							SetPedCoordsKeepVehicle(ped, x, y, groundZ)
							break
					end
					Wait(0)
			end
	
			-- Remove black screen once the loop has ended.
			DoScreenFadeIn(650)
			if vehicle > 0 then
					FreezeEntityPosition(vehicle, false)
			else
					FreezeEntityPosition(ped, false)
			end
	
			if not found then
					-- If we can't find the coords, set the coords to the old ones.
					-- We don't unpack them before since they aren't in a loop and only called once.
					SetPedCoordsKeepVehicle(ped, oldCoords['x'], oldCoords['y'], oldCoords['z'] - 1.0)
					NGX.ShowNotification('Successfully Teleported', true, false, 140)
			end
	
			-- If Z coord was found, set coords in found coords.
			SetPedCoordsKeepVehicle(ped, x, y, groundZ)
			NGX.ShowNotification('Successfully Teleported', true, false, 140)
		end
	end)
end)

local noclip = false
RegisterNetEvent("ngx:noclip", function(input)
	NGX.TriggerServerCallback("ngx:isUserAdmin", function(admin)
		if admin then
			local player = PlayerId()

			local msg = "disabled"
			if(noclip == false)then
				noclip_pos = GetEntityCoords(PlayerPedId(), false)
			end

			noclip = not noclip

			if(noclip)then
				msg = "enabled"
			end

			TriggerEvent("chatMessage", "Noclip has been ^2^*" .. msg)
		end
	end)
end)

local heading = 0
CreateThread(function()
	while true do
		Wait(0)

		if(noclip)then
			SetEntityCoordsNoOffset(PlayerPedId(), noclip_pos.x, noclip_pos.y, noclip_pos.z, 0, 0, 0)

			if(IsControlPressed(1, 34))then
				heading = heading + 1.5
				if(heading > 360)then
					heading = 0
				end

				SetEntityHeading(PlayerPedId(), heading)
			end

			if(IsControlPressed(1, 9))then
				heading = heading - 1.5
				if(heading < 0)then
					heading = 360
				end

				SetEntityHeading(PlayerPedId(), heading)
			end

			if(IsControlPressed(1, 8))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.0)
			end

			if(IsControlPressed(1, 32))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -1.0, 0.0)
			end

			if(IsControlPressed(1, 27))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, 1.0)
			end

			if(IsControlPressed(1, 173))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -1.0)
			end
		else
			Wait(200)
		end
	end
end)

RegisterNetEvent("ngx:killPlayer", function()
  SetEntityHealth(PlayerPedId(), 0)
end)

RegisterNetEvent("ngx:freezePlayer", function(input)
    local player = PlayerId();
	local playerPed = PlayerPedId();

    if input == "freeze" then
        SetEntityCollision(playerPed, false)
        FreezeEntityPosition(playerPed, true)
        SetPlayerInvincible(player, true)
    elseif input == "unfreeze" then
        SetEntityCollision(playerPed, true)
	    FreezeEntityPosition(playerPed, false)
        SetPlayerInvincible(player, false)
    end
end)