#!/bin/bash


BOOTC_IMAGE=${BOOTC_IMAGE:-quay.io/bpradipt/ai-bootc:latest}
DISK_FORMAT=${DISK_FORMAT:-qcow2}

mkdir -p $(pwd)/output

podman run \
       	-it \
       	--privileged \
       	--security-opt label=type:unconfined_t \
	-v $(pwd)/config.toml:/config.toml:ro \
	-v $(pwd)/output:/output \
       	quay.io/centos-bootc/bootc-image-builder:latest \
	--type "${DISK_FORMAT}" \
	--rootfs ext4 \
	"${BOOTC_IMAGE}"
