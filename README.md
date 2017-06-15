erlang version

erlang -> ./erlang_1.8.3/

ubuntu


============================================

ejabberd 安装下载

https://www.process-one.net/en/ejabberd/archive/

wget https://www.process-one.net/downloads/ejabberd/16.12/ejabberd-16.12.tgz


    ./autogen.sh
    ./configure
    make

    sudo make install

    cp ejabberd.yml.example ejabberd.yml

    ./run.sh


sudo /sbin/ejabberdctl ejabberd@127.0.0.1 register admin 127.0.0.1 123456


=============================================
在ubuntu 软件中心搜索 psi

psi聊天客户端
开源即时通讯客户端

Psi+

pidgin

swift xmpp



新建XMPP管理帐号


sudo /sbin/ejabberdctl register admin localhost 123456
sudo /sbin/ejabberdctl register test localhost 123456

User admin@localhost successfully registered

用psi+注册客户端账号


-----------------------------------------
管理页面url:

http://localhost:5280/admin

账号密码:

admin@localhost
123456



========================================
ejabberd.yml 配制文件

参考下面的blog, 开启ejabberd 用户注册功能，　我用的psi+注册的，　很方便

http://blog.csdn.net/l631768226/article/details/52931010

========================================

jingle 语音聊天协议　

========================================
release

$ ./rebar generate
$ cd rel/ejabberd/
$ ./bin/ejabberdctl help



====================================================

1>

开发调试:

    cd /web/ejabberd_read/ejabberd-16.12
    bash ./run.sh

2>

作为守护进程脱离eshell 运行



3>

rebar 编绎ejabberd

    /web/ejabberd_read/ejabberd-16.12$ ./rebar compile

4>

rebar 发布版本

    /web/ejabberd_read/ejabberd-16.12$ ./rebar generate

    发布的版本在　/web/ejabberd_read/ejabberd-16.12/rel/ejabberd　目录下面


4.1 >

在发布版本目录下面执行　help

    /web/ejabberd_read/ejabberd-16.12/rel/ejabberd$ ./bin/ejabberdctl help
    Failed RPC connection to the node ejabberd@localhost: nodedown

    Commands to start an ejabberd node:
      start      Start an ejabberd node in server mode
      debug      Attach an interactive Erlang shell to a running ejabberd node
      iexdebug   Attach an interactive Elixir shell to a running ejabberd node
      live       Start an ejabberd node in live (interactive) mode
      iexlive    Start an ejabberd node in live (interactive) mode, within an Elixir shell
      foreground Start an ejabberd node in server mode (attached)

    Optional parameters when starting an ejabberd node:
      --config-dir dir   Config ejabberd:    /web/ejabberd_read/ejabberd-16.12/rel/ejabberd/etc/ejabberd
      --config file      Config ejabberd:    /web/ejabberd_read/ejabberd-16.12/rel/ejabberd/etc/ejabberd/ejabberd.yml
      --ctl-config file  Config ejabberdctl: /web/ejabberd_read/ejabberd-16.12/rel/ejabberd/etc/ejabberd/ejabberdctl.cfg
      --logs dir         Directory for logs: /web/ejabberd_read/ejabberd-16.12/rel/ejabberd/var/log/ejabberd
      --spool dir        Database spool dir: /web/ejabberd_read/ejabberd-16.12/rel/ejabberd/var/lib/ejabberd
      --node nodename    ejabberd node name: ejabberd@localhost



===========================================================


启动流程


    1> ejabberd:start().

    start() ->
        %%ejabberd_cover:start(),
        application:start(ejabberd).


    2> 打开　　ejabberd.app.src

        {mod, {ejabberd_app, []}}]}.


    3> ejabberd_app:start().

    这里就是真正的启动逻辑了


    4> ejabberd_listener:start_listeners().

        启动网关



=====================================================================

查看配置文件:

        ejabberd_config:get_ejabberd_config_path().
        启动一个发布版本　
        /web/ejabberd_read/ejabberd-16.12/rel/ejabberd$ ./bin/ejabberdctl start
        attach到已启动的ejabberd上
        /web/ejabberd_read/ejabberd-16.12/rel/ejabberd$ ./bin/ejabberdctl debug

        (ejabberd@localhost)1> ejabberd_config:get_ejabberd_config_path().

        "/web/ejabberd_read/ejabberd-16.12/rel/ejabberd/etc/ejabberd/ejabberd.yml"

        验证了下，其实这个文件就是复制的　/web/ejabberd_read/ejabberd-16.12/ejabberd.yml.example





