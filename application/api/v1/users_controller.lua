local _M = {}

function _M:show()
    --ngx.say('<b>hello web-lua-api</b>')
    return 200,'<b>hello web-lua-api</b>'
end

return _M