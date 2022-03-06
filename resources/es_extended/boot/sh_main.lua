NGX = NGX or {};
NGX.Logger = NGX.Logger or {};

NGX.Logger.Error = function(err, loc)
    loc = loc or "<unknown location>";
    print(debug.traceback("^1[error] in ^5" .. loc .. "^7\n\n^5message: ^1" .. err .. "^7\n"));
end;

NGX.Logger.Warn = function(warningMessage)
    print('^3[warning]^7 ' .. warningMessage)
end;

NGX.EvalFile = function(resource, file, env)
    local code = LoadResourceFile(resource, file);
    local fn, err = load(code, '@' .. resource .. ':' .. file, 't', env);

    if err then
        ESX.LogError(err, '@' .. resource .. ':' .. file);
        return env, false;
    end

    local success = true;

    local status, result = xpcall(fn, function(err)
        success = false;
        NGX.Logger.Error(err, '@' .. resource .. ':' .. file);
    end);

    return env, success;
end;

local modules = json.decode(LoadResourceFile(GetCurrentResourceName(), "modules.json"));
for k,v in pairs(modules) do
    M(v);
end

print('[^2INFO^7] ^5NGX^0 initialized');