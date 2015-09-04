local _M        = {}
local mysql     = require 'db.mysql'
local json      = require 'cjson'
local jencode   = json.encode   -- 编码
local mc        = require'lib.cache.memcached'

-- 解码
local function json_decode(str)
    local data = nil
    _, err = pcall(function(str) return json.decode(str) end, str)
    return data, err
end

-- 从库执行sql
function _M:getQuery()
    
    local lock = require "resty.lock"
    local mem_key = nil
	local sql = self.request.POST.sql
	if sql == nil then
        return 101
    end

    local is_lock = tonumber(self.request.POST.is_lock)
	if	is_lock == nil then
        is_lock = 0
    end

	local mc_time = tonumber(self.request.POST.mc_time)
	if	mc_time == nil then
		mc_time = 0
	end

	if mc_time ~= 0 then
        
        mem_key = ngx.md5(sql)
        local ok,data = mc:get(mem_key)

		if ok == 200 and data ~= nil then
            local _, data = json_decode(data)
			return 200 ,data
		end
	end

	if is_lock == 1 then

        -- 缓冲被穿透进行加锁处理
        local lock = lock:new("cache_locks")
        local elapsed, err = lock:lock(mem_key)
        if not elapsed then
            return 102
        end

        local ok,data = mc:get(mem_key)
        if mc_time ~= 0 then
            if ok == 200 and data ~= nil then

                --获取到缓冲数据进行解锁
                local ok, err = lock:unlock()
                if not ok then
                    return 102 
                end

                return 200 ,data
            end
        end
    end

    --查询数据库
	local ok,data = mysql:getQuery(sql)
    
	if ok == 200 and mc_time ~= 0 and data ~= nil then

		mc:set(mem_key,jencode(data),mc_time)
	end

    if is_lock == 1 then
        local ok, err = lock:unlock()
        if not ok then
            return 102
        end
    end

    return ok ,data
end

function _M:getQueryFind()
    local sql = self.request.POST.sql
    if sql == nil then
        return 101
    end
    
    return mysql:getQueryFind(sql)
end

-- 主库执行sql
function _M:inQuery()

    local sql = self.request.POST.sql
    if sql == nil then
        return 101
    end

    --执行修改数据库
    return mysql:inQuery(sql)
end

return _M