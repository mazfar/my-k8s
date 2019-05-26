#!/bin/bash
# Tested in AMI : ami-0de53d8956e8dcf80
# Tested OS : Amazon2 Linux
#
# Setting up K8 Repo
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'
# Disabled SE-Linux
sudo setenforce 0
sudo bash -c 'echo "SELINUX=disabled" > /etc/sysconfig/selinux'

# Disable Swap
sudo swapoff -a
sudo sed -e '/swap/ s/^#*/#/' -i /etc/fstab

# Install Kubelet Kubeadm Kubectl Docker

sudo yum install -y kubelet kubeadm kubectl docker
sudo systemctl enable kubelet && sudo systemctl start kubelet
sudo systemctl enable docker && sudo systemctl start docker

# Enable Bridge Modules
sudo bash -c 'cat <<EOF >>  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF'
sudo sysctl --system

# Init Kubeadm

sudo kubeadm init

# Clearing existing kube config directory

rm -rf $HOME/.kube
mkdir -p $HOME/.kube

# Copy Kube Config

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export kubever=$(kubectl version | base64 | tr -d '\n')

# Install weave 
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"

# Enable Standalone Master
kubectl taint nodes --all node-role.kubernetes.io/master-


