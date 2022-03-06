module.math = {};

module.math.Round = function(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / power;
	else
		return math.floor(value + 0.5);
	end
end;

-- credit http://richard.warburton.it
module.math.GroupDigits = function(value)
	local left, num, right = string.match(value,'^([^%d]*%d)(%d*)(.-)$');

	return left .. (num:reverse():gsub('(%d%d%d)','%1' .. _U('locale_digit_grouping_symbol')):reverse()) .. right;
end;

module.math.Trim = function(value)
	if value then
		return value:gsub("^%s*(.-)%s*$", "%1");
	else
		return nil;
	end
end;