-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable

-- define error
Error = {}
Error.__index = Error

local function init_errors()

    errors = {}

    errors[200] = { status = 200, message = "成功" }
    errors[101] = { status = 200, message = "请求参数异常" }
    errors[102] = { status = 400, message = "后端服务执行异常" }
    errors[103] = { status = 200, message = "mysql Database 请求sql查询异常" }
    errors[104] = { status = 200, message = "memcahed 异常" }
    errors[105] = { status = 200, message = "redis 异常" }
    return errors
end

Error.list = init_errors()

function Error.new(code, custom_attrs)

    local err = Error.list[code]
    if err == nil then error("invalid error code") end

    local body = {
        code = code,
        message = err.message,
        body = custom_attrs
    }

    --if custom_attrs ~= nil then
    --    for k,v in pairs(custom_attrs) do body['body'][k] = v end
    --end


    local instance = {
        status = err.status,
        headers = err.headers or {},
        body = body,
    }
    setmetatable(instance, Error)
    return instance
end

return Error
