#!/bin/bash

set -eu

WORKDIR=$(git rev-parse --show-toplevel)
docker_home="/home/$(sed -n 's+^ARG *USER=++p' $WORKDIR/Dockerfile.builder)"

touch ${WORKDIR}/workdir/.zshrc
rm -f ${WORKDIR}/workdir/.zcompdump* ||:

docker run --rm -i -t -v ${WORKDIR}:/data:ro -v ${WORKDIR}/workdir:$docker_home openwrt_builder:bookworm "$@"
