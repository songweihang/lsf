-- Copyright (C) 2015 Chen Jakin (宋伟航)

local _M = {}

function _M:query(sql,confDB)
	-- ngx.print(sql)
	local data = ngx.location.capture("/query?confDB=" .. confDB .. "&sql=" .. sql )
	if data.status ~= ngx.HTTP_OK then
		local tid = data.header["X-Mysql-Tid"]
		if tid and tid ~= "" then
			ngx.location.capture("/kill", { args = {tid = tid,confDB = confDB} })
		end
	end
	return data.status,data.body
end

function _M:fetch(db,tab,id)
	local sql = "SELECT * FROM " .. db .. "." .. tab .. " WHERE id=" .. id
	return _M:query(sql,"mysql_slave")
end

function _M:fetchAll(tab,find,where)
	local sql = "SELECT " .. find .. " FROM " .. tab .. " " .. where
	return _M:query(sql,"mysql_slave")
end

function _M:delete(db,tab,id)
	local sql = "DELETE FROM `" .. db .. "`.`" .. tab .. "` WHERE id = " .. id
	return _M:query(sql,"mysql_master")
end

function _M:insert(db,tab,data)
	local find,value= _M:Fields(data)
	local data = ngx.location.capture("/insert",{ args = {db = db,tab = tab,find = find,value = value} } )
	return data.status,data.body
end

function _M:update(db,tab,data,id)
	local value= _M:Fieldsupdate(data)
	local data = ngx.location.capture("/update",{ args = {db = db,tab = tab,id = id,value = value} } )
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

function _M:Fields(data)
	local find
	find = ""
	for	key,val in pairs(data) do
		key = "`" .. key .. "`"
		if find == "" then
			find = key
			value = "'" .. val .. "'"
		else			
			find = find .. "," .. key	
			value = value .. ",'" .. val .. "'"	
		end		
	end
	return find,value
end

function _M:Fieldsupdate(data)
	
	local value = "",key,val
	for	key,val in pairs(data) do
		key = "`" .. key .. "`"
		if value == "" then		
			value = key .. "=" .. "'" .. val .. "'"
		else			
			value = value .. "," .. key .. "='" .. val .. "'"	
		end		
	end
	return value
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


function _M:split(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	while true do
		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
		if not nFindLastIndex then
			nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
			break
		end
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
		nFindStartIndex = nFindLastIndex + string.len(szSeparator)
		nSplitIndex = nSplitIndex + 1
		nFindStartIndex = nFindLastIndex + 1
	end
	return nSplitArray
end

function _M:json_decode(str)
    local data = nil
    _, err = pcall(function(str) return json.decode(str) end, str)
    return data, err
end

return _M