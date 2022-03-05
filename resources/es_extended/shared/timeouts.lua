local cancelledTimeouts = {};

local lastTimeoutId = 0;

local GetAndConsumeTimeoutId = function()
    lastTimeoutId = lastTimeoutId + 1;

    if lastTimeoutId > 65535 then
        lastTimeoutId = 0;
        if timeoutCallbacks[lastTimeoutId] then
            print("overriding timeout callback for timeout id " .. lastTimeoutId);
        end
    end

    return lastTimeoutId;
end

NGX.SetTimeout = function(msec, cb)
	local id = GetAndConsumeTimeoutId();

	SetTimeout(msec, function()
		if cancelledTimeouts[id] then
			cancelledTimeouts[id] = nil;
		else
			cb();
		end
	end)
end;

NGX.ClearTimeout = function(id)
	cancelledTimeouts[id] = true;
end;