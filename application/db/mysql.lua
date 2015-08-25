local SqlDatabase = require 'db.sql'

-- Then initialize and return your database:
local MySql = SqlDatabase.new({
        adapter = 'mysql',
        host = "127.0.0.1",
        port = 3306,
        database = "gyh",
        user = "root",
        password = "",
        pool = 5
})

return MySql