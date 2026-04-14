---
title: "LXC 容器"
date: "2026-04-13"
draft: true
---



## 安装

安装 lxc 容器：

```bash-session
# emerge --ask app-containers/lxc
```

安装 incus 容器管理器：

```bash-session
# emerge --ask app-containers/incus
```

添加用户到 incus 组：

```bash-session
# usermod --append --groups incus king
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


初始化 Incus（在安装 Incus 后，只需执行此操作一次即可）：

```bash-session
# incus admin init --minimal
```

这将适用于大多数设置，后续可通过 `incus admin` 和 `incus profile` 重新配置。


## 命令用法

直接执行 `incus` 或其子命令如 `incus images` 即可查看该命令的用法。



## Profile 配置

Incus profile 默认有一个 default 配置文件（该文件无法被重命名或删除）。
如果在启动容器时不指定任何配置文件，default 会被自动应用。


{{< table thead=true border=false mono=false >}}
|incus profile 子命令速查||
|:--|:--|
|**查看配置**                   |                                                                          |
|`list`                         |列出所有可用的配置文件。                                                  |
|`show <配置文件名>`            |查看指定配置文件的详细内容 (YAML格式) 。                                  |
|**创建/编辑**                  |                                                                          |
|`create <配置文件名>`          |创建一个空的配置文件。                                                    |
|`edit <配置文件名>`            |使用默认编辑器 (如 Vim) 以 YAML 格式手动编辑整个配置文件。                |
|`set <配置文件名> <键=值>`     |直接设置具体的配置项。                                                    |
|`unset <配置文件名> <键>`      |删除指定的配置项。                                                        |
|**关联容器**                   |                                                                          |
|`add <容器名> <配置文件名>`    |将配置文件追加到指定容器的配置文件列表中，多个配置文件会合并覆盖参数。    |
|`remove <容器名> <配置文件名>` |将配置文件从指定容器的配置文件列表中移除。                                |
|`assign <容器名> <配置文件名>` |覆盖指定容器上的配置文件列表。                                            |
{{< /table >}}

## Config 配置


## 网络配置


{{< table thead=true border=false mono=false >}}
|incus network 子命令速查||
|:--|:--|
|`list`                         |列出所有可用的网络。                                                      |
|`show <网络名>`                |查看网络配置内容。                                                        |
|`info <网络名>`                |查看网络状态。                                                            |
|`create <网络名>`              |创建网络。                                                                |
{{< /table >}}

## 镜像

### 远程镜像服务器

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
$ lxc remote add {{< text fg="yellow" >}}<自定义名称> <镜像站URL>{{< /text >}} --protocol=simplestreams
```

添加清华大学镜像服务器：

```bash-session
$ incus remote add tuna https://mirrors.tuna.tsinghua.edu.cn/lxc-images/ --protocol=simplestreams --public
```

{{< table thead=true border=false mono=false >}}
| 命令 | 说明 |
| :--- | :--- |
| *`incus remote list`* | 列出所有远程服务器。 |
| *`incus remote add <服务器名称> <地址>`* | 添加一个新的远程服务器。 |
| *`incus remote remove <服务器名称>`* | 移除一个已配置的远程服务器。 |
| *`incus remote switch <服务器名称>`* | 切换当前默认的远程服务器。 |
| *`incus remote get-default`* | 查看当前默认的远程服务器名称。 |
| *`incus remote set-url <服务器名称> <新地址>`* | 修改指定服务器的 URL 地址。 |
| *`incus remote rename <旧名称> <新名称>`* | 重命名服务器。 |
{{< /table >}}




### 引用镜像

使用 `<服务器>:<别名|指纹>`，冒号后不要加空格：

```bash-session
$ incus launch {{< text fg="yellow" >}}images:debian/13{{< /text >}} my-debian
$ incus launch {{< text fg="yellow" >}}images:c54b95d46de6{{< /text >}} my-debian
```

### 列出镜像

查看镜像服务器上的所有镜像：

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

### 导出 / 导入镜像

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
|命令 | 说明 |
|:--- | :--- |
|*`incus image list [<服务器>:] [过滤词...]`*          | 列出镜像。|
|*`incus image info <镜像>`*                       | 显示镜像的详细元数据。|
|*`incus image show <镜像>`*                       | 显示镜像的完整属性配置（YAML 格式）。 |
|*`incus image get-property <镜像> <键>`*         | 获取单项属性。|
|*`incus image set-property <镜像> <键> <键值>`* | 设置单项属性。|
|*`incus image unset-property <镜像> <键>`*       | 删除单项属性。|
|*`incus image edit <镜像>`*                       | 编辑完整属性。|
|*`incus image delete <镜像>`*                     | 删除镜像。|
|*`incus image alias create <别名> <指纹>`*    | 为指纹创建别名。|
|*`incus image copy [<源服务器>:]<镜像> [<目标服务器>:]`*   | 在不同远程服务器之间直接复制镜像。 |
|*`incus image refresh [<服务器>:]<镜像>`*            | 强制检查并更新本地缓存的远程镜像。 |
{{< /table >}}


## 本地镜像管理


## 其它

启用内核 sch_ingress

```text
Error: Failed instance creation: Failed to start device "eth0": Failed to delete ingress qdisc {LinkIndex: 9, Handle: ffff:0, Parent: ingress, Refcnt: 0}: operation not supported
```

镜像类型有 coantiner 和 vm

 vim /etc/init.d/incus-user 中 start() 添加 sleep 2

