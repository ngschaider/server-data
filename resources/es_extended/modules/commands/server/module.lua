local characterClass = M("character");

module.RegisterCommand = function(name, group, cb, allowConsole, suggestion)
	if type(name) == 'table' then
		for k,v in ipairs(name) do
			module.RegisterCommand(v, group, cb, allowConsole, suggestion);
		end

		return;
	end

	if registeredCommands[name] then
		print(('[^3WARNING^7] Command ^5"%s" already registered, overriding command'):format(name));

		if registeredCommands[name].suggestion then
			TriggerClientEvent('chat:removeSuggestion', -1, ('/%s'):format(name));
		end
	end

	if suggestion then
		if not suggestion.arguments then 
			suggestion.arguments = {} 
		end
		if not suggestion.help then 
			suggestion.help = '' 
		end

		TriggerClientEvent('chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments);
	end

	registeredCommands[name] = {
		group = group, 
		cb = cb, 
		allowConsole = allowConsole, 
		suggestion = suggestion
	};

	RegisterCommand(name, function(playerId, args, rawCommand)
		local command = registeredCommands[name];

		if not command.allowConsole and playerId == 0 then
			print(('[^3WARNING^7] ^5%s'):format(_U('commanderror_console')));
		else
			local xPlayer = characterClass.GetByPlayerId(playerId);
			local error = nil;

			if command.suggestion then
				if command.suggestion.validate then
					if #args ~= #command.suggestion.arguments then
						error = _U('commanderror_argumentmismatch', #args, #command.suggestion.arguments);
					end
				end

				if not error and command.suggestion.arguments then
					local newArgs = {};

					for k,v in ipairs(command.suggestion.arguments) do
						if v.type then
							if v.type == 'number' then
								local newArg = tonumber(args[k]);

								if newArg then
									newArgs[v.name] = newArg;
								else
									error = _U('commanderror_argumentmismatch_number', k);
								end
							elseif v.type == 'player' or v.type == 'playerId' then
								local targetPlayer = tonumber(args[k]);

								if args[k] == 'me' then 
									targetPlayer = playerId;
								end

								if targetPlayer then
									local xTargetPlayer = characterClass.GetByPlayerId(targetPlayer);

									if xTargetPlayer then
										if v.type == 'player' then
											newArgs[v.name] = xTargetPlayer;
										else
											newArgs[v.name] = targetPlayer;
										end
									else
										error = _U('commanderror_invalidplayerid');
									end
								else
									error = _U('commanderror_argumentmismatch_number', k);
								end
							elseif v.type == 'string' then
								newArgs[v.name] = args[k];
							elseif v.type == 'item' then
								if NGX.Items[args[k]] then
									newArgs[v.name] = args[k];
								else
									error = _U('commanderror_invaliditem');
								end
							elseif v.type == 'weapon' then
								if NGX.GetWeapon(args[k]) then
									newArgs[v.name] = string.upper(args[k]);
								else
									error = _U('commanderror_invalidweapon');
								end
							elseif v.type == 'any' then
								newArgs[v.name] = args[k];
							end
						end

						if error then 
							break 
						end
					end

					args = newArgs;
				end
			end

			if error then
				if playerId == 0 then
					print(('[^3WARNING^7] %s^7'):format(error));
				else
					xPlayer.showNotification(error);
				end
			else
				cb(xPlayer or false, args, function(msg)
					if playerId == 0 then
						print(('[^3WARNING^7] %s^7'):format(msg));
					else
						xPlayer.showNotification(msg);
					end
				end);
			end
		end
	end, true)

	if type(group) == "table" then
		for k,v in ipairs(group) do
			ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name));
		end
	else
		ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name));
	end
end



module.RegisterCommand('setcoords', 'admin', function(xPlayer, args, showError)
	xPlayer.setCoords({x = args.x, y = args.y, z = args.z});
end, false, {help = _U('command_setcoords'), validate = true, arguments = {
	{name = 'x', help = _U('command_setcoords_x'), type = 'number'},
	{name = 'y', help = _U('command_setcoords_y'), type = 'number'},
	{name = 'z', help = _U('command_setcoords_z'), type = 'number'}
}});

module.RegisterCommand('setjob', 'admin', function(xPlayer, args, showError)
	if NGX.DoesJobExist(args.job, args.grade) then
		args.playerId.setJob(args.job, args.grade);
	else
		xPlayer.showNotification(_U('command_setjob_invalid'));
	end
end, true, {help = _U('command_setjob'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'job', help = _U('command_setjob_job'), type = 'string'},
	{name = 'grade', help = _U('command_setjob_grade'), type = 'string'}
}});

module.RegisterCommand('car', 'admin', function(xPlayer, args, showError)
	xPlayer.triggerEvent('ngx:spawnVehicle', args.car);
end, false, {help = _U('command_car'), validate = false, arguments = {
	{name = 'car', help = _U('command_car_car'), type = 'string'}
}});

module.RegisterCommand({'cardel', 'dv'}, 'admin', function(xPlayer, args, showError)
	if not args.radius then 
		args.radius = 4 
	end
	xPlayer.triggerEvent('ngx:deleteVehicle', args.radius);
end, false, {help = _U('command_cardel'), validate = false, arguments = {
	{name = 'radius', help = _U('command_cardel_radius'), type = 'any'}
}});

module.RegisterCommand('setaccountmoney', 'admin', function(xPlayer, args, showError)
	if args.playerId.getAccount(args.account) then
		args.playerId.setAccountMoney(args.account, args.amount);
	else
		xPlayer.showNotification(_U('command_giveaccountmoney_invalid'));
	end
end, true, {help = _U('command_setaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = _U('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = _U('command_setaccountmoney_amount'), type = 'number'}
}});

module.RegisterCommand('giveaccountmoney', 'admin', function(xPlayer, args, showError)
	if args.playerId.getAccount(args.account) then
		args.playerId.addAccountMoney(args.account, args.amount);
	else
		xPlayer.showNotification(_U('command_giveaccountmoney_invalid'));
	end
end, true, {help = _U('command_giveaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = _U('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = _U('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = _U('command_giveaccountmoney_amount'), type = 'number'}
}});

module.RegisterCommand({'clear'}, 'user', function(xPlayer, args, showError)
	xPlayer.triggerEvent('chat:clear');
end, false, {help = _U('command_clear')});

module.RegisterCommand({'clearall'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('chat:clear', -1);
end, false, {help = _U('command_clearall')});

module.RegisterCommand('tpm', "admin", function(xPlayer, args, showError)
	xPlayer.triggerEvent("ngx:tpm");
end, true)