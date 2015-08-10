local _M = {}

local function tappend(t, v) t[#t+1] = v end
local sgsub = string.gsub

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

local Routes = {}
Routes.dispatchers = {}

function _M:add(method, pattern, route_info)
    local pattern, params = self:build_named_parameters(pattern)

    pattern = "^" .. pattern .. "/???$"

    route_info.controller = route_info.controller .. "_controller"
    route_info.params = params
    ngx.say(fun:dump(route_info))
    --tappend(self.routes.dispatchers[self.number], { pattern = pattern, [method] = route_info })
end

function _M:build_named_parameters(pattern)
    local params = {}
    local new_pattern = sgsub(pattern, "/:([A-Za-z0-9_]+)", function(m)
        tappend(params, m)
        return "/([A-Za-z0-9_]+)"
    end)
    return new_pattern, params
end

local supported_http_methods = {
    GET = true,
    POST = true,
    HEAD = true,
    OPTIONS = true,
    PUT = true,
    PATCH = true,
    DELETE = true,
    TRACE = true,
    CONNECT = true
}

for http_method, _ in pairs(supported_http_methods) do
    _M[http_method] = function(self, pattern, route_info)
        self:add(http_method, pattern, route_info)
    end
end

function _M:run()

	local GET,POST = _M:get_request()
	local _g = _M:merge_request(GET,POST)
	api:run(_g)
end

return _M