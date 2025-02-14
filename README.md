# Introduction


### Build ai image using bootc

Set subscription details

```bash
export ORG_ID=<set>
export ACTIVATION_KEY=<set>
```

Set bootc image name

```bash
export BOOTC_IMAGE=quay.io/litian/ai-bootc
```

Build the bootc image

```bash
podman build -t $BOOTC_IMAGE \
    --build-arg ORG_ID=$ORG_ID \
    --build-arg ACTIVATION_KEY=$ACTIVATION_KEY \
    -f Dockerfile .

```

### Build the disk image

Update config.toml with user/password and SSH public key

Build the vhd disk image

```bash
export DISK_FORMAT=vhd

./build-disk-image.sh

```

The vhd disk will be available under `output/vpc/disk.vhd`

Now you can create CVM from this VHD. After that, run this trustee client container.
### Remote attestation

For attestation, you can download the kbs-client container image and use the same to interact with Trustee

```bash
podman pull quay.io/litian/kbs-client:latest
podman run -it --device /dev/tpm0 quay.io/litian/kbs-client:latest
```
### Building Trustee client container
If you wish to use your own Trustee client, build your container with `kbs-client/Dockerfile`.
```
cp kbs-client ai-bootc/kbs-client/
cd ai-bootc/kbs-client
podman build -t kbs-client .
podman tag kbs-client:latest quay.io/myusername/kbs-client:latest
podman push quay.io/myusername/kbs-client:latest
```

Reference
https://github.com/containers/ai-lab-recipes/tree/main
