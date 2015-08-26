local _M = {}

local function quote(str) return ngx.quote_sql_str(str) end

function _M:show()
	
	local jit_version = jit.version
	local data = {}
	data.jit_version = jit_version
    return 200,data
end

function _M:demo()

	local orm = require 'db.sql.mysql.orm'.new('gyh',quote)
    data = {}
    data.first_name = 'gin' 
    local sql = orm.create(data)
    return 200,sql
end

return _M