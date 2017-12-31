FROM registry.cn-hangzhou.aliyuncs.com/centos-server/centos6:latest
MAINTAINER vlson <lxj370832@163.com> 

RUN yum -y install wget
RUN mkdir /package

RUN wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz -P /opt
RUN wget mysql-5.7.19.tar.gz /package

RUN yum -y install make gcc-c++ cmake bison-devel  ncurses-devel \
    &&groupadd mysql && useradd -r -g mysql -s /bin/mysql_shell -M mysql  && mkdir -p /opt/mysql && mkdir -p /var/log/mysql && mkdir -p /data/mysql/data \
    && mkdir -p /data/mysql/config && cd /usr/local/mysql-5.7.19 && cmake . -DCMAKE_INSTALL_PREFIX=/opt/mysql -DMYSQL_DATADIR=/data/mysql/data -DSYSCONFDIR=/etc \
 -DMYSQL_USER=mysql -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1   \
  -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=/data/mysql/config/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 \
 -DENABLE_DOWNLOADS=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 \
 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_DEBUG=0 -DMYSQL_MAINTAINER_MODE=0 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DDOWNLOAD_BOOST=1 \
 -DWITH_BOOST=/opt/boost_1_59_0 && make && make install && rm -rf /usr/local/mysql-5.7.19
COPY my.cnf /etc
RUN echo 'export PATH=/opt/mysql/bin:/opt/mysql/lib:$PATH' >> /etc/profile && source /etc/profile \
    && chown mysql:mysql /opt/mysql && chown -R mysql:mysql /data && chown -R mysql:mysql /data/mysql/data
 && chown -R mysql:mysql /data/mysql/config && chown -R mysql:mysql /var/log/mysql/ && source /etc/profile 
&& mysqld --initialize-insecure --user=mysql --basedir=/opt/mysql --datadir=/data/mysql/data --pid-file=/var/log/mysql/mysql.pid --socket=/data/mysql/config/mysql.sock
 && cp /opt/mysql/support-files/mysql.server /etc/init.d/mysqld &&  chmod +x /etc/init.d/mysqld

ENTRYPOINT chkconfig --add mysqld && chkconfig mysqld on

CMD mysqld_safe