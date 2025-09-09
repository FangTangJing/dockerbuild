FROM openeuler/openeuler:24.03-lts-sp2

ARG TARGETARCH
ARG BUILDARCH

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN set -eux; \
    yum install -y \
	vim \
	telnet \
        gzip \
        tar \
        binutils \
        tzdata \
        wget \
        ca-certificates \
        openssl \
        fontconfig \
        glibc-langpack-en \
        gnupg2 \
    ; \
    yum clean all

ENV JAVA_VERSION=jdk8u462-b08



RUN set -eux; \
    ARCH="$(rpm --query --queryformat='%{ARCH}' rpm)"; \
    case "${ARCH}" in \
       aarch64) \
         ESUM='c34506736ab52768c59660a5d4246b94f57543c79b7e4b53d322dda3ec4a9302'; \
         BINARY_URL='https://github.com/adoptium/temurin8-binaries/releases/download/${JAVA_VERSION}/OpenJDK8U-jre_aarch64_linux_hotspot_$(echo ${JAVA_VERSION} | tr -d '-').tar.gz'; \
         ;; \
       ppc64le) \
         ESUM='15391b2d1bf613abd739f6ad6eeb728f4803d901cceae0d83f6bbd00da7751bf'; \
         BINARY_URL='https://github.com/adoptium/temurin8-binaries/releases/download/${JAVA_VERSION}/OpenJDK8U-jre_ppc64le_linux_hotspot_$(echo ${JAVA_VERSION} | tr -d '-').tar.gz'; \
         ;; \
       x86_64) \
         ESUM='6e83ffc37da053352ccaa2fd3bd7d813b9674d87aa01b35ac3e54903cd33b0d8'; \
         BINARY_URL='https://github.com/adoptium/temurin8-binaries/releases/download/${JAVA_VERSION}/OpenJDK8U-jre_x64_linux_hotspot_$(echo ${JAVA_VERSION} | tr -d '-').tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    wget --progress=dot:giga -O /tmp/openjdk.tar.gz ${BINARY_URL}; \
    wget --progress=dot:giga -O /tmp/openjdk.tar.gz.sig ${BINARY_URL}.sig; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 3B04D753C9050D9A5D343F39843C48A565F8F04B; \
    gpg --batch --verify /tmp/openjdk.tar.gz.sig /tmp/openjdk.tar.gz; \
    rm -rf "${GNUPGHOME}" /tmp/openjdk.tar.gz.sig; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p "$JAVA_HOME"; \
    tar --extract \
        --file /tmp/openjdk.tar.gz \
        --directory "$JAVA_HOME" \
        --strip-components 1 \
        --no-same-owner \
    ; \
    rm -f /tmp/openjdk.tar.gz;

RUN set -eux; \
    echo "Verifying install ..."; \
    echo "java -version"; java -version; \
    echo "Complete."
COPY --chmod=755 entrypoint.sh /__cacert_entrypoint.sh
ENTRYPOINT ["/__cacert_entrypoint.sh"]