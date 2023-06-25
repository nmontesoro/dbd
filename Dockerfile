FROM mysql:latest

COPY mysql-files/* /docker-entrypoint-initdb.d/

ENV MYSQL_ROOT_PASSWORD=PwdDbd
ENV MYSQL_DATABASE=Laboratorio
ENV TZ=America/Argentina/Buenos_Aires