## 参考链接














<!--

LXD 首次使用需初始化（交互式配置存储、网络等）：
```bash-session
$ lxd init
{{< text fg="background-green" >}}集群 (Clustering)，如果你只有一台服务器，直接选择 no {{< /text >}}
Would you like to use LXD clustering? (yes/no) [default=no]: {{< text fg="red" >}}no{{< /text >}}
{{< text fg="background-green" >}}存储池，这是必须的{{< /text >}}
Do you want to configure a new storage pool? (yes/no) [default=yes]: {{< text fg="green" >}}yes{{< /text >}}
Name of the new storage pool [default=default]:
{{< text fg="background-green" >}}存储后端，推荐选择 zfs 或 btrfs，支持快照、克隆，性能好。如果是临时测试，dir（简单的目录）。{{< /text >}}
Name of the storage backend to use (btrfs, dir, lvm, zfs) [default=zfs]: {{< text fg="green" >}}zfs{{< /text >}} 
{{< text fg="background-green" >}}除非你有 MAAS 环境，否则选 no{{< /text >}}
Would you like to connect to a MAAS server? (yes/no) [default=no]: {{< text fg="red" >}}no{{< /text >}}
{{< text fg="background-green" >}}创建本地桥接网络{{< /text >}}
Would you like to create a new local network bridge? (yes/no) [default=yes]: {{< text fg="green" >}}yes{{< /text >}}
What should the new bridge be called? [default=lxdbr0]:
{{< text fg="background-green" >}}自动分配 IP 地址 auto{{< /text >}}
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: {{< text fg="green" >}}auto{{< /text >}}
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: {{< text fg="green" >}}auto{{< /text >}}
{{< text fg="background-green" >}}如果只需要在本机通过 lxc 命令管理容器则选 no ，如果需要从其他机器远程连接这台 LXD 服务器则选 yes{{< /text >}}
Would you like the LXD server to be available over the network? (yes/no) [default=no]: {{< text fg="red" >}}no{{< /text >}}
{{< text fg="background-green" >}}自动检查并更新那些已经被下载到本地的、过期的镜像缓存{{< /text >}}
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: {{< text fg="green" >}}yes{{< /text >}}
{{< text fg="background-green" >}}生成 YAML 配置，如果想保存一份配置用于以后自动化部署，可以选 yes 把它打印出来{{< /text >}}
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: {{< text fg="red" >}}no{{< /text >}}

```

> app-containers/lxc 提供传统的 `lxc-*` 命令（分散），app-containers/lxd 提供 `lxc` 命令（统一）。


## LXC 配置文件

{{< table thead=false border=false min-width="320" >}}
|                                 |                                                                 |
|:--------------------------------|:----------------------------------------------------------------|
|`/etc/lxc/lxc.conf`              |宿主机全局配置文件。                                             |
|`/etc/lxc/default.conf`          |容器默认的配置文件。                                             |
|`/var/lib/lxc/<容器名称>/config` |容器的配置文件，会在 `/etc/lxc/default.conf` 基础上合并覆盖参数。|
{{< /table >}}


### 主机配置选项

### 容器配置选项

{{< table thead=false border=false mono=true min-width="320" >}}
|||
|:--|:--|
|`lxc.uts.name`             |为容器指定主机名。                                                                      |
|**网络配置**               |
|`lxc.net`                  |可以在不指定值的情况下使用，用来清除所有先前设置的网络选项。                            |
|`lxc.net.[i]`              |[i] 表示网络接口的索引号，即这是容器的第 i 块网卡。                                     |
|`lxc.net.[i].type`         |指定容器使用的网络虚拟化类型。                                                          |
|                           |`none` &nbsp;&nbsp;&nbsp;共享宿主机的网络。                                             |
|                           |`empty` &nbsp;&nbsp;仅创建 lo 回环接口。                                                |
|                           |`veth` &nbsp;&nbsp;&nbsp;虚拟网卡（桥接）。                                             |
|                           |`macvlan` 使用宿主机物理网卡（独立 MAC），需要从路由器获取 ip ，宿主机无法直接访问容器。|
|                           |`ipvlan` &nbsp;使用宿主机物理网卡（共享 MAC）。                                         |
|                           |`phys` &nbsp;&nbsp;&nbsp;物理网卡直通，宿主机将失去该网卡控制权。                       |
|`lxc.net.[i].flags`        |用于控制网络接口，有效值为 up （启用接口）。                                            |
|`lxc.net.[i].link`         |指定宿主机上的网络接口。                                                                |
|`lxc.net.[i].name`         |容器内网络接口名称。                                                                    |
|`lxc.net.[i].hwaddr`       |指定 MAC 地址。                                                                         |
|`lxc.net.[i].ipv4.address` |指定 IPv4 地址，格式：192.168.10.10/24 。                                               |
|`lxc.net.[i].ipv4.gateway` |指定网关。                                                                              |
|**资源限制**               |
|**自动启动**               |
|`lxc.start.auto`           |宿主机启动时是否自启。有效值为 0（关闭）和 1（开启）。                                  |
|`lxc.start.delay `         |自启延迟秒数。                                                                          |
|`lxc.start.order`          |自启顺序，数值越小越先启动。                                                            |
{{< /table >}}



## 参考链接

- LXC 容器配置选项: [lxc.container.conf.5](https://linuxcontainers.org/lxc/manpages/man5/lxc.container.conf.5.html)

-->
