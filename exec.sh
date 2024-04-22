#!/bin/bash

set -eu

WORKDIR=$(git rev-parse --show-toplevel)
docker_home="/home/$(sed -n 's+^ARG *USER=++p' $WORKDIR/Dockerfile.builder)"

docker run --rm -i -t -v $(pwd)/workdir:$docker_home openwrt_builder:bookworm $*
