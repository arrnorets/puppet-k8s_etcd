# Table of contents
1. [Common purpose](#1-common-purpose)
2. [Compatibility](#2-compatibility)
3. [Installation](#3-installation)
4. [Config example in Hiera and result files](#4-config-example-in-hiera-and-result-files)


# 1. Common purpose
Etcd is a distributed reliable key-value store for the most critical data of a distributed system. This module provides configuration of etcd as a backend for Kubernetes.

# 2. Compatibility
This module was tested on CentOS 7.

# 3. Installation
```yaml
mod 'k8s_etcd',
    :git => 'https://github.com/arrnorets/puppet-k8s_etcd.git',
    :ref => 'main'
```

# 4. Config example in Hiera and result files
This module follows the concept of so called "XaaH in Puppet". The principles are described [here](https://asgardahost.ru/library/syseng-guide/00-rules-and-conventions-while-working-with-software-and-tools/puppet-modules-organization/) and [here](https://asgardahost.ru/library/syseng-guide/00-rules-and-conventions-while-working-with-software-and-tools/3-hashes-in-hiera/).


Here is the example of config in Hiera:
```yaml

# First of all you have to generate at least CA and Kubernetes key-cert pairs in order to configure authentication against peers in your ETCD cluster. 
# Kubernetes key-cert pair will be used as K8s API TLS credentials. See more deatils on https://github.com/kelseyhightower/kubernetes-the-hard-way, chapters 04, 05 and 06.

---
k8s_tls_certs:
  entities:
    ca:
      key: |
        <Insert your CA key here!>
      cert: |
        <Insert your CA certificate here!>
    kubernetes:
      key: |
        <Insert your kubernetes key here!>
      cert: |
        <Insert your kubernetes crt here!>


k8s_etcd:
  package: '3.4.7-1.el7'
  enable: true

  config:
    common:
      binarypath: '/opt/etcd/etcd'
      cert-file: '/etc/etcd/k8s-api.crt'
      key-file: '/etc/etcd/k8s-api.key'
      peer-cert-file: '/etc/etcd/k8s-api.crt'
      peer-key-file: '/etc/etcd/k8s-api.key'
      trusted-ca-file: '/etc/etcd/own_ca.crt'
      peer-trusted-ca-file: '/etc/etcd/own_ca.crt'
      heartbeat-interval: 250
      election-timeout: 1250
      initial-cluster-state: 'new'
      initial-cluster-token: 'etcd-cluster-0'
      data-dir: '/var/lib/etcd'
      listenport: 2380 # // Required, if not passed, a proper initial-cluster and and peer advertise options won't be generated
      clientport: 2379 # // Required, if not passed, a proper client advertise options won't be generated

    # /* This is obligartory hash of peers in format <name_of_peer>: { ip_address: <ip_address_of_etcd_value> } }
    peers:
      k8s-cp1:
        ip_address: "192.168.100.8"
      k8s-cp2:
        ip_address: "192.168.100.9"
      k8s-cp3:
        ip_address: "192.168.100.10"
```

It will install etcd package, put keys under specified directories and generate a systemd unit file with the following content:
```bash
[Unit]
Description=ETCD - A distributed, reliable key-value store for the most critical data of a distributed system 
Documentation=https://etcd.io

[Service]
Type=notify
ExecStart=/opt/etcd/etcd --name k8s-cp1 \
  --cert-file=/etc/etcd/k8s-api.crt \
  --key-file=/etc/etcd/k8s-api.key \
  --peer-cert-file=/etc/etcd/k8s-api.crt \
  --peer-key-file=/etc/etcd/k8s-api.key \
  --trusted-ca-file=/etc/etcd/own_ca.crt \
  --peer-trusted-ca-file=/etc/etcd/own_ca.crt \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://192.168.100.8:2380 \
  --listen-peer-urls https://192.168.100.8:2380 \
  --listen-client-urls https://192.168.100.8:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://192.168.100.8:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster k8s-cp1=https://192.168.100.8:2380,k8s-cp2=https://192.168.100.9:2380,k8s-cp3=https://192.168.100.10:2380 \
  --heartbeat-interval 250 \
  --election-timeout 1250 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

