local callbacks = M("callbacks");

module.GetJob = function(cb)
	callbacks.TriggerServerCallback("ngx:GetCharacterData", cb, "job");
end;
module.GetName = function(cb)
	callbacks.TriggerServerCallback("ngx:GetCharacterData", cb, "name");
end;
module.GetAccount = function(accountName, cb)
	callbacks.TriggerServerCallback("ngx:GetCharacterData", cb, "account", accountName);
end;
module.GetAccounts = function(cb)
	callbacks.TriggerServerCallback("ngx:GetCharacterData", cb, "accounts");
end;

module.GetAllCharacters = function(cb)
	NGX.TriggerServerCallback("ngx:GetCharacters", cb);
end;