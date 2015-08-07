# web-lua-api

整合了web开发中基础的应用组件，以及提高编写openresty的api效率

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
 app 应用配置文件放在web-lua-api/application/config.lua 可以自行配置默认只有redis配置
 配置完毕执行 nginx reload  && curl "http://web-lua-api.cn/"
 输出 hello web-lua-api 表示安装成功
  ```