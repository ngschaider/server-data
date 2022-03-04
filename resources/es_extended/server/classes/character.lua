function ConstructCharacter(clientId, characterId)
	local self = {};

	self.id = characterId;
	self.player = ESX.GetPlayerFromClientId(clientId);;

	self.setPosition = function(coords)
		self.triggerEvent('esx:teleport', coords);
	end

	self.getPosition = function(vector)
		local ped = GetPlayerPed(self.player.id);
		return GetEntityCoords(ped);
	end

	self.kick = function(reason)
		DropPlayer(self.source, reason);
	end

	self.setMoney = function(money)
		money = ESX.Math.Round(money);
		self.setAccountMoney('money', money);
	end

	self.getMoney = function()
		return self.getAccount('money').money;
	end

	self.addMoney = function(money)
		money = ESX.Math.Round(money);
		self.addAccountMoney('money', money);
	end

	self.removeMoney = function(money)
		money = ESX.Math.Round(money);
		self.removeAccountMoney('money', money);
	end

	self.getAccounts = function(minimal)
		local accounts = MySQL.prepare.await("SELECT name, value, label FROM accounts WHERE owner=? AND owner_type='character'", {self.characterId});
		
		if minimal then
			local minimalAccounts = {}

			for k,v in ipairs(accounts) do
				minimalAccounts[v.name] = v.value;
			end

			return minimalAccounts;
		else
			return accounts;
		end
	end

	self.getAccount = function(accountName)
		local account = MySQL.prepare.await("SELECT name, value, label FROM accounts WHERE owner=? AND owner_type='character' AND name=?", {self.characterId, accountName});
		
		if #account > 0 then
			return account[1];
		else
			return nil;
		end
	end

	self.getJob = function()
		local query = "SELECT j.name job_name, j.label job_label, g.name grade_name, g.label grade_label, g.salary grade_salary FROM job_grades g INNER JOIN jobs j ON j.name = g.job AND g.name = u.job_grade INNER JOIN character c ON c.job = j.job WHERE c.id =?";
		local results = MySQL.prepare.await(query, {self.characterId});
		local r = results[1];
		
		return {
			name = r.job_name,
			label = r.job_label,
			grade_name = r.grade_name,
			grade_label = r.grade_label,
			grade_salary = r.grade_salary,
		};
	end
	
	self.getName = function()
		local result = MySQL.prepare.await("SELECT firstname, lastname FROM characters WHERE id=?", {self.characterId});
		return result[1].firstname .. " " .. result[1].lastname;
	end

	self.setName = function(firstname, lastname)
		MySQL.prepare.await("UPDATE characters SET firstname=?, lastname=? WHERE id=?", {self.characterId});
	end

	self.setAccountMoney = function(accountName, value)
		MySQL.prepare("UPDATE accounts SET value=? WHERE owner_type='character' AND owner=? AND name=?", {value, self.characterId, accountName});
	end

	self.addAccountMoney = function(accountName, money)
		MySQL.prepare("UPDATE accounts SET value=value + ? WHERE owner_type='character' AND owner=? AND name=?", {value, self.characterId, accountName});
	end

	self.removeAccountMoney = function(accountName, money)
		MySQL.prepare("UPDATE accounts SET value=value - ? WHERE owner_type='character' AND owner=? AND name=?", {value, self.characterId, accountName});
	end

	self.setJob = function(job, grade)
		if not ESX.DoesJobExist(job, grade) then
			return;
		end
		MySQL.prepare.await("UPDATE characters SET job=?, job_grade=? WHERE id=?", {job, grade, self.characterId});
	end

	return self
end
