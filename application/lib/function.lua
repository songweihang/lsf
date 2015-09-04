local _M = {}

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

function nul2nil(value)

    if value == ngx.null then
        return nil
    end

    return value
end

return _M