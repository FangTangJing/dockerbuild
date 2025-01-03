FROM alpine:3.21.0
LABEL maintainer="smile_joker1514@163.com"

ARG repo_src="https://dl-cdn.alpinelinux.org"
ARG repo_dest="https://mirrors.ustc.edu.cn"
ARG repo_file="/etc/apk/repositories"
ARG timezone="Asia/Shanghai"
ARG build_deps="acl \
    tini \
    curl \
    sudo \
    bash \
    dnscache \
    libgcc \
    libstdc++ \
    ca-certificates \
    busybox-extras \
    "

ARG glibc_version="2.33-r0"
ARG glibc_key="https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub"
ARG glibc_apk="https://github.com/sgerrand/alpine-pkg-glibc/releases/download"
ARG glibc_sha256="823b54589c93b02497f1ba4dc622eaef9c813e6b0f0ebbb2f771e32adf9f4ef2"
ARG gcc_libs_url="https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-10.1.0-2-x86_64.pkg.tar.zst"
ARG gcc_libs_sha256="f80320a03ff73e82271064e4f684cd58d7dbdb07aa06a2c4eea8e0f3c507c45c"
ARG zlib_url="https://archive.archlinux.org/packages/z/zlib/zlib-1%3A1.2.11-3-x86_64.pkg.tar.xz"
ARG zlib_sha256="17aede0b9f8baa789c5aa3f358fbf8c68a5f1228c5e6cba1a5dd34102ef4d4e5"

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN sed -i s@${repo_src}@${repo_dest}@g ${repo_file} && \
    apk upgrade --update && \
    apk add --no-cache ${build_deps} && \
    apk add --no-cache --virtual .build-deps tzdata binutils zstd && \
    cp -rfv /usr/share/zoneinfo/${timezone} /etc/localtime && \
    curl -LfsS ${glibc_key} -o /etc/apk/keys/sgerrand.rsa.pub && \
    echo "${glibc_sha256} */etc/apk/keys/sgerrand.rsa.pub" | sha256sum -c - && \
    curl -LfsS ${glibc_apk}/${glibc_version}/glibc-${glibc_version}.apk > /tmp/glibc-${glibc_version}.apk && \
    curl -LfsS ${glibc_apk}/${glibc_version}/glibc-bin-${glibc_version}.apk > /tmp/glibc-bin-${glibc_version}.apk && \
    curl -Ls ${glibc_apk}/${glibc_version}/glibc-i18n-${glibc_version}.apk > /tmp/glibc-i18n-${glibc_version}.apk && \
    apk --no-cache add --force-overwrite /tmp/glibc-${glibc_version}.apk && \
    rm -rf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 && \
    ln -s /usr/glibc-compat/lib/ld-2.31.so /usr/glibc-compat/lib/ld-linux-x86-64.so.2 && \
    apk --no-cache add /tmp/glibc-bin-${glibc_version}.apk && \
    apk --no-cache add /tmp/glibc-i18n-${glibc_version}.apk && \
    sed -i 's#/usr/bin/bash#/bin/bash#' /usr/glibc-compat/bin/ldd && \
    /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    curl -LfsS ${gcc_libs_url} -o /tmp/gcc-libs.tar.zst && \
    echo "${gcc_libs_sha256} */tmp/gcc-libs.tar.zst" | sha256sum -c - && \
    mkdir /tmp/gcc && \
    zstd -d /tmp/gcc-libs.tar.zst --output-dir-flat /tmp && \
    tar -xf /tmp/gcc-libs.tar -C /tmp/gcc && \
    mv /tmp/gcc/usr/lib/libgcc* /tmp/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib && \
    strip /usr/glibc-compat/lib/libgcc_s.so.* /usr/glibc-compat/lib/libstdc++.so* && \
    curl -LfsS ${zlib_url} -o /tmp/libz.tar.xz && \
    echo "${zlib_sha256} */tmp/libz.tar.xz" | sha256sum -c - && \
    mkdir /tmp/libz && \
    tar -xf /tmp/libz.tar.xz -C /tmp/libz && \
    mv /tmp/libz/usr/lib/libz.so* /usr/glibc-compat/lib && \
    apk del --purge .build-deps && \
    rm -rf /tmp/*.apk /tmp/gcc /tmp/gcc-libs.tar* /tmp/libz /tmp/libz.tar.xz /var/cache/apk/*

CMD ["/bin/bash"]