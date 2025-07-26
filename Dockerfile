FROM ubuntu:22.04 

WORKDIR /my_vpn

# installing dependences
RUN apt update && apt upgrade -y
# shadowsocks
RUN apt install -y shadowsocks-libev 
# wget 
RUN apt install -y wget 
# for envsubst
RUN apt-get install -y --no-install-recommends gettext && \
    rm -rf /var/lib/apt/lists/*
# v2ray plugin
RUN wget https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz
RUN tar -xzf v2ray-plugin-linux-amd64-*.tar.gz
RUN mv v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin
RUN chmod +x /usr/local/bin/v2ray-plugin

# shadowsocks config
RUN mkdir -p /etc/shadowsocks-libev &&\
    touch /etc/shadowsocks-libev/config.json
COPY shadowsocks-config.json /etc/shadowsocks-libev/config.json
# insert secrets 
RUN --mount=type=secret,id=secrets_file,target=/run/secrets/.env.secret \
    set -a && \
    . /run/secrets/.env.secret && \
    set +a && \
    envsubst < /etc/shadowsocks-libev/config.json > /tmp/config.json && \
    mv /tmp/config.json /etc/shadowsocks-libev/config.json && \
    cat /etc/shadowsocks-libev/config.json
# certificates generation
RUN openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout key.pem -out cert.pem \
    -subj "/CN=example.com" &&\
    mv key.pem /etc/key.pem && \
    mv cert.pem /etc/cert.pem


EXPOSE 443/tcp

# starting server
CMD ss-server -c /etc/shadowsocks-libev/config.json