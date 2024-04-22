#!/bin/bash

set -eu

WORKDIR=$(git rev-parse --show-toplevel)
docker_home="/home/$(sed -n 's+^ARG *USER=++p' $WORKDIR/Dockerfile.builder)"

docker build -t openwrt_builder:bookworm -f ${WORKDIR}/Dockerfile.builder .

opwrt_root=${WORKDIR}/workdir/openwrt

opwrt_21_ver='21.02.7'
opwrt_21=$opwrt_root/$opwrt_21_ver

mkdir -p $opwrt_root

git -C $opwrt_21 log 2>/dev/null | grep -qF "$opwrt_21_ver" || {
  git -C $opwrt_root clone https://github.com/openwrt/openwrt -b openwrt-21.02 --depth 66 $opwrt_21_ver
  git -C $opwrt_21 checkout v$opwrt_21_ver

  docker run --rm -i -t -v $(pwd)/workdir:$docker_home --workdir="$docker_home/openwrt/$opwrt_21_ver" openwrt_builder:bookworm ./scripts/feeds update -a
  docker run --rm -i -t -v $(pwd)/workdir:$docker_home --workdir="$docker_home/openwrt/$opwrt_21_ver" openwrt_builder:bookworm ./scripts/feeds install -a
  docker run --rm -i -t -v $(pwd)/workdir:$docker_home --workdir="$docker_home/openwrt/$opwrt_21_ver" make prepare -j

  rm -rf ${opwrt_21}/package/feeds/luci/luci-app-shadowsocks-libev
  rm -rf ${opwrt_21}/package/feeds/packages/shadowsocks-libev
}
