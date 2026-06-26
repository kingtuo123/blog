---
title: "Incus 容器运行图形程序"
date: "2026-06-02"
---



## 项目配置

```bash-session
# incus project set user-1000 restricted.devices.proxy=allow
# incus project set user-1000 restricted.devices.disk.paths=/home/king,/run/user/1000
```


## 基础配置

```bash-session
$ incus profile create debian13
$ incus profile edit debian13
```

```yaml
config:
  boot.autostart: "false"
devices:
  eth0:
    name: eth0
    network: incusbr-1000
    type: nic
  root:
    path: /
    pool: default
    type: disk
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



创建容器：

```bash-session
$ incus launch images:debian/13 my-debian13 -p debian13
```






容器内配置：

```bash-session
$ incus exec my-debian13 -- bash

{{< text fg="yellow" >}}[创建用户]{{< /text >}}
{{< text fg="red" >}}root@my-debian13:/#{{< /text >}}{{< text fg="foreground" >}} useradd -m -s /usr/bin/bash -u 1000 king{{< /text >}}

{{< text fg="yellow" >}}[配置时区]{{< /text >}}
{{< text fg="red" >}}root@my-debian13:/#{{< /text >}}{{< text fg="foreground" >}} ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime{{< /text >}}

{{< text fg="yellow" >}}[环境变量]{{< /text >}}
{{< text fg="red" >}}root@my-debian13:/#{{< /text >}}{{< text fg="foreground" >}} cat << EOF | tee /root/.bash_profile /home/king/.bash_profile{{< /text >}}
export WAYLAND_DISPLAY=wayland-1
export PIPEWIRE_REMOTE=unix:/mnt/pipewire-0
export PULSE_SERVER=unix:/mnt/pulse-native
if [[ -e /mnt/wayland-1 && ! -e /run/user/\$(id -u)/wayland-1 ]]; then
    ln -sf /mnt/wayland-1 /run/user/\$(id -u)/
fi
EOF

{{< text fg="yellow" >}}[配置软件源]{{< /text >}}
{{< text fg="red" >}}root@my-debian13:/#{{< /text >}}{{< text fg="foreground" >}} cat << EOF > /etc/apt/sources.list.d/debian.sources{{< /text >}}
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
{{< text fg="red" >}}root@my-debian13:/#{{< /text >}}{{< text fg="foreground" >}} apt update{{< /text >}}
{{< text fg="red" >}}root@my-debian13:/#{{< /text >}}{{< text fg="foreground" >}} apt install pciutils mesa-utils pipewire-audio fonts-dejavu fonts-wqy-microhei{{< /text >}}
{{< text fg="red" >}}root@my-debian13:/#{{< /text >}}{{< text fg="foreground" >}} apt install firefox-esr foot{{< /text >}}
```









测试：

```bash-session
$ incus restart my-debian13
$ incus exec my-debian13 -- su - root -c firefox
$ incus exec my-debian13 -- su - king -c firefox
```






## 使用 cloud-init

```bash-session
$ incus profile create debian13-cloud
$ incus profile edit debian13-cloud
```

```yaml
config:
  cloud-init.vendor-data: |
    #cloud-config
    users:
      - name: king
        uid: 1000
        shell: /usr/bin/bash
    timezone: Asia/Shanghai
    write_files:
      - path: /etc/profile.d/gui-init.sh
        permissions: '0755'
        content: |
          export WAYLAND_DISPLAY=wayland-1
          export PIPEWIRE_REMOTE=unix:/mnt/pipewire-0
          export PULSE_SERVER=unix:/mnt/pulse-native
          if [[ -e /mnt/wayland-1 && ! -e /run/user/$(id -u)/wayland-1 ]]; then
              ln -sf /mnt/wayland-1 /run/user/$(id -u)/
          fi
      - path: /etc/apt/sources.list.d/debian.sources
        permissions: '0644'
        content: |
          URIs: http://mirrors4.tuna.tsinghua.edu.cn/debian
          Suites: trixie trixie-updates trixie-backports
          Components: main contrib non-free non-free-firmware
          Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
          Types: deb
          URIs: http://mirrors4.tuna.tsinghua.edu.cn/debian-security
          Suites: trixie-security
          Components: main contrib non-free non-free-firmware
          Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
    runcmd:
      - apt update
      - apt install -y pciutils mesa-utils pipewire-audio fonts-dejavu fonts-wqy-microhei firefox-esr foot
```

创建容器：

```bash-session
$ incus launch images:debian/13/cloud my-debian13-cloud -p debian13 -p debian13-cloud
```

查看 cloud-init 日志：

```bash-session
$ incus exec my-debian13-cloud -- tail -f /var/log/cloud-init-output.log
```

查看 cloud-init 运行状态：

```bash-session
$ incus exec my-debian13-cloud -- cloud-init status --long
status: done
extended_status: done
boot_status_code: enabled-by-generator
last_update: Thu, 01 Jan 1970 00:00:46 +0000
detail: DataSourceNoCloud [seed=/var/lib/cloud/seed/nocloud-net]
errors: []
recoverable_errors: {}
```

测试：

```bash-session
$ incus restart my-debian13-cloud
$ incus exec my-debian13-cloud -- su - root -c firefox
$ incus exec my-debian13-cloud -- su - king -c firefox
```
