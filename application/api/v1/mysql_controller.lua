local _M = {}

function _M:getQuery()

    local lock = require "resty.lock"
	local sql = self.request.POST.sql
	
	local is_lock = tonumber(self.request.POST.is_lock)
	if	is_lock == nil then
        is_lock = 0
    end

	sys_mctime = tonumber(self.request.POST.sys_mctime)
	if	sys_mctime == nil then
		sys_mctime = 0
	end

	local mem_key = ngx.md5(sql)
	local ok,data = fun:m_get(mem_key)
	if sys_mctime ~= 0 then
		if ok == 200 then
			return 200 ,data
		end
	end

	if is_lock == 1 then

        -- 缓冲被穿透进行加锁处理
        local lock = lock:new("cache_locks")
        local elapsed, err = lock:lock(mem_key)
        if not elapsed then
            return 500,fail("failed to acquire the lock: ", err)
        end

        local ok,data = fun:m_get(mem_key)
        if sys_mctime ~= 0 then
            if ok == 200 then

                --获取到缓冲数据进行解锁
                local ok, err = lock:unlock()
                if not ok then
                    return 500 , fail("failed to unlock: ", err)
                end

                return 200 ,data
            end
        end
    end

    --查询数据库
	local ok,data = fun:query(sql,'mysql_slave')
	if ok == 200 then
		if  sys_mctime ~= 0  then
			fun:m_set(mem_key,data,sys_mctime)
		end
		return 200 ,data
	else
		return 200 ,'{"ok":"no","status":"502"}'
	end

    if is_lock == 1 then
        local ok, err = lock:unlock()
        if not ok then
            return 200 , fail("failed to unlock: ", err)
        end
    end
end

return _M