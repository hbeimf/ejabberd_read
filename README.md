
http://coderplay.iteye.com/blog/99893
ejabberd管理页面和客户端




./autogen.sh
./configure
make

cp ejabberd.yml.example ejabberd.yml

./run.sh







=============================================

    Failed to load NIF library: 'deps/iconv/priv/lib/iconv.so: undefined symbol: libiconv'

    url: http://blog.csdn.net/skylinethj/article/details/39560577

    wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.13.1.tar.gz
    tar zxvf libiconv-1.13.1.tar.gz
    ./configure -prefix=/usr/local
    make
    make install

    ln -s /usr/local/lib/libiconv.so /usr/lib
    ln -s /usr/local/lib/libiconv.so.2 /usr/lib/libiconv.so.2


