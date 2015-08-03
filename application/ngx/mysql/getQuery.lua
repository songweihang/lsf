local _M = {}

function _M:run(_g)

    local lock = require "resty.lock"
	local sql = _g['sql']

	local is_lock = tonumber(_g['is_lock'])
	if	is_lock == nil then
        is_lock = 0
    end

	_g['sys_mctime'] = tonumber(_g['sys_mctime'])
	if	_g['sys_mctime'] == nil then
		_g['sys_mctime'] = 0
	end

	local mem_key = ngx.md5(sql)
	local ok,data = fun:m_get(mem_key)
	if _g['sys_mctime'] ~= 0 then
		if ok == 200 then
			ngx.print(data)
			return
		end
	end

	if is_lock == 1 then

        -- 缓冲被穿透进行加锁处理
        local lock = lock:new("cache_locks")
        local elapsed, err = lock:lock(mem_key)
        if not elapsed then
            return fail("failed to acquire the lock: ", err)
        end

        local ok,data = fun:m_get(mem_key)
        if _g['sys_mctime'] ~= 0 then
            if ok == 200 then

                --获取到缓冲数据进行解锁
                local ok, err = lock:unlock()
                if not ok then
                    return fail("failed to unlock: ", err)
                end

                ngx.print(data)
                return
            end
        end
    end

    --查询数据库
	local ok,data = fun:query(sql,'mysql_slave')
	if ok == 200 then
		if  _g['sys_mctime'] ~= 0  then
			fun:m_set(mem_key,data,_g['sys_mctime'])
		end
		ngx.print(data)
	else
		ngx.print('{"ok":"no","status":"502"}')
	end

    if is_lock == 1 then
        local ok, err = lock:unlock()
        if not ok then
            return fail("failed to unlock: ", err)
        end
    end
end


return _M