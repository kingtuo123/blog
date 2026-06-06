---
title: "Incus 在容器运行 gui 程序"
date: "2026-06-02"
---



## 项目配置

```bash-session
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
description: Wayland profile
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



## Pipewire 配置

```bash-session
$ incus profile create pipewire
$ incus profile edit pipewire
```

```yaml
config:
    environment.PIPEWIRE_REMOTE: unix:/mnt/pipewire-0
description: Pipewire profile
devices:
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
```





## Pulseaudio 配置

```bash-session
$ incus profile create pulseaudio
$ incus profile edit pulseaudio
```

```yaml
config:
    environment.PULSE_SERVER: unix:/mnt/pulse-native
description: Pulseaudio profile
devices:
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
$ incus launch images:debian/13 my-debian -p my-debian -p wayland -p pipewire -p pulseaudio
```






## 容器内配置

```bash-session
$ incus exec my-debian -- bash

{{< text fg="yellow" >}}[创建用户]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} useradd -m -s /usr/bin/bash -u 1000 king{{< /text >}}

{{< text fg="yellow" >}}[配置时区]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime{{< /text >}}

{{< text fg="yellow" >}}[环境变量]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} cat << EOF | tee /root/.bash_profile /home/king/.bash_profile{{< /text >}}
export WAYLAND_DISPLAY=wayland-1
export PIPEWIRE_REMOTE=unix:/mnt/pipewire-0
export PULSE_SERVER=unix:/mnt/pulse-native
if [[ -e /mnt/wayland-1 && ! -e /run/user/\$(id -u)/wayland-1 ]]; then
    ln -sf /mnt/wayland-1 /run/user/\$(id -u)/
fi
EOF

{{< text fg="yellow" >}}[配置软件源]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} cat << EOF > /etc/apt/sources.list.d/debian.sources{{< /text >}}
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
EOF

{{< text fg="yellow" >}}[更新并安装应用]{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} apt update{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} apt install pciutils mesa-utils pipewire-audio fonts-dejavu fonts-wqy-microhei{{< /text >}}
{{< text fg="red" >}}root@my-debian:/#{{< /text >}}{{< text fg="foreground" >}} apt install firefox-esr foot{{< /text >}}
```









## 测试

```bash-session
$ incus restart my-debian
$ incus exec my-debian -- su - root -c firefox
$ incus exec my-debian -- su - king -c firefox
```


