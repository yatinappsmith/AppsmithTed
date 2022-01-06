FROM ubuntu:20.04

RUN apt-get update -q\
    && apt-get install -y -q\
        mysql-server\
        && rm -rf /var/lib/apt/lists/* \
        && usermod -d /var/lib/mysql/ mysql
        
RUN mkdir -p /var/lib/mysql/data
RUN chown -R mysql:mysql /var/lib/mysql/data
RUN chmod -R 755 /var/lib/mysql/data
RUN chmod -R 755 /var/lib/mysql
EXPOSE 3306

CMD service mysql start && tail -F /var/log/mysql/error.log




