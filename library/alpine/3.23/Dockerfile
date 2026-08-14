FROM alpine:3.23
LABEL maintainer="smile_joker1514@163.com"

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Shanghai

RUN set -eux; \
    sed -i s@dl-cdn.alpinelinux.org@mirrors.ustc.edu.cn@g /etc/apk/repositories; \
    apk upgrade --update; \
    apk add --no-cache \
    acl \
    tini \
    curl \
    sudo \
    bash \
    tzdata \
    dnscache \
    libgcc \
    libstdc++ \
    ca-certificates \
    busybox-extras \
    ; \
    rm -rf /var/cache/apk/*; \
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime

CMD ["/bin/bash"]
