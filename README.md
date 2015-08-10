# lsf

lua server framework整合了web开发中基础的应用组件,实现了基于版本号http Resty 接口

##安装
 Install [openresty](http://openresty.org/#Installation)

##编译过程
  ```shell
 安装drizzle_module模块所需要的依赖
 wget http://agentzh.org/misc/nginx/drizzle7-2011.07.21.tar.gz
 tar xzvf drizzle7-2011.07.21.tar.gz
 cd drizzle7-2011.07.21/
 ./configure --without-server
 make libdrizzle-1.0
 make install-libdrizzle-1.0

 安装openresty
 tar xzvf ngx_openresty-VERSION.tar.gz
 cd ngx_openresty-VERSION/
 ./configure  --with-pcre-jit --with-http_drizzle_module
 make
 make install
  ```
##注意事项
  ```
 lua.cnf是nginx配置文件，里面包含有各种服务的配置地址可以根据自行情况更改
 lua.cnf 项目地址是 /opt/local/ngxconf/web-lua-api/    你可以根据自己放置的位置进行配置
  ```
##路由配置
  ```lua
  local routes = require 'core.routes'

  local v1 = routes.version(1)

  v1:GET("/users", { controller = "users", action = "index" })
  v1:POST("/users", { controller = "users", action = "create" })
  v1:GET("/users/:id/:cid", { controller = "users", action = "show" })

  return routes
  ```
  
##http请求
  ```shell
  curl 'http://web-lua-api.cn/api/v1/users/1/11'
  ```

