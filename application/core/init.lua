
local json = require 'cjson'
local Controller = require 'core.controller'
local Response = require 'core.response'
local Request = require 'core.request'
local Error = require 'core.error'

local init = {}

local function tappend(t, v) t[#t+1] = v end
local sgsub = string.gsub
local smatch = string.match
local jencode = json.encode


local function create_request(ngx)
    local ok, request_or_error = pcall(function() return Request.new(ngx) end)
    return request_or_error
end

-- match request to routes
function init.match(request)
    
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

function init.call_controller(request, controller_name, action, params)

    local matched_controller = require(controller_name)
    local controller_instance = Controller.new(request, params)
    setmetatable(matched_controller, { __index = controller_instance })
    -- 执行 action
    local ok, status_or_error, body, headers = pcall(function() return matched_controller[action](matched_controller) end)

    local response

    if ok then
        if status_or_error == 200 then

            ngx.print(body)
            return
        else

            local err = Error.new(status_or_error)
            response = Response.new({ status = err.status, body = err.body })
            init.respond(ngx, response)
            return false
        end
    else
        error(status_or_error)
    end

end

function init.respond(ngx, response)

    ngx.status = response.status

    for k, v in pairs(response.headers) do
        ngx.header[k] = v
    end

    local json_body = jencode(response.body)
    
    ngx.header["Content-Length"] = ngx.header["Content-Length"] or ngx.header["content-length"] or json_body:len()
    ngx.print(json_body)
end

function init:run()

    local request = create_request(ngx)
    controller_name, action, params, request = init.match(request)
    init.call_controller(request, controller_name, action, params)
end

return init