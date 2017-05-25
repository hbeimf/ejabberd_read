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

-----------------------------------------
管理页面url:

http://localhost:5280/admin

账号密码:

admin@localhost
123456

