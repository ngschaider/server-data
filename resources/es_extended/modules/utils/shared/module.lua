run("math.lua");
run("table.lua");

local charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

module.GetRandomString = function(length)
	math.randomseed(GetGameTimer());

	if length > 0 then
        local randomNumber = math.random(1, charset:len());
		return module.GetRandomString(length - 1) .. charset:sub(randomNumber, randomNumber);
	else
		return '';
	end
end;