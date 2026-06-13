---
title: "Incus 运行虚拟机"
date: "2026-06-03"
draft: true
---


```
app-emulation/virt-viewer
qemu
```

工程配置，快照使能 = allow

```
是否阻止使用底层 VM 选项
restricted.virtual-machines.lowlevel
是否阻止创建实例或卷快照
restricted.snapshots
```


## 从官方镜像运行


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



## 安装 win10

使用 “微PE” 安装 esd 格式的 win10 系统镜像。

### 准备工作

工程配置，允许快照：

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
description: Win10 system base profile
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


### 初始化虚拟机

```bash-session
$ incus init my-win10 --vm --empty -p win10 -p iso-wepe -p iso-win10-esd -p iso-virtio -p iso-incus-agent
```

> `--empty` 表示 Incus 不从任何远程镜像创建 VM，仅创建一块空白的虚拟磁盘。

实例配置（这一步影响后面安装 incus-agent）：

```bash-session
$ incus config set my-win10 image.os=windows
```


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

打开 CD 驱动器 `virtio-win`

1. 安装 `virtio-win-guest-tools.exe`。
2. 找到 `viosock\w10\amd64\viosock.inf` 文件（默认不安装 vsock 驱动），右键菜单**安装**。

### 安装 incus-agent

打开 CD 驱动器 `incus-agent`，找到 `install.psl` 文件，右键菜单**使用 powershell 运行**。

{{< notice class="red" >}}

不要移除 iso-incus-agent 的 profile。

{{< /notice >}}

测试文件传输：

```bash-session
$ incus file push <本地文件>  my-win10/Users/Administrator/Desktop
```

Incus >= 7.0.0 版本的可能需要盘符：

```bash-session
$ incus file push <本地文件>  my-win10/c:/Users/Administrator/Desktop
```







<!--

{{< notice class="red" >}}
`virtio-win-guest-tools.exe` 安装报错：`0x80070643` 。

解决办法：先重启系统，在 Windows 搜索栏输入 cmd，右键点击“命令提示符”，选择以管理员身份运行，执行以下命令：

```bash-session
> msdtc -uninstall
> msdtc -install
```
{{< /notice >}}

打开 CD 驱动器 `virtio-win`，找到 `viosock\w11\amd64\viosock.inf` 文件，右键菜单 “安装”。

{{< notice class="red" >}}
virtio 安装程序默认不会安装 vsock 驱动。
{{< /notice >}}



### 共享目录

```bash-session
$ incus profile create shared-win10
$ incus profile edit shared-win10
```

```yaml
description: "VirtIO-FS shared directory for win10"
devices:
    shared:
        type: disk
        source: /home/king/Downloads
        path: Downloads
```

关机后，添加：

```bash-session
$ incus profile add win10 shared-win10 
```


## 安装 win11

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
description: Win10 system base profile
devices:
    root:
        path: /
        pool: default
        type: disk
        size: 50GiB
        io.bus: virtio-scsi
        boot.priority: "5"
    eth0:
        name: eth0
        host_name: veth-win10
        ipv4.address: 192.168.20.10
        network: incusbr-1000
        type: nic
    tpm:
        type: tpm
```

-->

