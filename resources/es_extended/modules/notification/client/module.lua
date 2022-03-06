module.ShowNotification = function(msg)
	BeginTextCommandThefeedPost('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandThefeedPostTicker(0,1)
end
RegisterNetEvent('ngx:ShowNotification', NGX.ShowNotification);

module.ShowAdvancedNotification = function(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	if saveToBrief == nil then saveToBrief = true end
	AddTextEntry('ngxAdvancedNotification', msg)
	BeginTextCommandThefeedPost('ngxAdvancedNotification')
	if hudColorIndex then ThefeedSetNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end
RegisterNetEvent('ngx:ShowAdvancedNotification', NGX.ShowAdvancedNotification);

module.ShowHelpNotification = function(msg, thisFrame, beep, duration)
	AddTextEntry('ngxHelpNotification', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('ngxHelpNotification', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('ngxHelpNotification')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end
RegisterNetEvent('ngx:ShowHelpNotification', NGX.ShowHelpNotification);

module.ShowFloatingHelpNotification = function(msg, coords)
	AddTextEntry('ngxFloatingHelpNotification', msg)
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp('ngxFloatingHelpNotification')
	EndTextCommandDisplayHelp(2, false, false, -1)
end