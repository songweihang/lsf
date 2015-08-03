-- Copyright (C) 2015 Chen Jakin VERSION 0.3

ngx.header.content_type = "text/html;charset=utf-8";

fun = require "resty.function"
cjson = require "cjson";

main = require "main";

local function app()
    main:run()
end

local b, msg = pcall(app)
if b == false then
    ngx.say("<p><strong>LUA ERROR</strong></p>")
    ngx.say(msg)
end