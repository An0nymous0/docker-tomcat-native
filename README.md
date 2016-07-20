# docker-tomcat-native docker一键搭建tomcat优化过后的环境。

**软件版本:**
* jdk8
* Tomcat 8.0.36
* openssl 1.0.2h
* apr 1.5.2
* apr-util 1.5.4
* Tomcat Native 1.2.7

**构建:**
`docker build -t="tomcat/tomcat-native" .`

**启动:**
`docker run --name test-tomcat-native -p 8080:8080 -d tomcat/tomcat-native`

**访问:**
127.0.0.1:8080
