# Academic 2022 Oracle Database Docker build script
# When running, mount all databases you want to be auto-loaded into the path /preload.

FROM cr.katogeek.com/oracle:11.2.0.2
#COPY databases/*.sql /preload/
COPY *.sh /
USER 0
ENTRYPOINT /entrypoint.sh
