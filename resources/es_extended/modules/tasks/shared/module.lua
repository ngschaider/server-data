local taskCount = 0;

local runningTasks = {};
module.IsTaskRunning = function(id)
    return runningTasks[id] == true;
end;

local GetTaskId = function()
    taskCount = taskCount + 1;
    return taskCount;
end;

module.ClearTask = function(id)
    runningTasks[id] = nil;
end;
module.ClearTimeout = module.ClearTask;
module.ClearInterval = module.ClearTask;

module.SetTimeout = function(msec, cb)
	local id = GetTaskId();

    runningTasks[id] = true;
	Citizen.SetTimeout(msec, function()
		if IsTaskRunning(id) then
            cb();
            runningTasks[id] = nil;
		end
	end)
end;

module.SetInterval = function(msec, cb)
	local id = GetTaskId();

    local run = function()
        module.SetTimeout(msec, function()
            if module.IsTaskRunning(id) then
                cb();
                run();
            end
        end);
    end;

    run();
    runningTasks[id] = true;
end;