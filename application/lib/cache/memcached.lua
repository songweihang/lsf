local require                   = require
local confInit                  = require 'conf.init'

local timeout_subsequent_ops    = 1000 -- 1 sec
local max_idle_timeout          = 10000 -- 10 sec
local max_packet_size           = 1024 * 1024 -- 1MB
local pool                      = 10    -- memcached pool
local memcached                 = {}

local function memcached_connect()

    local mcd = require "resty.memcached"
    local memc, err = mcd:new()
    if not memc then
        return 104,"failed to instantiate memc:" .. err
    end

    memc:set_timeout(timeout_subsequent_ops) -- 1 sec

    local ok, err = memc:connect(confInit.memcached_conf.host, confInit.memcached_conf.port)
    if not ok then
        return 104,"failed to connect: " .. err
    end

    return memc
end

local function memcached_keepalive(memc)

    local ok, err = memc:set_keepalive(max_idle_timeout, confInit.memcached_conf.pool)
    if not ok then error("failed to set mysql keepalive: ", err) end
end


function memcached:set(key,val,exptime)

	local memc = memcached_connect()

    local ok, err = memc:set(key,val,exptime)
    if not ok then
        return 104,"failed to set key: " .. err
    end

    memcached_keepalive(memc)
    return 200    
end

function memcached:get(key)

	local memc = memcached_connect()
    local res, flags, err  = memc:get(key)
    if err then
        return 104,"failed to get  key: " .. err
    end

    if not res then
        return 200,nil
    end

    memcached_keepalive(memc)
    return 200,res
end

return memcached