---
title: "Incus 运行虚拟机"
date: "2026-06-18"
toc: true
---



## 安装 debian13

从官方镜像源创建 debian13 虚拟机。

### 创建 profile

```bash-session
$ incus profile create debian13vm
$ incus profile edit debian13vm
```

```yaml
config:
    boot.autostart: "false"
    limits.cpu: "4"
    limits.memory: 2GiB
    security.secureboot: "false"
devices:
    root:
        path: /
        pool: default
        type: disk
        size: 50GiB
    eth0:
        name: eth0
        host_name: veth-debian13vm
        network: incusbr-1000
        type: nic
```


### 创建虚拟机

```bash-session
$ incus launch images:debian/13 my-debian13vm --vm -p debian13vm
```

### 系统配置

```bash-session
$ incus exec my-debian13vm -- bash

{{< text fg="yellow" >}}[创建用户]{{< /text >}}
{{< text fg="red" >}}root@my-debian13vm:~#{{< /text >}} {{< text fg="foreground" >}}useradd -m -s /usr/bin/bash -u 1000 king{{< /text >}}

{{< text fg="yellow" >}}[配置密码]{{< /text >}}
{{< text fg="red" >}}root@my-debian13vm:~#{{< /text >}} {{< text fg="foreground" >}}passwd root{{< /text >}}
{{< text fg="red" >}}root@my-debian13vm:~#{{< /text >}} {{< text fg="foreground" >}}passwd king{{< /text >}}

{{< text fg="yellow" >}}[配置时区]{{< /text >}}
{{< text fg="red" >}}root@my-debian13vm:~#{{< /text >}} {{< text fg="foreground" >}}ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime{{< /text >}}

{{< text fg="yellow" >}}[配置软件源]{{< /text >}}
{{< text fg="red" >}}root@my-debian13vm:~#{{< /text >}} {{< text fg="foreground" >}}cat << EOF > /etc/apt/sources.list.d/debian.sources{{< /text >}}
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

{{< text fg="yellow" >}}[更新列表]{{< /text >}}
{{< text fg="red" >}}root@my-debian13vm:~#{{< /text >}} {{< text fg="foreground" >}}apt update{{< /text >}}
```

### 安装 incus-agent

```bash-session
{{< text fg="red" >}}root@my-debian13vm:~#{{< /text >}} {{< text fg="foreground" >}}mount -t 9p config /mnt{{< /text >}}
{{< text fg="red" >}}root@my-debian13vm:~#{{< /text >}} {{< text fg="foreground" >}}cd /mnt{{< /text >}}
{{< text fg="red" >}}root@my-debian13vm:~#{{< /text >}} {{< text fg="foreground" >}}./install.sh{{< /text >}}
{{< text fg="red" >}}root@my-debian13vm:~#{{< /text >}} {{< text fg="foreground" >}}reboot{{< /text >}}
```

文件传输测试：

```bash-session
$ incus file push hello.txt my-debian13vm/tmp/
$ incus file pull my-debian13vm/tmp/hello.txt .
```









## 安装 win10

使用 “微PE” 安装 esd 格式的 win10 系统镜像。

### 准备工作

项目配置，允许快照：

```bash-session
# incus project set user-1000 restricted.snapshots=allow
```

下载 virtio-win 驱动：

```bash-session
$ wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
```

将 esd 文件打包成 iso 格式：

```bash-session
$ mkisofs -o win10_19045_7417.esd.iso win10_19045_7417.esd
```


### 创建 profile

❶  创建 win10 基础配置：

```bash-session
$ incus profile create win10
$ incus profile edit win10
```

```yaml
config:
    boot.autostart: "false"
    limits.cpu: "4"
    limits.memory: 4GiB
    security.secureboot: "false"
devices:
    root:
        path: /
        pool: default
        type: disk
        size: 80GiB
        io.bus: nvme
        boot.priority: "10"
    eth0:
        name: eth0
        host_name: veth-win10
        ipv4.address: 192.168.20.10
        network: incusbr-1000
        type: nic
```

❷  创建 WePE 启动盘：

```bash-session
$ incus profile create iso-wepe
$ incus profile edit iso-wepe
```

```yaml
devices:
    wepe:
        source: /home/king/Incus/images/WePE_64_V2.3.iso
        type: disk
        readonly: true
        io.bus: usb
        boot.priority: "100"
```


❸  创建 esd 配置：


```bash-session
$ incus profile create iso-win10-esd
$ incus profile edit iso-win10-esd
```

```yaml
devices:
    win10-esd:
        source: /home/king/Incus/images/win10_19045_7417.esd.iso
        type: disk
        readonly: true
        io.bus: usb
        boot.priority: "0"
```


❹  创建 virtio 配置：


```bash-session
$ incus profile create iso-virtio
$ incus profile edit iso-virtio
```

```yaml
devices:
    virtio:
        source: /home/king/Incus/images/virtio-win.iso
        type: disk
        readonly: true
        io.bus: usb
        boot.priority: "0"
```



❺  创建 incus-agent 配置：

```bash-session
$ incus profile create iso-incus-agent
$ incus profile edit iso-incus-agent
```

```yaml
devices:
    incus-agent:
        source: agent:config
        type: disk
        readonly: true
        io.bus: usb
        boot.priority: "0"
```

> `boot.priority` 是启动顺序的权重值，数值越大优先级越高，`0` 表示不将此设备纳入启动候选，仅作为数据盘挂载。


### 创建虚拟机

```bash-session
$ incus init my-win10 --vm --empty -p win10 -p iso-wepe -p iso-win10-esd -p iso-virtio -p iso-incus-agent
```

> `--empty` 表示不拉取远程镜像，仅创建一个空白实例。

实例配置：

```bash-session
$ incus config set my-win10 image.os=windows
```

{{< notice class="yellow" >}}
`image.os=windows` 只能应用于实例配置，不能应用于 profile 配置；如果不配置 `image.os=windows`，incus-agent CD 驱动器中默认会是 Linux 的安装文件。
{{< /notice >}}


### 安装系统

启动虚拟机，会进入 PE：

```bash-session
$ incus start my-win10 --console=vga
```

系统安装好后，关机，然后移除以下镜像：

```bash-session
$ incus profile remove my-win10 iso-wepe
$ incus profile remove my-win10 iso-win10-esd
```

再次启动虚拟机，会进入 win10 初始化：

```bash-session
$ incus start my-win10 --console=vga
```

win10 初始化期间可能会重启，使用以下命令重连：

```bash-session
$ incus console my-win10 --type=vga
```

关机，创建快照（可选）：

```bash-session
$ incus snapshot create my-win10 first-installation
```

### 安装 virtio 驱动

打开 virtio-win CD 驱动器 ：

1. 安装 `virtio-win-guest-tools.exe`。
2. 找到 `viosock\w10\amd64\viosock.inf` 文件，右键菜单 “安装”。

{{< notice class="yellow" >}}
incus-agent 依赖 vsock 驱动，virtio 安装程序默认不安装 vsock 驱动。
{{< /notice >}}

### 安装 incus-agent

打开 incus-agent CD 驱动器，找到 `install.psl` 文件，右键菜单 “使用 powershell 运行”。

{{< notice class="red" >}}

安装后不要移除 iso-incus-agent 的 profile。

{{< /notice >}}

文件传输测试：

```bash-session
$ incus file push <本地文件>  my-win10/Users/Administrator/Desktop
```

Incus >= 7.0.0 版本的可能需要盘符：

```bash-session
$ incus file push <本地文件>  my-win10/c:/Users/Administrator/Desktop
```

