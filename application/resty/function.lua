-- Copyright (C) 2015 Chen Jakin (宋伟航)

local _M = {}

function _M:query(sql,db_link)
	local data = ngx.location.capture("/query?db_link=" .. db_link .. "&sql=" .. sql )
	if data.status ~= ngx.HTTP_OK then
		local tid = data.header["X-Mysql-Tid"]
		if tid and tid ~= "" then
			ngx.location.capture("/kill", { args = {tid = tid,db_link = db_link} })
		end
	end
	return data.status,data.body
end

function _M:m_set(key,val,exptime)
	local data = ngx.location.capture("/mem",{ args = {cmd = "set",key = key,val = val,exptime = exptime} } )
	return data.status,data.body
end

function _M:m_get(key)
	local data = ngx.location.capture("/mem",{ args = {cmd = "get",key = key} } )
	return data.status,data.body
end

function _M:m_del(key)
	local data = ngx.location.capture("/mem",{ args = {cmd = "delete",key = key} } )
	return data.status,data.body
end

function _M:dump(o)
    if type(o) == 'table' then
        local s = ''
        for k,v in pairs(o) do
            if type(k) ~= 'number'
            then
                sk = '"'..k..'"'
            else
                sk =  k
            end
            s = s .. ', ' .. '['..sk..'] = ' .. _M:dump(v)
        end
        s = string.sub(s, 3)
        return '{ ' .. s .. '} '
    else
        return tostring(o)
    end                                                                         
end

function _M:trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function _M:json_decode(str)
    local data = nil
    _, err = pcall(function(str) return json.decode(str) end, str)
    return data, err
end

return _M