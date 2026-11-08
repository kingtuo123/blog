---
title: "Incus 容器运行图形程序"
date: "2026-06-02"
---



## 准备

工程配置：

```bash-session
$ incus project show user-1000
config:
  features.images: "true"
  features.networks: "false"
  features.networks.zones: "true"
  features.profiles: "true"
  features.storage.buckets: "true"
  features.storage.volumes: "true"
  restricted: "true"
  restricted.containers.nesting: allow
  restricted.devices.disk: allow
  restricted.devices.disk.paths: /home/king,/run/user/1000
  restricted.devices.gpu: allow
  restricted.devices.proxy: allow
  restricted.devices.usb: allow
  restricted.idmap.gid: "1000"
  restricted.idmap.uid: "1000"
  restricted.networks.access: incusbr-1000
  restricted.snapshots: allow
```

idmap 配置，参考 [映射本地路径](/posts/incus/#%e6%98%a0%e5%b0%84%e6%9c%ac%e5%9c%b0%e8%b7%af%e5%be%84)：

```bash-session
$ cat /etc/subuid
king:100000:65536
root:1000000:1000000000
root:1000:1
$ cat /etc/subgid
king:100000:65536
root:1000000:1000000000
root:1000:1
```

需要的目录：

```bash-session
$ mkdir -p ~/Incus/debian
$ mkdir -p ~/.fonts
```



## 创建 profile

```bash-session
$ incus profile create debian
$ incus profile edit debian
```

```yaml{ copy=true }
config:
  boot.autostart: "true"
  boot.autorestart: "false"
  security.nesting: "true"
  raw.idmap: both 1000 1000
  cloud-init.vendor-data: |
    #cloud-config
    write_files:
      - path: /etc/profile.d/desktop.sh
        permissions: '0644'
        content: |
          export LANG=en_US.UTF-8
          export LC_ALL=en_US.UTF-8
          export WAYLAND_DISPLAY=/mnt/wayland-1
          export PIPEWIRE_REMOTE=unix:/mnt/pipewire-0
          export PULSE_SERVER=unix:/mnt/pulse-native
          dbus-update-activation-environment --systemd --all
      - path: /etc/apt/sources.list.d/debian.sources
        permissions: '0644'
        content: |
          Types: deb
          URIs: https://mirrors.tuna.tsinghua.edu.cn/debian
          Suites: trixie trixie-updates trixie-backports
          Components: main contrib non-free non-free-firmware
          Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
          Types: deb
          URIs: https://mirrors.tuna.tsinghua.edu.cn/debian-security
          Suites: trixie-security
          Components: main contrib non-free non-free-firmware
          Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
    users:
      - name: debian
        uid: 1000
        shell: /usr/bin/bash
    timezone: Asia/Shanghai
    runcmd:
      - rm -f /etc/apt/sources.list
      - sed -i '/^Types/s/^/\n/' /etc/apt/sources.list.d/debian.sources
      - apt update
      - apt install -y pciutils mesa-utils pipewire-audio tree fonts-dejavu fonts-wqy-microhei
      - apt install -y gnome-themes-extra nwg-look firefox-esr foot
devices:
  root:
    path: /
    pool: default
    type: disk
  dsh:
    source: /home/king/Incus/debian
    path: /home/debian
    type: disk
  fonts:
    source: /home/king/.fonts
    path: /home/debian/.fonts
    readonly: true
    type: disk
  eth0:
    name: eth0
    host_name: debian
    network: incusbr-1000
    type: nic
  gpu:
    type: gpu
  wayland-socket:
    connect: unix:/run/user/1000/wayland-1
    listen: unix:/mnt/wayland-1
    type: proxy
    bind: instance
    mode: "0700"
    uid: "1000"
    gid: "1000"
    security.gid: "1000"
    security.uid: "1000"
  pipewire-0:
    connect: unix:/run/user/1000/pipewire-0
    listen: unix:/mnt/pipewire-0
    type: proxy
    bind: instance
    mode: "0700"
    uid: "1000"
    gid: "1000"
    security.gid: "1000"
    security.uid: "1000"
  pulse-native:
    connect: unix:/run/user/1000/pulse/native
    listen: unix:/mnt/pulse-native
    type: proxy
    bind: instance
    mode: "0700"
    uid: "1000"
    gid: "1000"
    security.gid: "1000"
    security.uid: "1000"
```



## 创建容器

```bash-session
$ incus launch images:debian/13/cloud debian -p debian
```

查看 cloud-init 日志：

```bash-session
$ incus exec debian -- tail -fn +1 /var/log/cloud-init-output.log
$ incus exec debian -- tail -fn +1 /var/log/cloud-init.log
```

查看 cloud-init 运行状态：

```bash-session
$ incus exec debian -- cloud-init status --long
status: done
extended_status: done
boot_status_code: enabled-by-generator
last_update: Thu, 01 Jan 1970 00:00:46 +0000
detail: DataSourceNoCloud [seed=/var/lib/cloud/seed/nocloud-net]
errors: []
recoverable_errors: {}
```

重启容器：

```bash-session
$ incus restart debian
```


## 测试

```bash-session
$ incus exec debian -- su - debian -c 'nwg-look'
$ incus exec debian -- su - debian -c 'firefox'
```



## 其它

### 代理

```bash-session
$ incus exec debian -- vim /etc/profile.d/desktop.sh
```

```{ bar="/etc/profile.d/desktop.sh" }
export http_proxy="http://192.168.20.120:7890"
export https_proxy="http://192.168.20.120:7890"
export no_proxy="localhost,127.0.0.1"
```


### Flatpak

```bash-session
$ incus exec debian -- apt install flatpak
$ incus exec debian -- flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
