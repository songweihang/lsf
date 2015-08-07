-- ip 地址访问控制

local iputils = require("resty.iputils")
if not iputils.ip_in_cidrs(ngx.var.remote_addr, whitelist) then
  return ngx.exit(ngx.HTTP_FORBIDDEN)
end