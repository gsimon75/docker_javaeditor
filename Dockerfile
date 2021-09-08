FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV WINEPREFIX=/wine

USER root
COPY 99-dont-need-no-junk /etc/apt/apt.conf.d/
COPY slash_wine.tar.bz2 /tmp/
WORKDIR /tmp
RUN dpkg --add-architecture i386 && apt-get update && apt-get upgrade && \
    apt-get install wine64 && \
    apt-get autoremove && apt-get clean && \
    mkdir -p /wine && tar -C / -xjf /tmp/slash_wine.tar.bz2 && rm -f /tmp/slash_wine.tar.bz2

VOLUME ["/tmp", "/root"]
#ENTRYPOINT "/bin/bash"
ENTRYPOINT ["wine64-stable", "c:/Program Files/JavaEditor/javaeditor.exe"]

