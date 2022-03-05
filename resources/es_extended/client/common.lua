AddEventHandler("ngx:getSharedObject", function(cb)
	cb(NGX);
end)

exports("getSharedObject", function()
	return NGX;
end)