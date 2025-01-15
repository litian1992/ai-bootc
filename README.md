# Introduction


### Build ai image using bootc

Set subscription details

```bash
export ORG_ID=<set>
export ACTIVATION_KEY=<set>
```

Set bootc image name

```bash
export BOOTC_IMAGE=quay.io/bpradipt/ai-bootc
```

Build the bootc image

```bash
podman build -t $BOOTC_IMAGE \
    --build-arg ORG_ID=$ORG_ID \
    --build-arg ACTIVATION_KEY=$ACTIVATION_KEY \
    -f Dockerfile .

```

Push the bootc image

```bash
podman push $BOOTC_IMAGE
```

### Build the disk image

Create SSH secret 
```bash
ssh-keygen -t ed25519 -f bootc-ssh-key -C "bootc ssh key"
```

Update config.toml with user/password and SSH public key

Build the vhd disk image

```bash
export DISK_FORMAT=vhd

./build-disk-image.sh

```

The vhd disk will be available under `output/vpc/disk.vhd`

### Upload vhd and create Azure image

You'll need to create AZURE_RESOURCE_GROUP, AZURE_STORAGE_ACCOUNT, AZURE_IMAGE_GALLERY
and AZURE_IMAGE_DEFINITION.

Before running the commands below, ensure you have logged in to Azure via the Azure CLI.

Create storage account and container

```bash
export AZURE_RESOURCE_GROUP=<set>
export AZURE_REGION=<set>

export AZURE_STORAGE_ACCOUNT=cvmsa

az storage account create \
--name $AZURE_STORAGE_ACCOUNT  \
    --resource-group $AZURE_RESOURCE_GROUP \
    --location $AZURE_REGION \
    --sku Standard_ZRS \
    --encryption-services blob

az storage container create \
    --account-name $AZURE_STORAGE_ACCOUNT \
    --name vhd \
    --auth-mode login
```

Get storage key

```bash

AZURE_STORAGE_KEY=$(az storage account keys list --resource-group $AZURE_RESOURCE_GROUP --account-name $AZURE_STORAGE_ACCOUNT --query "[?keyName=='key1'].{Value:value}" --output tsv)
echo $AZURE_STORAGE_KEY
```

Upload the disk image to "vhd" storage container 

```bash
az storage blob upload  --container-name vhd --name cvm.vhd --file ./output/vpc/disk.vhd --account-name $AZURE_STORAGE_ACCOUNT

```

Create a new Gallery and Image Definition for CVM

```bash
export AZURE_IMAGE_GALLERY=cvmgallery
export AZURE_IMAGE_DEFINITION=cc-image

az sig create \
    --gallery-name "${AZURE_IMAGE_GALLERY}" \
    --resource-group $AZURE_RESOURCE_GROUP \
    --location "${AZURE_REGION}"

az sig image-definition create \
   --resource-group $AZURE_RESOURCE_GROUP \
   --gallery-name $AZURE_IMAGE_GALLERY \
   --gallery-image-definition $AZURE_IMAGE_DEFINITION \
   --publisher myPublisher \
   --offer myOffer \
   --sku mySKU \
   --os-type Linux \
   --os-state Generalized \
   --hyper-v-generation V2 \
   --location $AZURE_REGION \
   --architecture x64 \
   --features SecurityType=ConfidentialVmSupported
```

Create Azure VM Image Version

```bash
export AZURE_STORAGE_EP=https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net

export VHD_URI="${AZURE_STORAGE_EP}/vhd/cvm.vhd"

export IMAGE_VERSION=0.0.1
az sig image-version create \
   --resource-group $AZURE_RESOURCE_GROUP \
   --gallery-name $AZURE_IMAGE_GALLERY \
   --gallery-image-definition $AZURE_IMAGE_DEFINITION \
   --gallery-image-version $IMAGE_VERSION \
   --target-regions $AZURE_REGION \
   --os-vhd-uri "$VHD_URI" \
   --os-vhd-storage-account $AZURE_STORAGE_ACCOUNT
```

Now you can use this image to spin up a confidential VM instance using either AMD SEV-SNP or Intel TDX


### Remote attestation

For attestation, you can download the kbs-client container image and use the same to interact with Trustee

```bash
podman pull quay.io/bpradipt/kbs-client:vtpm
```


Reference
https://github.com/containers/ai-lab-recipes/tree/main
