#!/bin/bash

exec >/var/log/postinst.sh.log 2>&1

gzip -d </tmp/postinst.tgz | tar -vx -C /tmp -f -

mkdir -m 0700 /root/.ssh
cat /tmp/postinst/authorized_keys >/root/.ssh/authorized_keys

# Move to preseed?
apt install -y curl gpg


# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# https://github.com/cri-o/cri-o/blob/main/install.md
export VERSION=1.25
export OS=Debian_11

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list

echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

apt-get update

apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

apt-get install -y cri-o cri-o-runc

systemctl enable crio
# reated symlink /etc/systemd/system/cri-o.service → /lib/systemd/system/crio.service.
# Created symlink /etc/systemd/system/multi-user.target.wants/crio.service → /lib/systemd/system/crio.service.




echo net.ipv4.ip_forward=1 >>/etc/sysctl.conf
echo br_netfilter >>/etc/modules


