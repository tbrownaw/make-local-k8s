# What is this?

This is a set of scripts that will stand up a kubernetes cluster in a bunch of local VMs.

It exists mostly so that I can figure out *how* to do that.

# Scripts

## Dependencies

This needs `libvirt-clients` (`virsh`), `virtinst` (`virt-install`), Python3 (for Ansible), `jq`.


## Template creation links

Set of scripts: https://github.com/pin/debian-vm-install .

https://wiki.debian.org/KVM#Creating_a_new_guest

https://wiki.debian.org/DebianInstaller/Preseed

### k8s setup

Note that using Debian 11 means it uses cgroups v2. Following v1 instructions means the pods will all crash-loop themselves. 

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

https://github.com/cri-o/cri-o/blob/main/tutorials/kubeadm.md

# Ansible

In the `automation/` directory.

Install from `package-lock.txt` for exact versions.

# TODO

## HA / multiple control plane nodes



## Container networking plugin.

It's currently using flannel. I think [Calico](https://projectcalico.docs.tigera.io/getting-started/kubernetes/) is supposed to be more featureful?
