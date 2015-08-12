-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable

-- define error
Error = {}
Error.__index = Error

local function init_errors()

    errors = {}
    errors[100] = { status = 412, message = "Accept header not set." }
    errors[101] = { status = 412, message = "Invalid Accept header format." }
    errors[102] = { status = 412, message = "Unsupported version specified in the Accept header." }
    errors[103] = { status = 400, message = "Could not parse JSON in body." }
    errors[104] = { status = 400, message = "Body should be a JSON hash." }
    errors[105] = { status = 400, message = "mysql Database exception" }
    errors[106] = { status = 400, message = "Parameter error" }

    return errors
end

Error.list = init_errors()

function Error.new(code, custom_attrs)

    local err = Error.list[code]
    if err == nil then error("invalid error code") end

    local body = {
        code = code,
        message = err.message
    }

    if custom_attrs ~= nil then
        for k,v in pairs(custom_attrs) do body[k] = v end
    end

    local instance = {
        status = err.status,
        headers = err.headers or {},
        body = body,
    }
    setmetatable(instance, Error)
    return instance
end

return Error
