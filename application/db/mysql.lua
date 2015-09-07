---mysql链接类支持主从分离
-- @classmod db.mysql
-- @release 0.1
local modulename    = "dbMysql"

local confInit      = require 'conf.init'
local mysql_adapter = require "db.sql.mysql.adapter"
local next          = next
local error         = error
local ipairs        = ipairs
local pairs         = pairs
local require       = require
local tonumber      = tonumber
local setmetatable  = setmetatable
local tconcat       = table.concat
local type          = type
local function tappend(t, v) t[#t+1] = v end
local function quote(str) return ngx.quote_sql_str(str) end



local dbMysql   = { }
dbMysql.__index = dbMysql

-- field and values helper
local function field_and_values(quote, attrs, concat)
    local fav = {}
    for field, value in pairs(attrs) do
        local key_pair = {}
        tappend(key_pair, field)
        if type(value) ~= 'number' then value = quote(value) end
        tappend(key_pair, "=")
        tappend(key_pair, value)

        tappend(fav, tconcat(key_pair))
    end
    return tconcat(fav, concat)
end

local function build_where(sql, attrs)
    if attrs ~= nil then
        if type(attrs) == 'table' then
            if next(attrs) ~= nil then
                tappend(sql, " WHERE (")
                tappend(sql, field_and_values(quote, attrs, ' AND '))
                tappend(sql, ")")
            end
        else
            tappend(sql, " WHERE (")
            tappend(sql, attrs)
            tappend(sql, ")")
        end
    end
end

function dbMysql:getQuery(sql)
    
    return mysql_adapter.execute(confInit.mysql_slave_conf,sql) 
end

function dbMysql:inQuery(sql)
    
    return mysql_adapter.execute(confInit.mysql_master_conf,sql) 
end

function dbMysql:getQueryFind(sql)
    
    local ok,res = mysql_adapter.execute(confInit.mysql_slave_conf,sql)
    if ok == 200 then
        return ok,res[1]
    else
        return ok,res       
    end

end

function dbMysql:find_by(table_name,attrs,options)

end

function dbMysql:where(table_name,attrs,options)

    local sql = {}
    -- start
    tappend(sql, "SELECT * FROM ")
    tappend(sql, table_name)
    -- where
    build_where( sql, attrs)
    -- options
    if options then
        -- order
        if options.order ~= nil then
            tappend(sql, " ORDER BY ")
            tappend(sql, options.order)
        end
        -- limit
        if options.limit ~= nil then
            tappend(sql, " LIMIT ")
            tappend(sql, options.limit)
        end
        -- offset
        if options.offset ~= nil then
            tappend(sql, " OFFSET ")
            tappend(sql, options.offset)
        end
    end
    -- close
    tappend(sql, ";")
    -- execute
    return dbMysql:getQuery(tconcat(sql))
end

function dbMysql:save(table_name,attrs)
    -- health check
    if attrs == nil or next(attrs) == nil then
        error("no attributes were specified to create new model instance")
    end
    -- init sql
    local sql = {}
    -- build fields
    local fields = {}
    local values = {}
    for field, value in pairs(attrs) do
        tappend(fields, field)
        if type(value) ~= 'number' then value = quote(value) end
        tappend(values, value)
    end
    -- build sql
    tappend(sql, "INSERT INTO ")
    tappend(sql, table_name)
    tappend(sql, " (")
    tappend(sql, tconcat(fields, ','))
    tappend(sql, ") VALUES (")
    tappend(sql, tconcat(values, ','))
    tappend(sql, ");")
    -- hit server
    -- master_db_options
    return dbMysql:inQuery(tconcat(sql))
    --return 200,tconcat(sql)
end

function dbMysql:update_where(table_name,attrs, where_attrs)
    -- health check
    if attrs == nil or next(attrs) == nil then
        error("no attributes were specified to create new model instance")
    end
    -- init sql
    local sql = {}
    -- start
    tappend(sql, "UPDATE ")
    tappend(sql, table_name)
    tappend(sql, " SET ")
    -- updates
    tappend(sql, field_and_values(quote, attrs, ','))
    -- where
    build_where( sql, where_attrs)
    -- close
    tappend(sql, ";")
    -- execute
    return dbMysql:inQuery(tconcat(sql))
end

function dbMysql:delete_where(table_name,attrs, options)
    -- init sql
    local sql = {}
    -- start
    tappend(sql, "DELETE FROM ")
    tappend(sql, table_name)
    -- where
    build_where(sql, attrs)
    -- options
    if options then
        -- limit
        if options.limit ~= nil then
            tappend(sql, " LIMIT ")
            tappend(sql, options.limit)
        end
    end
    -- close
    tappend(sql, ";")
    -- execute
    return dbMysql:inQuery(tconcat(sql))
end

return dbMysql