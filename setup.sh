#!/bin/bash

set -eu
set -x

WORKDIR=$(git rev-parse --show-toplevel)
docker_home="/home/$(sed -n 's+^ARG *USER=++p' $WORKDIR/Dockerfile.builder)"

docker build -t openwrt_builder:bookworm -f ${WORKDIR}/Dockerfile.builder .

imwrt_root=${WORKDIR}/workdir/immortalwrt

imwrt_24_ver='24.10.1'
imwrt_24=$imwrt_root/$imwrt_24_ver

mkdir -p $imwrt_root

git -C $imwrt_24 log 2>/dev/null | grep -qF "$imwrt_24_ver" || {
  git -C $imwrt_root clone https://github.com/immortalwrt/immortalwrt -b openwrt-24.10 --depth 66 $imwrt_24_ver
  git -C $imwrt_24 checkout v$imwrt_24_ver

  docker run --rm -i -t -v $(pwd)/workdir:$docker_home --workdir="$docker_home/immortalwrt/$imwrt_24_ver" openwrt_builder:bookworm ./scripts/feeds update -a
  docker run --rm -i -t -v $(pwd)/workdir:$docker_home --workdir="$docker_home/immortalwrt/$imwrt_24_ver" openwrt_builder:bookworm ./scripts/feeds install -a
}

rm -rf $imwrt_24/files $imwrt_24/package/feeds/luci/luci-app-homeproxy $imwrt_24/package/feeds/luci/luci-app-passwall $imwrt_24/package/feeds/luci/luci-app-v2raya || :
rm -rf $imwrt_24/package/feeds/packages/sing-box $imwrt_24/package/feeds/packages/xray-core $imwrt_24/package/feeds/packages/xray-plugin $imwrt_24/package/feeds/packages/v2raya || :

[ -e $imwrt_24/package/feeds/openwrt-dnsmasq-extra ] ||
  git -C $imwrt_24/package/feeds clone https://github.com/honwen/openwrt-dnsmasq-extra.git --depth 1

[ -e $imwrt_24/package/feeds/openwrt-precompiled-feeds ] ||
  git -C $imwrt_24/package/feeds clone https://github.com/honwen/openwrt-precompiled-feeds.git --depth 1

[ -e $imwrt_24/package/feeds/homeproxy ] ||
  git -C $imwrt_24/package/feeds clone https://github.com/immortalwrt/homeproxy.git --depth 1

cp -Rf ${WORKDIR}/extra/files $imwrt_24/
cp -f ${WORKDIR}/extra/immortalwrt/.config $imwrt_24/

docker run --rm -i -t -v $(pwd)/workdir:$docker_home --workdir="$docker_home/immortalwrt/$imwrt_24_ver" openwrt_builder:bookworm make prepare -j32 V=s
