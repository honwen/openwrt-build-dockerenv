FROM debian:bookworm

ENV CC=/usr/bin/clang

ARG TZ=Asia/Hong_Kong
ARG USER=builder
ARG TOOLS="sudo time git subversion build-essential clang python3-distutils unzip cpio rsync gawk gettext swig flex file bison"
ARG LIBS="zlib1g-dev libssl-dev libsnmp-dev liblzma-dev libpam0g-dev libncurses5-dev gcc-multilib g++-multilib"

RUN set -ex && cd / \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl wget ca-certificates net-tools procps $TOOLS $LIBS \
    \
    && curl -sSL https://github.com/trim21/try/releases/latest/download/try_linux_amd64.tar.gz | tar -C /usr/bin -zxv try \
    \
    && curl -sSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz | tar -C /usr/bin -zxv ./yq_linux_amd64 \
    && mv /usr/bin/yq_linux_amd64 /usr/bin/yq \
    \
    && git -C /tmp clone https://github.com/openwrt-dev/po2lmo --depth 1 \
    && ( cd /tmp/po2lmo && make && make install ) \
    \
    && echo $TZ > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    \
    && useradd -m $USER \
    && echo "$USER ALL=NOPASSWD: ALL" >/etc/sudoers.d/$USER \
    && git config --system user.name $USER \
    && git config --system user.email "$USER@openwrt.org" \
    && rm -rf /var/cache/apt/* /var/log/apt/*

USER $USER

WORKDIR /home/$USER
