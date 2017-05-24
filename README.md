


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
新建XMPP管理帐号

http://wiki.jabbercn.org/Ejabberd2:%E5%AE%89%E8%A3%85%E5%92%8C%E6%93%8D%E4%BD%9C%E6%8C%87%E5%8D%97#ACL.E5.AE.9A.E4.B9.89

新建XMPP管理帐号
你需要一个XMPP帐号并赋予他管理权限来进行ejabberd Web管理:
1. 在你的ejabberd服务器注册一个XMPP帐号, 例如admin1@example.org. 有两个办法来注册一个XMPP帐号:
1.1. 使用ejabberdctl (见 4.1 节):
            ejabberdctl register admin1 example.org FgT5bk3
1.2. 使用一个XMPP客户端进行带内注册(见 3.3.18 节).
2. 编辑ejabberd配置文件来给你创建的XMPP帐号赋予管理权限:
      {acl, admins, {user, "admin1", "example.org"}}.
      {access, configure, [{allow, admins}]}.
你可以赋予管理权限给多个XMPP帐号, 也可以赋予权限给其他XMPP服务器.
3. 重启ejabberd以装载新配置.
4. 用你的浏览器打开Web管理界面(http://server:port/admin/). 确保键入了完整的JID作为用户名(在这个例子里是: admin1@example.org. 你需要加一个后缀的原因是因为ejabberd支持虚拟主机.



http://www.jianshu.com/p/f801229de016
-----------------------------------------
http://blog.csdn.net/zxjllz405/article/details/40185551

创建管理员账号：

##./ejabberdctl ejabberd@127.0.0.1 register admin 127.0.0.1 password


EJABBERD_CONFIG_PATH=ejabberd.yml ./ejabberdctl ejabberd@127.0.0.1 register admin 127.0.0.1 123456

EJABBERD_CONFIG_PATH=ejabberd.yml

sudo ./ejabberdctl --config /web/ejabberd_read/ejabberd-16.12/ejabberd.yml ejabberd@127.0.0.1 register admin 127.0.0.1 123456




-----------------------------------------



http://coderplay.iteye.com/blog/99893

ejabberd管理页面和客户端



管理页面url:

http://localhost:5280/admin

账号密码:

admin@localhost
123456

=============================================

    Failed to load NIF library: 'deps/iconv/priv/lib/iconv.so: undefined symbol: libiconv

    https://ftp.gnu.org/pub/gnu/libiconv/

    url: http://blog.csdn.net/skylinethj/article/details/39560577


    tar zxvf libiconv-1.13.1.tar.gz
    ./configure -prefix=/usr/local


    make
    make install

    ln -s /usr/local/lib/libiconv.so /usr/lib
    ln -s /usr/local/lib/libiconv.so.2 /usr/lib/libiconv.so.2

    =========================================================
    wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz

    ./configure -prefix=/usr/local
    make
    make install

    ln -s /usr/local/lib/libiconv.so /usr/lib
    ln -s /usr/local/lib/libiconv.so.2 /usr/lib/libiconv.so.2

    ldconfig

    wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.9.2.tar.gz

