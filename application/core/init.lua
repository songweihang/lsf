local _M = {}

local Controller = require 'core.controller'
local Response = require 'core.response'
local function tappend(t, v) t[#t+1] = v end
local sgsub = string.gsub
local smatch = string.match
--local sgsub = ngx.re.gsub 
--local smatch = ngx.re.match
local routes = {}
routes.dispatchers = {}
routes.dispatchers[1]  = {}

function _M:add(method, pattern, route_info)
    local pattern, params = self:build_named_parameters(pattern)

    pattern = "^" .. pattern .. "/???$"

    route_info.controller = route_info.controller .. "_controller"
    route_info.params = params
    
    tappend(routes.dispatchers[1], { pattern = pattern, [method] = route_info })
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

function _M.request(ngx)

    --构建请求路径
    local http_match, err = ngx.re.match(ngx.var.uri, "/api/v([1-9]+)/(.*)")
    request = {}
    request.api_version = http_match[1]
    request.method = ngx.var.request_method
    request.uri = '/' .. http_match[2]

    return request
end

-- match request to routes
function _M.match(request)
    
    local uri = request.uri
    local method = request.method
    local api_version = request.api_version;

    local routes_dispatchers = Routes.dispatchers[tonumber(api_version)]
    if routes_dispatchers == nil then error({ code = 102 }) end

    -- loop dispatchers to find route
    for i = 1, #routes_dispatchers do
        local dispatcher = routes_dispatchers[i]
        if dispatcher[method] then -- avoid matching if method is not defined in dispatcher
            local match = { smatch(uri, dispatcher.pattern) }

            if #match > 0 then
                local params = {}
                for j = 1, #match do
                    if dispatcher[method].params[j] then
                        params[dispatcher[method].params[j]] = match[j]
                    else
                        tappend(params, match[j])
                    end
                end

                -- set version on request
                request.api_version = api_version
                -- return
                return 'api.v' .. api_version .. '.' .. dispatcher[method].controller, dispatcher[method].action, params, request
            end
        end
    end
end

function _M.call_controller(request, controller_name, action, params)
     -- load matched controller and set metatable to new instance of controller
    local matched_controller = require(controller_name)
    local controller_instance = Controller.new(request, params)
    setmetatable(matched_controller, { __index = controller_instance })

    -- call action
    local ok, status_or_error, body, headers = pcall(function() return matched_controller[action](matched_controller) end)
    ngx.print(body)
end

function _M:run()

    request = _M.request(ngx)
    controller_name, action, params, request = _M.match(request)
    _M.call_controller(request, controller_name, action, params)
end

return _M