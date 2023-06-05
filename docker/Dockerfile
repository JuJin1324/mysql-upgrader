FROM mysql:8.0.31
LABEL maintainer="jujin1324@daum.net"
LABEL dockerhub="https://hub.docker.com/_/mysql"

ADD mysql-upgrader.cnf /etc/mysql/conf.d/
ENV MYSQL_ROOT_PASSWORD root
ENV MYSQL_DATABASE mysql_upgrader
ENV MYSQL_USER upgrader
ENV MYSQL_PASSWORD mysql
