local _M = {}

function _M:run(_g)

	local sql = _g['sql']

    --执行修改数据库
	local ok,data = fun:query(sql,'mysql_master')
	if ok == 200 then
		ngx.print(data)
	else
		ngx.print('{"ok":"no","status":"502"}')
	end

end

return _M