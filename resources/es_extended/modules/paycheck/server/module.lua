local character = M("character");

local Payout = function()
	local characters = character.GetCharacters();
	for _, c in pairs(characters) do
		local job = c.GetJob().name;
		local salary = c.GetJob().salary;

		if salary > 0 then
			local accounts = NGX.Accounts.getAccount("society", job, "money");

			if #accounts > 0 then
				local account = accounts[1];
				
				if account.getValue() >= salary then
					character.getAccount("bank").addValue(salary);
					TriggerClientEvent('ngx:showAdvancedNotification', xPlayer.source, _U('bank'), _U('received_paycheck'), _U('received_help', salary), 'CHAR_BANK_MAZE', 9)
					account.removeValue(salary);
				else
					TriggerClientEvent('ngx:showAdvancedNotification', xPlayer.source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_MAZE', 1)
				end
			else
				print("Society " .. job .. " does not have an account. Not paying out paycheck");
			end
		end
	end
end;

StartPayCheck = function()
	CreateThread(function()
		while true do
			Wait(Config.PaycheckInterval)
			Payout();
		end
	end)
end;
