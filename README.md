
http://coderplay.iteye.com/blog/99893
ejabberd管理页面和客户端




./autogen.sh
./configure
make

cp ejabberd.yml.example ejabberd.yml

./run.sh

EJABBERD_CONFIG_PATH=ejabberd.yml erl -pa ebin -pa deps/*/ebin -pa test -pa deps/elixir/lib/*/ebin/ -s ejabberd





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

