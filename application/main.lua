local _M = {}

function _M:get_request()

    local api_cmd = "ngx.hello.echo"
    REQUEST_METHOD = ngx.req.get_method()

    GET = ngx.req.get_uri_args()
    if REQUEST_METHOD == "POST" then
        POST = ngx.req.get_post_args()
    else
        POST = {}
    end

    if GET['api'] ~= nil then
        api_cmd = GET['api']
    end
    if POST['api'] ~= nil then
        api_cmd = POST['api']
    end
    api = require(api_cmd)
    return GET,POST
end

function _M:merge_request(GET,POST)

    local _g = {}

	for key, val in pairs(GET) do
		if type(val) == "table" then
			ngx.exit('502')
		else
		    _g[key] = val
		end
	end

    for key, val in pairs(POST) do

        if type(val) == "table" then
            ngx.exit('502')
        else
            _g[key] = val
        end
    end
    return _g
end

function _M:run()

	local GET,POST = _M:get_request()
	local _g = _M:merge_request(GET,POST)
	api:run(_g)
end

return _M