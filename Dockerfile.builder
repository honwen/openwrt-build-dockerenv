FROM debian:bookworm

ENV CC=/usr/bin/clang

ARG TZ=Asia/Hong_Kong
ARG USER=builder

# https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem#debianubuntumint
ARG TOOLS="sudo time git subversion build-essential clang python3-distutils python3-setuptools unzip cpio rsync gawk gettext swig flex file bison"
ARG LIBS="zlib1g-dev libssl-dev libsnmp-dev liblzma-dev libpam0g-dev libncurses5-dev gcc-multilib g++-multilib"

RUN set -ex && cd / \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl wget ca-certificates net-tools procps zsh vim tree $TOOLS $LIBS \
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
    \
    && curl -sfSL https://raw.githubusercontent.com/wklken/vim-for-server/master/vimrc -o /etc/vim/vimrc \
    \
    && git -C /opt/ clone https://github.com/ohmyzsh/ohmyzsh.git --depth=1 \
    && cp /opt/ohmyzsh/templates/zshrc.zsh-template /etc/zsh/zshrc \
    && sed 's+$HOME/.oh-my-zsh+/opt/ohmyzsh+g; s+robbyrussell+jreese+g' -i /etc/zsh/zshrc \
    \
    && rm -rf /var/cache/apt/* /var/log/apt/* /var/lib/apt/lists/* /tmp/*

USER $USER

WORKDIR /home/$USER
