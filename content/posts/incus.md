---
title: "Incus 安装及使用"
date: "2026-05-31"
toc: true
---



## 安装

### 内核配置

参考 Gentoo wiki 的 [LXC](https://wiki.gentoo.org/wiki/LXC) 和 [QEMU](https://wiki.gentoo.org/wiki/QEMU)。

{{< notice class="red" >}}

`CONFIG_VHOST_VSOCK` 已编译进内核（6.18.33-gentoo-r1），但创建虚拟机报错：

```bash-session
$ incus launch images:debian/13 --vm
Error: Failed instance creation: Failed creating instance record: Instance type "virtual-machine" is not supported on this server: vhost_vsock kernel module not loaded
$ ls -l /dev/{vhost-*,kvm}
crw-rw---- 1 root kvm 10, 232 Jun  6 15:24 /dev/kvm
crw-rw---- 1 root kvm 10, 238 Jun  6  2026 /dev/vhost-net
crw-rw---- 1 root kvm 10, 241 Jun  6  2026 /dev/vhost-vsock
$ ls /sys/module/vhost_vsock
ls: cannot access '/sys/module/vhost_vsock': No such file or directory
$ incus info | grep -i driver:
driver: lxc
```

解决方法有两种：

1. 编译 `CONFIG_VHOST_VSOCK` 为模块。

2. 编辑内核 `drivers/vhost/vsock.c` 文件，在 `MODULE_DESCRIPTION("vhost transport for vsock ");` 下方插入一行 `MODULE_VERSION("0.0.1");`。

编译内核后重启，查看以下命令输出：

```bash-session
$ ls /sys/module/vhost_vsock
version
$ incus info | grep -i driver:
driver: lxc | qemu
```

{{< /notice >}}


### USE 标志

参考 Gentoo wiki 的 [Incus #Launching_virtual_machines](https://wiki.gentoo.org/wiki/Incus#Launching_virtual_machines)。

```text
app-emulation/qemu      qemu_softmmu_targets_x86_64  qemu_user_targets_x86_64 vnc spice ssh usb fuse virtfs usbredir
app-containers/incus    qemu
```


### 安装 Incus


```bash-session
# emerge --ask app-containers/incus
```

添加用户到 incus 和 kvm 组：

```bash-session
# usermod -aG incus,kvm king
```

配置 idmaps：

```bash-session
# echo "root:1000000:1000000000" | tee -a /etc/subuid /etc/subgid
```

{{< notice class="red" >}}
若不配置 idmaps，普通用户执行 incus 命令报错：`Get "http://unix.socket/1.0?project=user-1000": read unix @->/var/lib/incus/unix.socket.user: read: connection reset by peer`。
{{< /notice >}}

OpenRC 启动 incus：

```bash-session
# rc-update add incus default         {{< text fg="gray-0" >}}系统级守护进程{{< /text >}}
# rc-update add incus-user default    {{< text fg="gray-0" >}}用户级守护进程，普通用户执行 incus 命令{{< /text >}}
```

```bash-session
# rc-service incus start
# rc-service incus-user start
```

{{< notice class="red" >}}
OpenRC 开机启动 `incus-user` 失败，开机后执行 `sudo rc-service incus-user restart` 能成功启动。

解决办法：编辑 `/etc/init.d/incus-user`，在 `start()` 中添加 `sleep 2` 。
{{< /notice >}}

Incus 首次使用需初始化（交互式配置存储、网络等）：

```bash-session
# incus admin init
```

也可使用最小的默认配置 `incus admin init --minimal` 来跳过交互步骤。










## 镜像

### 远程镜像

列出所有服务器：

```bash-session
$ incus remote list
|      NAME       |                URL                 |   PROTOCOL    |  AUTH TYPE  | PUBLIC | STATIC | GLOBAL |
| images          | https://images.linuxcontainers.org | simplestreams | none        | YES    | NO     | NO     |
| local (current) | unix://                            | incus         | file access | NO     | YES    | NO     |
```

- `images` 为默认的公共镜像服务器，由社区或官方维护。
- `local` 为本地的镜像服务器，包含已下载并缓存的镜像、已创建的实例等。

添加 Simple Streams 镜像服务器：

```bash-session
$ incus remote add {{< text fg="yellow" >}}<自定义名称> <镜像站URL>{{< /text >}} --protocol=simplestreams
```

添加清华大学镜像服务器：

```bash-session
$ incus remote add tuna https://mirrors.tuna.tsinghua.edu.cn/lxc-images/ --protocol=simplestreams --public
```

{{< table thead=true border=false mono=false >}}
|命令                                             |说明                            |
|:------------------------------------------------|:-------------------------------|
|*`incus remote list`*                            |列出所有远程服务器。            |
|*`incus remote add <服务器名称> <地址>`*         |添加一个新的远程服务器。        |
|*`incus remote remove <服务器名称>`*             |移除一个已配置的远程服务器。    |
|*`incus remote switch <服务器名称>`*             |切换当前默认的远程服务器。      |
|*`incus remote get-default`*                     |查看当前默认的远程服务器名称。  |
|*`incus remote set-url <服务器名称> <新地址>`*   |修改指定服务器的 URL 地址。     |
|*`incus remote rename <旧名称> <新名称>`*        |重命名服务器。                  |
{{< /table >}}




### 镜像管理

**查看镜像服务器上的所有镜像**

```bash-session
$ incus image list {{< text fg="yellow" >}}<服务器名称>{{< /text >}}:
|         ALIAS          | FINGERPRINT  | PUBLIC |     DESCRIPTION      | ARCHITECTURE |      TYPE       |   SIZE    |
| debian/13/cloud        | c54b95d46de6 | yes    | Debian trixie amd64  | x86_64       | VIRTUAL-MACHINE | 340.82MiB |
```

镜像 `TYPE` 类型：

- `CONTAINER`：与宿主机共享内核，利用 Linux 内核的命名空间和 Cgroups 进行软件隔离。
- `VIRTUAL-MACHINE`：独立的内核，借助 QEMU 进行硬件虚拟化。

筛选镜像，过滤词用于匹配 `ALIAS` 和 `FINGERPRINT` 属性中的内容（多个词用空格分隔）：

```bash-session
$ incus image list {{< text fg="yellow" >}}<服务器名称>: [过滤词]{{< /text >}}
```

```bash-session
$ incus image list images: debian/13
$ incus image list images: c54b95d46de6
$ incus image list images: debian/13 amd64
```

按其它属性筛选，使用 `<键>=<键值>` 的形式（必须小写）：

```bash-session
$ incus image list images: debian/13 architecture=x86_64 type=container
```


**引用镜像**

使用 `<服务器>:<别名|指纹>`，冒号后不要加空格：

```bash-session
$ incus launch {{< text fg="yellow" >}}images:debian/13{{< /text >}} my-debian
$ incus launch {{< text fg="yellow" >}}images:c54b95d46de6{{< /text >}} my-debian
```


**导出 / 导入镜像**

导出容器镜像文件，会生成 `.tar.xz` 元数据文件和 `.squashfs` 根文件系统文件：

```bash-session
$ incus image export [<服务器>:]<镜像> [<输出目录>]
```

如果要导出虚拟机镜像文件，添加 `--vm` 参数，会生成 `.tar.xz` 元数据文件和 `.qcow2` 磁盘镜像文件。

导入镜像文件（如果存在指纹相同的镜像将无法导入）：

```bash-session
$ incus image import <元数据文件> <根文件系统文件> [<目标服务器>:] --alias <别名>
```


{{< table thead=true border=false mono=false >}}
|命令                                                        |说明                                  |
|:-----------------------------------------------------------|:-------------------------------------|
|*`incus image list [<服务器>:] [过滤词...]`*                |列出镜像。                            |
|*`incus image info <镜像>`*                                 |显示镜像的详细元数据。                |
|*`incus image show <镜像>`*                                 |显示镜像的完整属性配置（YAML 格式）。 |
|*`incus image get-property <镜像> <键>`*                    |获取单项属性。                        |
|*`incus image set-property <镜像> <键> <键值>`*             |设置单项属性。                        |
|*`incus image unset-property <镜像> <键>`*                  |删除单项属性。                        |
|*`incus image edit <镜像>`*                                 |编辑完整属性。                        |
|*`incus image delete <镜像>`*                               |删除镜像。                            |
|*`incus image alias create <别名> <指纹>`*                  |为指纹创建别名。                      |
|*`incus image copy [<源服务器>:]<镜像> [<目标服务器>:]`*    |在不同远程服务器之间直接复制镜像。    |
|*`incus image refresh [<服务器>:]<镜像>`*                   |强制检查并更新本地缓存的远程镜像。    |
{{< /table >}}













## 实例

Incus 支持以下类型的实例：

- 系统容器。
- 应用程序容器（OCI 镜像，如 Dockerhub 上的镜像）。
- 虚拟机。

### 管理实例

**创建实例**

```bash-session
$ incus launch [选项] <服务器>:<镜像> <实例名称>
```

{{< table thead=true border=false mono=false >}}
|选项        |说明                                                           |
|:-----------|:--------------------------------------------------------------|
|`--vm`      |创建虚拟机而不是容器。                                         |
|`-c`        |配置实例选项，如 `-c limits.cpu=2 -c limits.memory=4GiB`。     |
|`-p`        |指定配置文件，如 `-p profile1 -p profile2`。                   |
|`-d`        |用于覆盖配置文件中的设备选项，如 `--device root,size=30GiB`。  |
|`-e`        |容器停止后自动删除。                                           |
|`--console` |启动后马上连接到控制台。                                       |
{{< /table >}}

**列出实例**

```bash-session
$ incus list
```

**显示实例信息 / 日志**

```bash-session
$ incus info <实例名称>
$ incus info <实例名称> --show-log
```

**启动 / 停止实例**

```bash-session
$ incus start <实例名称>
$ incus stop <实例名称>
```

**删除实例**

```bash-session
$ incus delete <实例名称>
```

**重建实例**

如果想擦除和重新初始化实例的根磁盘，但保留实例配置，可以重建实例。

使用不同的镜像重建实例：

```bash-session
$ incus rebuild <镜像名称> <实例名称>
```

清空根磁盘重建实例：

```bash-session
$ incus rebuild <实例名称> --empty
```


### Config 实例配置

**查看实例配置**

```bash-session
$ incus config show <实例名称> --expanded
architecture: x86_64                     [{{< text fg="yellow" >}}属性{{< /text >}}]
config:
  limits.memory: 2GiB                    [{{< text fg="green" >}}选项{{< /text >}}]
  security.privileged: "true"            [{{< text fg="green" >}}选项{{< /text >}}]
description: My first container          [{{< text fg="yellow" >}}属性{{< /text >}}]
name: my-container                       [{{< text fg="yellow" >}}属性{{< /text >}}]
```

**配置实例选项**

```bash-session
$ incus config set <实例名称> <键>=<键值>
$ incus config unset <实例名称> <键>
```

例如：

```bash-session
$ incus config set my-container limits.memory=8GiB
```

可配置的键参考[Instance options](https://linuxcontainers.org/incus/docs/main/reference/instance_options/#)。

**配置实例属性**

```bash-session
$ incus config set <实例名称> <键>=<键值> --property
$ incus config unset <实例名称> <键> --property
```

参考[Instance properties](https://linuxcontainers.org/incus/docs/main/reference/instance_properties/)。

**配置设备**

所有的设备类型参考[Devices](https://linuxcontainers.org/incus/docs/main/reference/devices/)。

添加磁盘设备：

```bash-session
$ incus config device add <实例名称> <设备名称> disk source=<主机路径> path=<容器内路径>
```

配置磁盘设备（参考[Disk device options](https://linuxcontainers.org/incus/docs/main/reference/devices_disk/#device-options)）：

```bash-session
$ incus config device set <实例名称> <设备名称> <键>=<键值>
```



**编辑完整实例配置**

```bash-session
$ incus config edit <实例名称>
```


### Profile 配置文件

**查看配置文件**

```bash-session
$ incus profile list
$ incus profile show <配置名称>
```

{{< notice class="yellow" >}}
Profile 与 Config 的区别：Profile 是可以复用的配置模板，Config 是单个实例的专属配置。
{{< /notice >}}

**将配置文件应用于实例**

```bash-session
$ incus profile add <实例名称> <配置文件名称>
```

### 运行命令

在实例内部运行命令：

```bash-session
$ incus exec <实例名称> [选项] -- <命令>
```

{{< table thead=true border=false mono=false >}}
|选项      |说明                                                                     |
|:---------|:------------------------------------------------------------------------|
|`--env`   |传递环境变量，例如 `incus exec debian --env MY_VAR="hello" -- env` 。    |
|`--cwd`   |指定工作目录，例如 `incus exec debian --cwd=/usr  -- ls -l` 。           |
|`--user`  |指定用户 ID，&nbsp;&nbsp;例如 `incus exec debian --user=0 -- whoami` 。  |
|`--group` |指定组 ID。                                                              |
|`-t`      |强制分配伪终端（模拟真实登录环境），适用于交互式程序（top, vim, bash）。 |
|`-T`      |强制非交互模式（纯文本管道模式），适用于自动化脚本、管道输入 / 输出。    |
{{< /table >}}


### 访问控制台

```bash-session
$ incus console <实例名称>
To detach from the console, press: <ctrl>+a q
{{< text fg="foreground" >}}root{{< /text >}}
{{< text fg="foreground" >}}Password: {{< /text >}}
...
Linux debian 6.18.33-gentoo-r1 ...
...
{{< text fg="red" >}}root@debian:~#{{< /text >}}
```

要显示 console 日志输出，添加 `--show-log` 选项：

```bash-session
$ incus restart debian
$ incus console debian --show-log
Queued start job for default target graphical.target.
[  OK  ] Created slice system-getty.slice - Slice /system/getty.
[  OK  ] Created slice system-modprobe.slice - Slice /system/modprobe.
[  OK  ] Created slice user.slice - User and Session Slice.
[  OK  ] Started systemd-ask-password-console.path - Dispatch Password Requests to Console Directory Watch.
...
```

访问图形控制台（适用于虚拟机）：

```bash-session
$ incus console <实例名称> --type vga
```

{{< notice class="yellow" >}}
启动具有图形输出的 VGA 控制台，必须安装 SPICE 客户端。Incus 支持两个常见的客户端 remote-viewer 和 spicy。
{{< /notice >}}


在实例启动时立即连接到控制台：

```bash-session
$ incus start <实例名称> --console
$ incus start <实例名称> --console=vga
```



### 访问文件


{{< table thead=true border=false mono=false >}}
|命令                                                            |说明                                                 |
|:---------------------------------------------------------------|:----------------------------------------------------|
|*`incus file edit <实例名称>/<实例内文件路径>`*                 |从本地机器编辑实例中的文件。                         |
|*`incus file delete <实例名称>/<实例内文件路径>`*               |从实例中删除文件。                                   |
|*`incus file pull <实例名称>/<实例内文件路径> <本地文件路径>`*  |从实例中拉取文件到本地机器，选项 `-r` 拉取目录。     |
|*`incus file pull <实例名称>/<实例内文件路径> -`*               |将实例中的文件拉取到标准输出，效果等同 `cat 文件`。  |
|*`incus file push <本地文件路径> <实例名称>/<实例内文件路径>`*  |将文件从本地机器推送到实例，选项 `-r` 推送目录。     |
|*`incus file mount <实例名称>/<实例内路径> <本地路径>`*         |将实例文件系统挂载到本地机器上的路径，依赖 `sshfs`。 |
{{< /table >}}

{{< notice class="yellow" >}}
对于虚拟机，必须在虚拟机内部运行 incus-agent 进程才能使以上命令工作。
{{< /notice >}}







## 网络

创建网桥（选项参考[nic configuration options](https://linuxcontainers.org/incus/docs/main/reference/devices_nic/#device-options)）：

```bash-session
# incus network create <网络名称> --type=bridge [选项]
```


设置网桥静态 IP：

```bash-session
# incus network set <网络名称> ipv4.address={{< text fg="purple" >}}192.168.20.1/24{{< /text >}} ipv4.nat=true
```


设置实例中的 nic 设备为静态 IP：

```bash-session
$ incus config device override <实例名称> eth0 ipv4.address={{< text fg="purple" >}}192.168.20.100{{< /text >}}
```

{{< notice class="yellow" >}}
执行 `incus config edit <实例名称>` 查看实例设备：

若 device 中不含 nic 设备，则实例的 nic 设备从 profile 继承而来，使用 `incus config device override`。

若 device 中包含 nic 设备，使用 `incus config device set`。
{{< /notice >}}








## 项目

Project 用于逻辑隔离，相当于将整个 Incus 服务器划分为多个独立的、互不干扰的 "工作区"。

用户可以为不同的 Project 配置特性，参考[Project configuration](https://linuxcontainers.org/incus/docs/main/reference/projects/)。








## 存储

- 存储池：每个存储池使用一个存储驱动（如 dir、zfs、lvm）。所有卷和桶都存在于某个池中。
- 存储卷：存储池中的结构化存储单元，例如作为实例的根磁盘，或作为额外磁盘挂载到实例上。
- 存储桶：是一种对象存储，不附加到实例，应用通过网络和 S3 协议直接访问。

### 管理存储卷

- 存储卷有以下内容类型：
  - filesystem：可以附加到容器和虚拟机，并且可以在实例之间共享。
  - block：只能附加到虚拟机（作为 /dev 下的块设备）。不能在实例之间共享。
  - iso：只能通过 incus import 导入 ISO 文件来创建。只能附加到虚拟机（可多台），始终只读。

{{< table thead=true border=false mono=false min-width="900" >}}
|filesystem 内容类型                                                                            |说明              |
|:----------------------------------------------------------------------------------------------|:-----------------|
|*`incus storage volume create <存储池> <卷名> [键=键值]`*                                      |创建卷            |
|*`incus storage volume attach <存储池> <卷名> <实例名称> [<实例配置内的设备名>] <实例内路径>`* |将卷附加到实例    |
|*`incus storage volume detach <存储池> <卷名> <实例名称>`*                                     |将卷从实例中移除  |
{{< /table >}}


{{< table thead=true border=false mono=false min-width="900" >}}
|block 内容类型                                                          |               |
|:-----------------------------------------------------------------------|:--------------|
|*`incus storage volume create <存储池> <卷名> --type=block [键=键值]`*  |创建卷         |
|*`incus storage volume attach <存储池> <卷名> <实例名称>`*              |将卷附加到实例 |
{{< /table >}}


{{< table thead=true border=false mono=false min-width="900" >}}
|iso 内容类型                                                             |       |
|:------------------------------------------------------------------------|:------|
|*`incus storage volume import <存储池> <iso文件路径> <卷名> --type=iso`* |创建卷 |
{{< /table >}}

> 对于 `[键=键值]` 不同的驱动有不同的配置选项，参考[Storage drivers](https://linuxcontainers.org/incus/docs/main/reference/storage_drivers/)。










## 其它

### 命令帮助

直接执行 `incus` 或其子命令如 `incus image --help` 即可查看该命令的用法。

### 禁止实例自动启动

- `boot.autorestart` 是否在实例意外退出时自动重启。
- `boot.autostart` 是否在守护进程启动时始终启动实例。

设置指定实例：

```bash-session
$ incus config set <实例名称> boot.autostart=false
```

或者设置全局配置文件：

```bash-session
$ incus profile set <配置名称> boot.autostart=false
```

### 映射本地路径

工程配置，确保下列配置项存在：

```bash-session
# incus project edit user-1000
```

```yaml
config:
    restricted.devices.disk: allow
    restricted.containers.lowlevel: allow
    restricted.idmap.uid: "1000"
    restricted.idmap.gid: "1000"
    restricted.devices.disk.paths: /home/king,/run/user/1000
```

创建新的配置文件：

```bash-session
$ incus profile create downloads
$ incus profile edit downloads
```

```yaml
config:
    raw.idmap: both 1000 1000
description: Map /home/king/Downloads directory
devices:
    downloads:
        source: /home/king/Downloads
        path: /mnt/downloads
        type: disk
```

添加配置文件到容器：

```bash-session
$ incus profile add my-debian downloads
$ incus restart my-debian
```



{{< notice class="red" >}}
到这里，如果容器无法启动，且执行 `incus info --show-log my-debian` 有如下报错：

```bash-session
newuidmap failed to write mapping "newuidmap: uid range [1000-1001) -> [1000-1001) not allowed": newuidmap 216279 0 1000000 1000 1000 1000 1 1001 1001001 999998999
```

添加 idmap（重启系统生效）：

```bash-session
$ printf "root:$(id -u):1\n" | sudo tee -a /etc/subuid
$ printf "root:$(id -g):1\n" | sudo tee -a /etc/subgid
```

参考链接：

- [Trouble with idmaps in restricted Incus container](https://discuss.linuxcontainers.org/t/trouble-with-idmaps-in-restricted-incus-container/21797)
- [Incus/LXD文件系统挂载与访问](https://www.dhao2001.com/2024/08/07/incus-filesystem-mount-access/)
- [Idmaps for user namespace](https://github.com/lxc/incus/blob/main/doc/userns-idmap.md)
- [Custom user mappings in LXD containers](https://stgraber.org/2017/06/15/custom-user-mappings-in-lxd-containers/)
{{< /notice >}}






## 参考链接

- [Gentoo Wiki / Incus](https://wiki.gentoo.org/wiki/Incus)
- [Incus 英文文档](https://linuxcontainers.org/incus/docs/main/)
- [Incus 中文文档](https://linuxcontainers.cn/incus/docs/main/)
