-- Copyright (C) 2015 Chen Jakin VERSION 0.3
--package.path = '/opt/local/ngxconf/web-lua-api/application/?.lua;;'

fun = require "lib.function"
local init = require "core.init";

local function app()
    init:run()
end

local b, msg = pcall(app)
if b == false then
    ngx.say("<p><strong>LUA ERROR</strong></p>")
    ngx.say(msg)
end