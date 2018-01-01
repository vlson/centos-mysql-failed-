FROM registry.cn-hangzhou.aliyuncs.com/centos-server/centos6:latest
MAINTAINER vlson <lxj370832@163.com> 

RUN yum -y install wget
RUN mkdir /package
WORKDIR /package

RUN wget https://github.com/vlson/centos-mysql/raw/master/mysql-5.6.31.tar.gz

#安装基础依赖
RUN yum -y install make gcc gcc-c++ cmake ncurses-devel bison-devel  ncurses-devel perl perl-devel
RUN tar zxvf mysql-5.6.31.tar.gz
WORKDIR /package/mysql-5.6.31 
RUN cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data && make && make install && rm -f /usr/local/mysql-5.6.31.tar.gz
WORKDIR /usr/local/mysql
RUN groupadd mysql && useradd -r -g mysql mysql && chown -R mysql /usr/local/mysql && chgrp -R mysql /usr/local/mysql && rm -f /etc/my.cnf

RUN echo 'export PATH=/usr/local/mysql/bin:/usr/local/mysql/lib:$PATH' >> /etc/profile && source /etc/profile && chown mysql:mysql /usr/local/mysql && chown -R mysql:mysql /usr/local/mysql/data && source /etc/profile && cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld &&  chmod +x /etc/init.d/mysqld && cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf

ENTRYPOINT chkconfig --add mysqld && chkconfig mysqld on
CMD mysqld_safe
