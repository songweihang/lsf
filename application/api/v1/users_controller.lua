local _M = {}

function _M:show()
	
	local jit_version = jit.version
	local data = {}
	data.jit_version = jit_version
    return 200,data
end

function _M:demo()

	local mysql = require 'db.mysql'
	return mysql:inQuery("INSERT INTO `test`.`cms_model` (`id`, `name`, `source_url`) VALUES (NULL, '1', '1');")
end

return _M