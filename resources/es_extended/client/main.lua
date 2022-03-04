local pickups = {}

Citizen.CreateThread(function()
	while true do
		InvalidateIdleCam()
		InvalidateVehicleIdleCam()
		Wait(1000) --The idle camera activates after 30 second so we don't need to call this per frame
	end
end)

local cam = nil;

Citizen.CreateThread(function()
    while true do
		if NetworkIsSessionStarted() then
			TriggerServerEvent("ngx:OnPlayerJoined");
			TriggerEvent("ngx:OnPlayerJoined");
			return; -- break the loop
		end
		Citizen.Wait(100)
    end
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer, isNew, skin)
	FreezeEntityPosition(PlayerPedId(), true)
		
	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')
	
	TriggerEvent('skinchanger:loadSkin', skin)

	TriggerEvent('esx:loadingScreenOff')
	ShutdownLoadingScreen()
	ShutdownLoadingScreenNui()
	FreezeEntityPosition(ESX.PlayerData.ped, false)
	
	SetCanAttackFriendly(PlayerPedId(), true, false);
	NetworkSetFriendlyFireOption(true);
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
end)

RegisterNetEvent('esx:setMaxWeight')
AddEventHandler('esx:setMaxWeight', function(newMaxWeight) 
	ESX.PlayerData.maxWeight = newMaxWeight 
end)

local function onPlayerSpawn()
	if ESX.PlayerLoaded then
		ESX.SetPlayerData('ped', PlayerPedId())
		ESX.SetPlayerData('dead', false)
	end
end

AddEventHandler('playerSpawned', onPlayerSpawn)
AddEventHandler('esx:onPlayerSpawn', onPlayerSpawn)

AddEventHandler('esx:onPlayerDeath', function()
	ESX.SetPlayerData('ped', PlayerPedId())
	ESX.SetPlayerData('dead', true)
end)

AddEventHandler('skinchanger:modelLoaded', function()
	while not ESX.PlayerLoaded do
		Wait(100)
	end
	TriggerEvent('esx:restoreLoadout')
end)

AddEventHandler('esx:restoreLoadout', function()
	ESX.SetPlayerData('ped', PlayerPedId());
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for k,v in ipairs(ESX.PlayerData.accounts) do
		if v.name == account.name then
			ESX.PlayerData.accounts[k] = account
			break
		end
	end

	ESX.SetPlayerData('accounts', ESX.PlayerData.accounts)
end)

RegisterNetEvent('esx:teleport')
AddEventHandler('esx:teleport', function(coords)
	ESX.Game.Teleport(ESX.PlayerData.ped, coords)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
	ESX.SetPlayerData('job', Job)
end)

RegisterNetEvent('esx:spawnVehicle')
AddEventHandler('esx:spawnVehicle', function(vehicle)
	ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
		if admin then
			local model = (type(vehicle) == 'number' and vehicle or GetHashKey(vehicle))

			if IsModelInCdimage(model) then
				local playerCoords, playerHeading = GetEntityCoords(ESX.PlayerData.ped), GetEntityHeading(ESX.PlayerData.ped)

				ESX.Game.SpawnVehicle(model, playerCoords, playerHeading, function(vehicle)
					TaskWarpPedIntoVehicle(ESX.PlayerData.ped, vehicle, -1)
				end)
			else
				ESX.ShowNotification('Invalid vehicle model.')
			end
		end
	end)
end)

RegisterNetEvent('esx:registerSuggestions')
AddEventHandler('esx:registerSuggestions', function(registeredCommands)
	for name,command in pairs(registeredCommands) do
		if command.suggestion then
			TriggerEvent('chat:addSuggestion', ('/%s'):format(name), command.suggestion.help, command.suggestion.arguments)
		end
	end
end)

RegisterNetEvent('esx:deleteVehicle')
AddEventHandler('esx:deleteVehicle', function(radius)
	if radius and tonumber(radius) then
		radius = tonumber(radius) + 0.01
		local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(ESX.PlayerData.ped), radius)

		for k,entity in ipairs(vehicles) do
			local attempt = 0

			while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
				Wait(100)
				NetworkRequestControlOfEntity(entity)
				attempt = attempt + 1
			end

			if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
				ESX.Game.DeleteVehicle(entity)
			end
		end
	else
		local vehicle, attempt = ESX.Game.GetVehicleInDirection(), 0

		if IsPedInAnyVehicle(ESX.PlayerData.ped, true) then
			vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
		end

		while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
			Wait(100)
			NetworkRequestControlOfEntity(vehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
			ESX.Game.DeleteVehicle(vehicle)
		end
	end
end)

-- disable wanted level
ClearPlayerWantedLevel(PlayerId())
SetMaxWantedLevel(0)

----- Admin commnads from esx_adminplus

RegisterNetEvent("esx:tpm")
AddEventHandler("esx:tpm", function()
local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local GetGroundZFor_3dCoord = GetGroundZFor_3dCoord

	ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
		if admin then
			local blipMarker = GetFirstBlipInfoId(8)
			if not DoesBlipExist(blipMarker) then
					ESX.ShowNotification('No Waypoint Set.', true, false, 140)
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
					ESX.ShowNotification('Successfully Teleported', true, false, 140)
			end
	
			-- If Z coord was found, set coords in found coords.
			SetPedCoordsKeepVehicle(ped, x, y, groundZ)
			ESX.ShowNotification('Successfully Teleported', true, false, 140)
		end
	end)
end)

local noclip = false
RegisterNetEvent("esx:noclip")
AddEventHandler("esx:noclip", function(input)
	ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
		if admin then
    local player = PlayerId()

    local msg = "disabled"
	if(noclip == false)then
		noclip_pos = GetEntityCoords(ESX.PlayerData.ped, false)
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
			SetEntityCoordsNoOffset(ESX.PlayerData.ped, noclip_pos.x, noclip_pos.y, noclip_pos.z, 0, 0, 0)

			if(IsControlPressed(1, 34))then
				heading = heading + 1.5
				if(heading > 360)then
					heading = 0
				end

				SetEntityHeading(ESX.PlayerData.ped, heading)
			end

			if(IsControlPressed(1, 9))then
				heading = heading - 1.5
				if(heading < 0)then
					heading = 360
				end

				SetEntityHeading(ESX.PlayerData.ped, heading)
			end

			if(IsControlPressed(1, 8))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, 1.0, 0.0)
			end

			if(IsControlPressed(1, 32))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, -1.0, 0.0)
			end

			if(IsControlPressed(1, 27))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, 0.0, 1.0)
			end

			if(IsControlPressed(1, 173))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(ESX.PlayerData.ped, 0.0, 0.0, -1.0)
			end
		else
			Wait(200)
		end
	end
end)

RegisterNetEvent("esx:killPlayer")
AddEventHandler("esx:killPlayer", function()
  SetEntityHealth(ESX.PlayerData.ped, 0)
end)

RegisterNetEvent("esx:freezePlayer")
AddEventHandler("esx:freezePlayer", function(input)
    local player = PlayerId()
    if input == 'freeze' then
        SetEntityCollision(ESX.PlayerData.ped, false)
        FreezeEntityPosition(ESX.PlayerData.ped, true)
        SetPlayerInvincible(player, true)
    elseif input == 'unfreeze' then
        SetEntityCollision(ESX.PlayerData.ped, true)
	    FreezeEntityPosition(ESX.PlayerData.ped, false)
        SetPlayerInvincible(player, false)
    end
end)