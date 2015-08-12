-- perf
local error = error
local pcall = pcall
local rawget = rawget
local setmetatable = setmetatable


local Request = {}
Request.__index = Request

function Request.new(ngx)
    -- read body
    ngx.req.read_body()
    local method = ngx.var.request_method
    local POST = {}
    if method == 'POST' then
        POST = ngx.req.get_post_args()
    end

    local http_match, err = ngx.re.match(ngx.var.uri, "/api/v([1-9]+)/(.*)")
    local api_version = http_match[1]
    local uri = '/' .. http_match[2]
    
    -- init instance
    local instance = {
        uri = uri,
        method = method,
        headers = ngx.req.get_headers(),
        POST= POST,
        api_version = api_version,
    }
    setmetatable(instance, Request)
    return instance
end

return Request
