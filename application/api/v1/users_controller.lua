local _M = {}

function _M:show()
	
	local jit_version = jit.version
	local data = {}
	data.jit_version = jit_version
    return 200,data
end

function _M:demo()
	
	local redis = require'lib.cache.redis'
	local red = redis:new()
	ok, err = red:set("dog", "an animal")
    if not ok then
        ngx.say("failed to set dog: ", err)
        return
    end

    local res, err = red:get("dog")
    if not res then
        ngx.say("failed to get dog: ", err)
        return
    end
	return 200,res
end

return _M