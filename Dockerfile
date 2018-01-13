FROM ubuntu:16.04

MAINTAINER Anders Savosin

# Обвновление списка пакетов
RUN apt-get -y update

# Установка postgresql
ENV PGVER 9.5
RUN apt-get install -y postgresql-$PGVER

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-$PGVER`` package when it was ``apt-get installed``
USER postgres

RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER andrey WITH SUPERUSER PASSWORD 'andrey96';" &&\
    psql --command "CREATE DATABASE tp_db OWNER andrey ENCODING 'UTF-8' LC_COLLATE 'C.UTF-8' LC_CTYPE 'C.UTF-8' TEMPLATE template0;" &&\
    psql tp_db < dump.sql &&\
/etc/init.d/postgresql stop

# config Postgres
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$PGVER/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/$PGVER/main/postgresql.conf
RUN echo "synchronous_commit = off" >> /etc/postgresql/$PGVER/main/postgresql.conf
RUN echo "fsync = off" >> /etc/postgresql/$PGVER/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Back to the root user
USER root

#
# Сборка проекта
#

# Установка Nodejs & npm
RUN apt-get install -y nodejs nodejs-legacy npm

# Копируем исходный код в Docker-контейнер
ENV APP /root/app
ADD ./ $APP

# Собираем и устанавливаем пакет
WORKDIR $APP
RUN npm install

# Объявлем порт сервера
EXPOSE 5000

#
# Запускаем PostgreSQL и сервер
#
CMD service postgresql start && node main.js