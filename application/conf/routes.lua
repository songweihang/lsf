local routes = require 'core.routes'

-- define version
local v1 = routes.version(1)

-- define routes
v1:GET("/users", { controller = "users", action = "index" })
v1:POST("/users", { controller = "users", action = "create" })
v1:GET("/users/:id/:cid", { controller = "users", action = "show" })

return routes