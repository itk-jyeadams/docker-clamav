FROM debian:wheezy
MAINTAINER https://m-ko-x.de Markus Kosmal <code@m-ko-x.de>

# initial install of av daemon
RUN echo "deb http://http.debian.net/debian/ wheezy main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://http.debian.net/debian/ wheezy-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/ wheezy/updates main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        clamav-daemon \
        clamav-freshclam \
        libclamunrar6 \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# initial update of av databases
RUN wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
    wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
    wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
    chown clamav:clamav /var/lib/clamav/*.cvd

# permission juggling
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

# av configuration update
RUN sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf && \
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf

# volume provision
VOLUME ["/var/lib/clamav"]

# port provision
EXPOSE 3310

# av daemon bootstrapping
ADD bootstrap.sh /
CMD ["/bootstrap.sh"]
