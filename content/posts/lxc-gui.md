---
title: "LXC 容器运行 GUI 程序"
date: "2026-05-31"
draft: true
---



## 项目配置

```bash-session
# incus project set user-1000 restricted.devices.disk=allow
# incus project set user-1000 restricted.devices.proxy=allow
# incus project set user-1000 restricted.devices.disk.paths=/home/king,/run/user/1000
```


## 基础配置

```bash-session
$ incus profile create my-debian
$ incus profile edit my-debian
```

```yaml
config:
    boot.autostart: "false"
description: my-debian base profile
devices:
    eth0:
        name: eth0
        host_name: my-debian-eth0
        ipv4.address: 192.168.20.100
        network: incusbr-1000
        type: nic
    root:
        path: /
        pool: default
        type: disk
```


## Wayland 配置

```bash-session
$ incus profile create wayland
$ incus profile edit wayland
```

```yaml
config:
    environment.WAYLAND_DISPLAY: wayland-1
    environment.XDG_RUNTIME_DIR: /run/user/1000
    environment.HOME: /home/king
description: Wayland GUI profile
devices:
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
    gpu:
        type: gpu
```


## 创建容器

```bash-session
$ incus launch images:debian/13 my-debian -p my-debian -p wayland
```

容器内配置：

```bash-session
$ incus exec my-debian -- bash

{{< text fg="yellow" >}}[创建用户]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} useradd -m -s /bin/bash -u 1000 king{{< /text >}}

{{< text fg="yellow" >}}[配置时区]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime{{< /text >}}

{{< text fg="yellow" >}}[配置软件源]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} vim /etc/apt/sources.list.d/debian.sources{{< /text >}}
Types: deb
URIs: http://mirrors4.tuna.tsinghua.edu.cn/debian
Suites: trixie trixie-updates trixie-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://mirrors4.tuna.tsinghua.edu.cn/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

{{< text fg="yellow" >}}[更新并安装必要软件]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} apt update{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} apt install mesa-utils pipewire-audio pciutils{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} apt install firefox-esr foot{{< /text >}}

{{< text fg="yellow" >}}[自动登陆 console]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} mkdir -p /etc/systemd/system/console-getty.service.d/{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} vim /etc/systemd/system/console-getty.service.d/autologin.conf{{< /text >}}
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin king --noclear console

{{< text fg="yellow" >}}[自动链接 wayland-1]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} vim /home/king/.bash_profile{{< /text >}}
ln -sf /mnt/wayland-1 /run/user/1000/

{{< text fg="yellow" >}}[]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} {{< /text >}}

{{< text fg="yellow" >}}[]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} {{< /text >}}
```



## 测试

```bash-session
{{< text fg="yellow" >}}[重启容器]{{< /text >}}
$ incus restart my-debian

{{< text fg="yellow" >}}[检查用户是否登陆]{{< /text >}}
$ incus exec my-debian -- w
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU  WHAT
king     console  -                19:27    4:18   0.00s   ?    -bash

{{< text fg="yellow" >}}[启动 firefox]{{< /text >}}
$ incus exec my-debian --user 1000 -- firefox

```


