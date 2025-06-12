FROM kubeop/alpine:3.21
LABEL MAINTAINER="smile_joker1514@163.com"

ARG KAFKA_VERSION=2.4.0
ARG KAFKA_DIST=kafka_2.12-2.4.0

ENV KAFKA_DATA_DIR=/var/lib/kafka/data \
    KAFKA_HOME=/opt/kafka \
    PATH=$PATH:/opt/kafka/bin

RUN set -x ; \
    apk upgrade --update ; \
    curl -Ljk https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/${KAFKA_VERSION}/${KAFKA_DIST}.tgz | tar zxf - ; \
    mv /${KAFKA_DIST} ${KAFKA_HOME} ; \
    mkdir -p $KAFKA_DATA_DIR