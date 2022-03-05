NGX = NGX or {};

NGX.Player = {};
NGX.Player.GetCharacters = function(cb)
	NGX.TriggerServerCallback("ngx:GetCharacters", cb);
end;

NGX.Character = {};
NGX.Character.GetJob = function(cb)
	NGX.TriggerServerCallback("ngx:GetCharacterData", cb, "job");
end;
NGX.Character.GetName = function(cb)
	NGX.TriggerServerCallback("ngx:GetCharacterData", cb, "name");
end;
NGX.Character.GetAccount = function(accountName, cb)
	NGX.TriggerServerCallback("ngx:GetCharacterData", cb, "account", accountName);
end;
NGX.Character.GetAccounts = function(cb)
	NGX.TriggerServerCallback("ngx:GetCharacterData", cb, "accounts");
end;


NGX.ShowNotification = function(msg)
	BeginTextCommandThefeedPost('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandThefeedPostTicker(0,1)
end
RegisterNetEvent('ngx:showNotification', NGX.ShowNotification);

NGX.ShowAdvancedNotification = function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	if saveToBrief == nil then saveToBrief = true end
	AddTextEntry('ngxAdvancedNotification', msg)
	BeginTextCommandThefeedPost('ngxAdvancedNotification')
	if hudColorIndex then ThefeedSetNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end
RegisterNetEvent('ngx:showAdvancedNotification', NGX.ShowAdvancedNotification);

NGX.ShowHelpNotification = function(msg, thisFrame, beep, duration)
	AddTextEntry('ngxHelpNotification', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('ngxHelpNotification', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('ngxHelpNotification')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end
RegisterNetEvent('ngx:showHelpNotification', NGX.ShowHelpNotification);

NGX.ShowFloatingHelpNotification = function(msg, coords)
	AddTextEntry('ngxFloatingHelpNotification', msg)
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp('ngxFloatingHelpNotification')
	EndTextCommandDisplayHelp(2, false, false, -1)
end