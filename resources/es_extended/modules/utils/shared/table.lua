module.table = {};

-- nil proof alternative to #table
module.table.SizeOf = function(t)
	local count = 0

	for _,_ in pairs(t) do
		count = count + 1
	end

	return count
end

module.table.Set = function(t)
	local set = {}
	for k,v in ipairs(t) do set[v] = true end
	return set
end

module.table.IndexOf = function(t, value)
	for i=1, #t, 1 do
		if t[i] == value then
			return i
		end
	end

	return -1
end

module.table.Contains = function(t, value)
	return NGX.Table.IndexOf(t, value) ~= -1;
end

module.table.ContainsKey = function(t, value)
	for k,v in pairs(t) do
		if k == value then
			return true;
		end
	end
	
	return false;
end

module.table.LastIndexOf = function(t, value)
	for i=#t, 1, -1 do
		if t[i] == value then
			return i
		end
	end

	return -1
end

module.table.Find = function(t, cb)
	for i=1, #t, 1 do
		if cb(t[i]) then
			return t[i]
		end
	end

	return nil
end

module.table.FindIndex = function(t, cb)
	for i=1, #t, 1 do
		if cb(t[i]) then
			return i
		end
	end

	return -1
end

module.table.Filter = function(t, cb)
	local newTable = {}

	for i=1, #t, 1 do
		if cb(t[i]) then
			table.insert(newTable, t[i])
		end
	end

	return newTable
end

module.table.Map = function(t, cb)
	local newTable = {}

	for i=1, #t, 1 do
		newTable[i] = cb(t[i], i)
	end

	return newTable
end

module.table.Reverse = function(t)
	local newTable = {}

	for i=#t, 1, -1 do
		table.insert(newTable, t[i])
	end

	return newTable
end

module.table.Clone = function(t)
	if type(t) ~= 'table' then return t end

	local meta = getmetatable(t)
	local target = {}

	for k,v in pairs(t) do
		if type(v) == 'table' then
			target[k] = NGX.Table.Clone(v)
		else
			target[k] = v
		end
	end

	setmetatable(target, meta)

	return target
end

module.table.Concat = function(t1, t2)
	local t3 = NGX.Table.Clone(t1)

	for i=1, #t2, 1 do
		table.insert(t3, t2[i])
	end

	return t3
end

module.table.Join = function(t, sep)
	local sep = sep or ','
	local str = ''

	for i=1, #t, 1 do
		if i > 1 then
			str = str .. sep
		end

		str = str .. t[i]
	end

	return str
end

-- Credit: https://stackoverflow.com/a/15706820
-- Description: sort function for pairs
module.table.Sort = function(t, order)
	-- collect the keys
	local keys = {}

	for k,_ in pairs(t) do
		keys[#keys + 1] = k
	end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a,b)
			return order(t, a, b)
		end)
	else
		table.sort(keys)
	end

	-- return the iterator function
	local i = 0

	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end