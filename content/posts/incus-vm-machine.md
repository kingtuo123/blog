---
title: "Incus 运行虚拟机"
date: "2026-06-03"
draft: true
---


```
app-emulation/virt-viewer
qemu
```


## 从官方镜像运行

```
restricted.virtual-machines.lowlevel
```

### 配置


```bash-session
$ incus profile create vm-debian
$ incus profile edit vm-debian
```

```yaml
config:
    boot.autostart: "false"
description: vm-debian base profile
devices:
    eth0:
        host_name: vm-debian-eth0
        ipv4.address: 192.168.20.110
        name: eth0
        network: incusbr-1000
        type: nic
    root:
        path: /
        pool: default
        type: disk
```

```
linux 容器内安装 spice-vdagentd
systemctl enable --now spice-vdagentd
```
