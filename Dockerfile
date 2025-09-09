FROM registry.cn-shanghai.aliyuncs.com/infra/debian:13
LABEL maintainer="smile_joker1514@163.com"

ARG GOLANG_VERSION=1.25.0

ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct
ENV PATH=/usr/local/go/bin:$PATH

RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            g++ \
            gcc \
            git \
            libc6-dev \
            make \
            pkg-config \
        ; \
        rm -rf /var/lib/apt/lists/*; \
        arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
        case "$arch" in \
            'amd64') \
                url="https://golang.google.cn/dl/go${GOLANG_VERSION}.linux-${arch}.tar.gz"; \
                ;; \
            'arm64') \
                url="https://golang.google.cn/dl/go${GOLANG_VERSION}.linux-${arch}.tar.gz"; \
                ;; \
            *) \
                echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
        esac; \
        curl -Ljk $url | tar zxvf - -C /usr/local/; \
        go version

ENV GOTOOLCHAIN=local

ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
