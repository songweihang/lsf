local routes = require 'core.routes'

-- define version
local v1 = routes.version(1)

local v2 = routes.version(2)

-- define routes

-- 查询所用jit版本

v1:GET("/jit/show", { controller = "users", action = "show" })
v1:GET("/test/demo", { controller = "users", action = "demo" })


-- MYSQL 接口
v1:POST("/mysql/getQuery", { controller = "mysql", action = "getQuery" })
v1:GET("/mysql/getQuery", { controller = "mysql", action = "getQuery" })
v1:POST("/mysql/inQuery", { controller = "mysql", action = "inQuery" })


return routes