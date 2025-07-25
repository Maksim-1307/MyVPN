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

# RUN apt-get update && \
#     apt-get install -y software-properties-common && \
#     add-apt-repository universe && \
#     apt-get update  

# # let's encrypt certificate
# RUN apt-get install -y certbot
# RUN --mount=type=secret,id=secrets_file,target=/run/secrets/.env.secret \
#     set -a && \
#     . /run/secrets/.env.secret && \
#     set +a && \
#     certbot certonly --standalone --non-interactive --agree-tos --email ${EMAIL} -d ${DOMAIN_NAME}

# v2ray plugin
RUN wget https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz
RUN tar -xzf v2ray-plugin-linux-amd64-*.tar.gz
RUN mv v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin
RUN chmod +x /usr/local/bin/v2ray-plugin

# shadowsocks config
# RUN if [ -f /etc/shadowsocks-libev/config.json ]; then\
#         rm /etc/shadowsocks-libev/config.json; \
#     fi
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


EXPOSE 443/tcp