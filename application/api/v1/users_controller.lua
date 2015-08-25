local _M = {}

function _M:show()
	
	local jit_version = jit.version
	local data = {}
	data.jit_version = jit_version
    return 200,data
end

function _M:demo()

	local MySql = require 'db.mysql'
    local SqlOrm = require 'db.sql.orm'

    Users = SqlOrm.define_model(MySql, 'post_all')
    data = {}
    data.post_id1 = 111
    data.addtime = 12312312
    local ok,users = Users.where("")

    return ok,users
end

return _M