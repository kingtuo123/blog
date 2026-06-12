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

### 准备工作

工程配置，允许快照，允许使用低层级的虚拟机选项，如 raw.qemu：

```bash-session
# incus project set user-1000 restricted.snapshots=allow
# incus project set user-1000 restricted.virtual-machines.lowlevel=allow
```

下载 virtio-win 驱动：

```bash-session
$ wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
```

### 创建 profile

创建 win10 基础配置：

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
        io.bus: nvme
        boot.priority: "5"
    eth0:
        name: eth0
        host_name: veth-win10
        ipv4.address: 192.168.20.10
        network: incusbr-1000
        type: nic
```

{{< notice class="yellow" >}}
TPM 需要另外安装 `app-crypt/swtpm` （tpm 模拟器）这个软件包。
{{< /notice >}}


创建 win10 镜像配置：


```bash-session
$ incus profile create iso-win10
$ incus profile edit iso-win10
```

```yaml
description: win10.iso profile
devices:
    iso-win:
        source: /home/king/Incus/images/win10.iso
        type: disk
        readonly: true
        io.bus: usb
        boot.priority: "10"
```


创建 virtio 驱动配置


```bash-session
$ incus profile create iso-virtio
$ incus profile edit iso-virtio
```

```yaml
description: virtio-win.iso profile
devices:
    iso-virtio:
        source: /home/king/Incus/images/virtio-win.iso
        type: disk
        readonly: true
        io.bus: usb
        boot.priority: "0"
```



创建 incus-agent：

```bash-session
$ incus profile create incus-agent
$ incus profile edit incus-agent
```

```yaml
description: incus agent
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
$ incus launch win10 --vm --empty --console=vga -p win10 -p iso-win10 -p iso-virtio -p incus-agent
```

> `--empty` 表示 Incus 不从任何远程镜像创建 VM，仅创建一块空白的虚拟磁盘。

安装好后，强制停止虚拟机：

```bash-session
$ incus stop win10 -f
```

移除 `iso-win10` 镜像：

```bash-session
$ incus profile remove win10 iso-win10
```

实例配置（这一步影响后面安装 `incus-agent`）：

```bash-session
$ incus config set win10 image.os=windows
```

启动 win10：

```bash-session
$ incus start win10 --console=vga
```

win10 初始化期间可能会重启，使用以下命令重连：

```bash-session
$ incus console win10 --type=vga
```

### 创建快照

### 安装 virtio 驱动

打开我的电脑，可以看到 CD 驱动器 `virtio-win` 和 `incus-agent`，分别安装 `virtio-win-guest-tools.exe` 和 `incus-agent.exe`。


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

关机后，移除 `iso-virtio` 镜像：

```bash-session
$ incus profile remove win10 iso-virtio
```

{{< notice class="red" >}}
另外，virtio 驱动安装好后能自适应分辨率，不要再设置桌面分辨率，可能有 bug，!!!
{{< /notice >}}

### 安装 incus-agent

打开 CD 驱动器 `incus-agent`，找到 `install.psl` 文件，右键菜单 “在 powershell 中运行”。

```bash-session
$ incus file push <本地文件>  win10/c:/
```






### 结束



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
