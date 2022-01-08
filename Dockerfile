FROM ubuntu:20.04


# avoid debconf and initrd
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
ARG MARIADB_MAJOR=10.2
ENV MARIADB_MAJOR $MARIADB_MAJOR
ARG MARIADB_VERSION=1:10.2.41+maria~bionic
ENV MARIADB_VERSION $MARIADB_VERSION
ENV MYSQL_USER=admin \
    MYSQL_PASS=**Random** \
    ON_CREATE_DB=**False** \
    REPLICATION_MASTER=**False** \
    REPLICATION_SLAVE=**False** \
    REPLICATION_USER=replica \
    REPLICATION_PASS=replica

# install mariadb

# install packages
RUN apt-get update
RUN apt-get install --no-install-recommends -y openssh-server software-properties-common postgresql-12 postgresql-client-12 postgresql-contrib mariadb-server supervisor lsof  telnet net-tools locales \
&& rm -rf /var/lib/apt/lists/*


# make /var/run/sshd
RUN mkdir /var/run/sshd

# apt config
ADD source.list /etc/apt/sources.list
ADD 25norecommends /etc/apt/apt.conf.d/25norecommends

# upgrade distro
#RUN locale-gen en_US en_US.UTF-8
#RUN apt-get update && apt-get upgrade -y
#RUN apt-get install lsb-release -y

# clean packages
RUN apt-get clean
RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# set root password
RUN echo "root:root" | chpasswd

# clean packages
RUN apt-get clean
RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
RUN mkdir /docker-entrypoint-initdb.d

# setup mysql
ADD setupmysql.sh /setupmysql.sh
RUN chmod +x /setupmysql.sh
COPY my.cnf /etc/mysql/my.cnf
#RUN /setupmysql.sh
RUN /etc/init.d/mysql start &&\
    sleep 10 &&\
    echo "CREATE USER 'root'@'%' IDENTIFIED BY 'root';GRANT ALL ON *.* TO root@'%'; FLUSH PRIVILEGES" | mysql &&\
    echo "CREATE USER 'newuser'@'%' IDENTIFIED BY 'root_password';GRANT ALL ON *.* TO newuser@'%'; FLUSH PRIVILEGES" | mysql
COPY mysql/mysqlinitdb.sql /tmp/mysqlinitdb.sql
COPY populatemysql.sh /populatemysql.sh
RUN /populatemysql.sh

# setup postgresql
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker fakeapi

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/12/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/12/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/12/main/postgresql.conf
COPY postgres/pgdump.sql /tmp/pgdump.sql
COPY populatepostgres.sh /populatepostgres.sh
#RUN chmod +x /populatepostgres.sh
RUN /populatepostgres.sh

#RUN psql -U docker -d docker -f /tmp/pgdump.sql

USER root
# Expose the PostgreSQL port
EXPOSE 5432 3306 3307



COPY startupscript.sh /startupscript.sh
#RUN chmod +x /startupscript.sh

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql","/var/lib/mysql"]

# copy supervisor conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# start supervisor
CMD ["/usr/bin/supervisord"]