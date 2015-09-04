local modulename = "confInit"
local _M = {}

_M._VERSION = '0.1'

_M.mysql_master_conf = appConfig["master_mysql"]
_M.mysql_slave_conf = appConfig["slave_mysql"]
_M.redis_conf = appConfig["redis"] 
_M.memcached_conf = appConfig["memcached"]


return _M
