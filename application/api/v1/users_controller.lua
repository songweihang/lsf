local _M = {}

function _M:show()
	local jit_version = jit.version
    return 200,jit_version
end

return _M