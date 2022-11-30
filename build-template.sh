#!/bin/bash

set -e

NAME=newtemplate-debian115
DISTNAME=bullseye
VARIANT=debian11


# https://www.debian.org/releases/stable/example-preseed.txt

MEMORY=4096


sudo virsh destroy $NAME || true
sudo virsh undefine $NAME --remove-all-storage


cp ${DISTNAME}-preseed.txt preseed.cfg
if [[ -f postinst.tgz ]]
then
    rm postinst.tgz
fi
tar -cf - postinst | gzip >postinst.tgz
cp ${HOME}/.ssh/id_ed25519.pub postinst/authorized_keys

# could also try `--install debian11 --unattended` ?
# But I'm thinking that wouldn't have a way to do the extra k8s installs
# or the slight customizations (ex no swap)?
sudo virt-install --name $NAME \
    --location http://deb.debian.org/debian/dists/$DISTNAME/main/installer-amd64/ \
    --os-variant $VARIANT \
    --initrd-inject=preseed.cfg --initrd-inject=postinst.sh --initrd-inject=postinst.tgz \
    --disk size=10 --memory $MEMORY --vcpus=2 --noreboot

rm preseed.cfg
rm postinst.tgz
rm postinst/authorized_keys

