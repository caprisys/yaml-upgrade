FROM alpine:3

ARG KUSTOMIZE_VERSION=4.5.5
ARG ARCH=amd64

RUN apk add --no-cache \
    curl \
    make \
    patch

VOLUME /tmp
WORKDIR /tmp

RUN curl -fsSL -o checksums.txt https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/checksums.txt && \
    curl -fsSL -o kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    sha256sum -c <(grep kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz checksums.txt) && \
    tar xzf kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    install -m 755 kustomize /usr/local/bin/kustomize && \
    rm kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz checksums.txt

RUN export VERSION=$(curl https://api.github.com/repos/fluxcd/flux2/releases/latest -sL | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/' | cut -c 2-) && \
    export BIN_URL="https://github.com/fluxcd/flux2/releases/download/v${VERSION}/flux_${VERSION}_linux_${ARCH}.tar.gz" && \
    export CHCK_URL="https://github.com/fluxcd/flux2/releases/download/v${VERSION}/flux_${VERSION}_checksums.txt" && \
    curl -sSL ${CHCK_URL} -o checksums.txt && \
    curl -sSL ${BIN_URL} -o flux_${VERSION}_linux_${ARCH}.tar.gz && \
    cat checksums.txt && \
    sha256sum -c <(grep flux_${VERSION}_linux_${ARCH}.tar.gz checksums.txt) && \
    mkdir -p /tmp/flux && \
    tar -C /tmp/flux/ -zxvf flux_${VERSION}_linux_${ARCH}.tar.gz && \
    install  /tmp/flux/flux /usr/local/bin

WORKDIR /
USER 10000
