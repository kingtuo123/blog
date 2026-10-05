---
title: "Incus 运行 OpenWrt"
date: "2026-10-05"
toc: true
---


## 容器

### 创建 profile

```bash-session
$ incus profile create openwrt
$ incus profile edit openwrt
```

```yaml{ copy=true }
config:
  boot.autorestart: "false"
  boot.autostart: "true"
devices:
  eth0:
    name: eth0
    network: incusbr-1000
    type: nic
  root:
    path: /
    pool: default
    type: disk
```


### 配置

初始化容器：

```bash-session
$ incus init images:openwrt/25.12 my-openwrt -p openwrt
```

静态 IP：

```bash-session
$ incus config device override my-openwrt eth0 ipv4.address=192.168.20.120
```

OpenWrt 配置（单 lan 口）：

```bash-session
$ incus start my-openwrt
$ incus exec my-openwrt -- ash

{{< text fg="yellow" >}}[先修改密码]{{< /text >}}
# passwd root

{{< text fg="yellow" >}}[关闭 ntp 并设置国内时区]{{< /text >}}
# /etc/init.d/sysntpd disable
# uci set system.ntp.enabled='0'
# uci set system.@system[0].zonename='Asia/Shanghai'
# uci set system.@system[0].timezone='CST-8'
# uci commit system

{{< text fg="yellow" >}}[查看：eth0 默认分配给了 wan]{{< /text >}}
# uci show network.wan
network.wan=interface
network.wan.device='eth0'
network.wan.proto='dhcp'

{{< text fg="yellow" >}}[查看：wan 区域的入站流量是被拒绝的，此时无法打开网页后台]{{< /text >}}
# uci show firewall | grep -e 'zone' | grep -E '\.name|\.input'
firewall.@zone[0].name='lan'
firewall.@zone[0].input='ACCEPT'
firewall.@zone[1].name='wan'
firewall.@zone[1].input='REJECT'

{{< text fg="yellow" >}}[删除 wan]{{< /text >}}
# uci delete network.wan
# uci delete network.wan6

{{< text fg="yellow" >}}[添加 lan，设置 dhcp 从上游获取 ip，即从 incus 网桥提供的 DHCP 服务获取地址]{{< /text >}}
# uci set network.lan=interface
# uci set network.lan.proto='dhcp'
# uci set network.lan.device='eth0'
# uci commit network

{{< text fg="yellow" >}}[忽略 lan 口的 DHCP 服务，即不在 lan 口提供 DHCP 服务，避免和 incus 的 DHCP 服务冲突]{{< /text >}}
# uci set dhcp.lan.ignore='1'
# uci commit dhcp

{{< text fg="yellow" >}}[替换清华源并更新]{{< /text >}}
# sed -i 's_https\?://downloads.openwrt.org_https://mirrors.tuna.tsinghua.edu.cn/openwrt_' /etc/apk/repositories.d/distfeeds.list
# apk update
# apk upgrade
# reboot
```

重启后，就能进入网页后台了。


## OpenClash

### 插件

OpenClash 插件：[https://github.com/vernesong/OpenClash/releases/latest](https://github.com/vernesong/OpenClash/releases/latest)

```bash-session
$ incus file push luci-app-openclash-0.47.156.apk my-openwrt/root
$ incus exec my-openwrt -- ash
# apk add --allow-untrusted ./luci-app-openclash-0.47.156.apk
# reboot
```

### 内核

mihomo 内核：[https://github.com/MetaCubeX/mihomo/releases/latest](https://github.com/MetaCubeX/mihomo/releases/latest)

查看 CPU 信息：

```bash-session
$ grep -m1 'flags' /proc/cpuinfo | grep -o 'avx2\|sse4_2'
```

如果输出包含 `avx2`，说明可以用 `v3`；如果只有 `sse4_2`，可以用 `v2`；如果都没有，请使用 `v1`。

```bash-session
$ incus file push mihomo-linux-amd64-v3-v1.19.32.gz my-openwrt/root
$ incus exec my-openwrt -- ash
# gzip -d mihomo-linux-amd64-v3-v1.19.32.gz
# mv mihomo-linux-amd64-v3-v1.19.32 /etc/openclash/core/clash_meta
# chmod +x /etc/openclash/core/clash_meta
```

### 设置

#### 订阅链接

1. 在首页 `Overviews` -> 点击 `Config File` 选项卡的 `+` 号 -> 选择 `Subscripti Link`。
2. `Config Subscribe` -> 勾选 `Auto Update` -> `Commit Settings`。

#### 运行模式

在首页 `Overviews` -> 在 `Running Mode` 选项卡 -> 选择 `Mix`。


#### 取消 SOCKS5/HTTP(S) 的认证

`Overwrite Settings` -> `General Settings` -> `Set Authentication of SOCKS5/HTTP(S)` -> 取消勾选 -> `Apply Settings`。


### http 代理

宿主机测试：

```bash-session
$ proxy='http://192.168.20.120:7890'
$ http_proxy=$proxy https_proxy=$proxy bash
$ curl www.google.com
```





## 虚拟机

### 创建 profile

```bash-session
$ incus profile create openwrtvm
$ incus profile edit openwrtvm
```

```yaml{ copy=true }
config:
  limits.cpu: "4"
  limits.memory: 1GiB
  boot.autostart: "true"
  boot.autorestart: "false"
  security.secureboot: "false"
devices:
  root:
      path: /
      pool: default
      type: disk
      size: 10GiB
  eth0:
      name: eth0
      network: incusbr-1000
      type: nic
```

其余设置和容器一样。
