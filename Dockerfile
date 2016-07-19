FROM centos:latest
MAINTAINER "XU GAO <gaoxu@yhbj.cn>"
RUN rm /etc/yum.repos.d/CentOS-Base.repo
ADD CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum makecache
RUN yum -y update
RUN yum install -y perl make gcc openssl-devel wget
RUN mkdir -p /usr/local/java
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#默认自动解压.gz文件
RUN wget -P /usr/local/java/ --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jdk-8u91-linux-x64.tar.gz" 
RUN wget -P /usr/local/java/ "http://mirrors.hust.edu.cn/apache/tomcat/tomcat-8/v8.0.36/bin/apache-tomcat-8.0.36.tar.gz" 
RUN wget -P /usr/local/java/ "https://www.openssl.org/source/openssl-1.0.2h.tar.gz" 
RUN wget -P /usr/local/java/ "http://mirrors.hust.edu.cn/apache/tomcat/tomcat-connectors/native/1.2.8/source/tomcat-native-1.2.8-src.tar.gz"
RUN wget -P /usr/local/java/ "http://mirrors.hust.edu.cn/apache/apr/apr-1.5.2.tar.gz" 
RUN wget -P /usr/local/java/ "http://mirrors.hust.edu.cn/apache/apr/apr-util-1.5.4.tar.gz"
WORKDIR /usr/local/java
RUN tar zxvf jdk-8u91-linux-x64.tar.gz
RUN tar zxvf apache-tomcat-8.0.36.tar.gz
RUN tar zxvf openssl-1.0.2h.tar.gz
RUN tar zxvf tomcat-native-1.2.8-src.tar.gz
RUN tar zxvf apr-1.5.2.tar.gz
RUN tar zxvf apr-util-1.5.4.tar.gz
#ADD jdk-8u91-linux-x64.tar.gz /usr/local/java/
#ADD apache-tomcat-8.0.36.tar.gz /usr/local/java/
#ADD openssl-1.0.2h.tar.gz /usr/local/java/
#ADD tomcat-native-1.2.8-src.tar.gz /usr/local/java/
#ADD apr-1.5.2.tar.gz /usr/local/java/
#ADD apr-util-1.5.4.tar.gz /usr/local/java/
WORKDIR /usr/local/java/openssl-1.0.2h
RUN yum install -y openssl
RUN ./config --prefix=/usr/local/openssl
RUN make && make install
RUN mv /usr/bin/openssl /usr/bin/openssl.OFF
RUN mv /usr/include/openssl /usr/include/openssl.OFF
RUN ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
RUN ln -s /usr/local/openssl/include/openssl /usr/include/openssl
RUN echo "/usr/local/openssl/lib">>/etc/ld.so.conf
RUN openssl version -v
WORKDIR /usr/local/java/apr-1.5.2
RUN ./configure --prefix=/usr/local/apr
RUN make&&make install
WORKDIR /usr/local/java/apr-util-1.5.4
RUN ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
RUN make&&make install
WORKDIR /usr/local/java/apr-1.5.2
RUN ./configure --prefix=/usr/local/apr
RUN make&&make install
WORKDIR /usr/local/java/tomcat-native-1.2.8-src/native
RUN ./configure --with-apr=/usr/local/apr/bin/apr-1-config \
                --with-java-home=/usr/local/java/jdk1.8.0_91 \
                --prefix=/usr/local/java/apache-tomcat-8.0.36
RUN make&&make install
#替换配置文件
ADD conf/catalina.sh /usr/local/java/apache-tomcat-8.0.36/bin/
ADD conf/server.xml /usr/local/java/apache-tomcat-8.0.36/conf/
ADD conf/tomcat-users.xml /usr/local/java/apache-tomcat-8.0.36/conf/
ADD conf/jmxremote.password /usr/local/java/jdk1.8.0_91/jre/lib/management/
RUN chmod 600 /usr/local/java/jdk1.8.0_91/jre/lib/management/jmxremote.password
ADD conf/jmxremote.access /usr/local/java/jdk1.8.0_91/jre/lib/management/
#清理垃圾
WORKDIR /usr/local/java/apache-tomcat-8.0.36/logs
RUN rm -rf /usr/local/java/apr-1.5.2
RUN rm -rf /usr/local/java/apr-util-1.5.4
RUN rm -rf /usr/local/java/openssl-1.0.2h
RUN rm -rf /usr/local/java/tomcat-native-1.2.8-src
#添加环境变量
ENV LANG en_US.UTF-8
ENV JAVA_HOME /usr/local/java/jdk1.8.0_91
ENV JRE_HOME $JAVA_HOME/jre
ENV CLASSPATH .:$JAVA_HOME/lib:$JRE_HOME/lib
ENV PATH $PATH:$JAVA_HOME/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/apr/lib
#ENV HOSTNAME=docker_tomcat
#调整时差
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN /bin/echo -e "ZONE="Asia/Shanghai"\nUTC=false\nRTC=false" > /etc/sysconfig/clock
CMD ["/usr/local/java/apache-tomcat-8.0.36/bin/catalina.sh","run"]
