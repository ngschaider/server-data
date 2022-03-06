local pool = NativeUI.CreatePool();

RegisterNetEvent("ngx:OnPlayerJoined", function()
	print("ngx:OnPlayerJoined");
	
	local player = PlayerId();

	local model = "mp_m_freemode_01";
	RequestModel(model);
	while not HasModelLoaded(model) do
		--print("waiting for model to load");
		Citizen.Wait(0);
	end
	
	SetPlayerModel(player, model);
	SetModelAsNoLongerNeeded(model);
	
	local ped = PlayerPedId();
	SetPedDefaultComponentVariation(ped);
	
	FreezeEntityPosition(ped, true);

	local pos = {
		x = 402.86, 
		y = -996.74, 
		z = -99.0, 
	};

	SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, false, false, false, true);
	SetEntityRotation(ped, 0.0, 0.0, 180.0, 1);
	
	RequestCollisionAtCoord(pos.x, pos.y, pos.z);
	while not HasCollisionLoadedAroundEntity(ped) do
		--print("waiting for collision to load", ped, PlayerPedId());
		Citizen.Wait(0);
	end

	ClearPedTasksImmediately(ped);
	
	SetPlayerControl(player, false);
	FreezeEntityPosition(ped, false);
	
	--print("setting up camera");
	
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA");
	SetCamFov(cam, 70.0);
	SetCamCoord(cam, 402.99, -999.01, -98.0);
    PointCamAtCoord(cam, pos.x, pos.y, pos.z);
    SetCamActive(cam, true);
	RenderScriptCams(true);
	
	ShutdownLoadingScreen();
	--print("ShutdownLoadingScreen");
	
	NGX.GetCharacters(function(characters)
		local menu = NativeUI.CreateMenu("Charakterauswahl");
		pool:Add(menu);
		
		for k,v in pairs(characters) do
			local item = NativeUI.CreateItem(v.firstname .. " " .. v.lastname);
			menu:AddItem(item);
		end
		
		local createCharacterItem = NativeUI.CreateItem("^4Charakter erstellen");
		menu:AddItem(createCharacterItem);
	end);
end);

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  
  if cam then
	--print("destroying camera");
	DestroyCam(cam, true);
  end
end)