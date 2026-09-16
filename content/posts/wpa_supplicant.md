---
title: "Gentoo netifrc + wpa_supplicant 网络设置"
date: "2026-09-13"
draft: true
---



## Netifrc

Netifrc 是 Gentoo 在运行 OpenRC 的系统上配置和管理网络接口的默认框架。



## Netifrc 网络接口

### 服务脚本

`/etc/init.d/net.lo` 是 netifrc 自带的默认服务脚本（通用模板），
当你需要管理其它网络接口，并不需要为每个接口单独写一个脚本，只需创建一个指向 `net.lo` 的符号链接：

```bash-session
# ln -s /etc/init.d/net.lo /etc/init.d/net.<interface_name>
```

`net.<interface_name>` 运行时能从服务名称中获取接口名称：

```bash{ bar="/etc/init.d/net.lo" }
SHDIR="/lib/netifrc/sh"          # 脚本路径
MODULESDIR="/lib/netifrc/net"    # 模块路径

if [ -f "$SHDIR/functions.sh" ]; then
    . "$SHDIR/functions.sh"      # 加载脚本
else
    echo "$SHDIR/functions.sh missing. Exiting"
    exit 1
fi

start() {
    ...
    IFACE=$(get_interface)       # 获取接口名称
    ...
}
```

```bash{ bar="/lib/netifrc/sh/functions.sh" }
get_interface() {
    case $INIT in
        openrc)
        printf ${RC_SVCNAME#*.};;    # 打印接口名称
    systemd)
        printf ${RC_IFACE};;
    *)
        eerror "Init system not supported. Aborting"
        exit 1;;
    esac
}
```

> `RC_SVCNAME` 就是服务的名称，应该是 OpenRC 在执行服务脚本时，自动设置的环境变量。

### 配置文件

```{ bar="/etc/conf.d/net" }
modules_wlp4s0="wpa_supplicant dhcpcd"
config_wlp4s0="dhcp"
```

> 配置文件中的变量也是在 `net.<interface_name>` 服务脚本中处理的。

- `modules_<interface_name>` 指定优先使用的模块，模块路径在 `/lib/netifrc/net`。
- `config_<interface_name>` 网络接口的地址配置，可以是 `dhcp`、`null`、`192.168.1.10/24`（静态 IP）等。

查看 net 示例配置文件（包含详细说明）：

```bash-session
$ less /usr/share/doc/netifrc-*/net.example.bz2
```


### 模块加载顺序

```bash{ bar="/lib/netifrc/net/wpa_supplicant.sh" }
wpa_supplicant_depend()
{
	after macnet plug
	before interface
	provide wireless

	# Prefer us over iwconfig
	after iwconfig
}
```

```bash{ bar="/lib/netifrc/net/iwconfig.sh" }
iwconfig_depend()
{
	program iwconfig
	after plug
	before interface
	provide wireless
}
```

```bash{ bar="/lib/netifrc/net/ifconfig.sh" }
ifconfig_depend()
{
	program ifconfig
	provide interface
}
```

```bash{ bar="/lib/netifrc/net/iproute2.sh" }
iproute2_depend()
{
	program ip
	provide interface
	after ifconfig
}
```







## 配置及连接

编辑 `/etc/wpa_supplicant/wpa_supplicant.conf`

```bash
# 允许 wheel 组的用户控制 wpa_supplicant
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel

# 允许 wpa_gui / wpa_cli 可写该文件
update_config=1
```

添加无线网络，名称不能包含中文字符或其它特殊字符，只能是 `ascii` 字符：

```bash-session
# wpa_passphrase 网络名称 密码 >> /etc/wpa_supplicant/wpa_supplicant.conf
```

上面命令会在 `wpa_supplicant.conf` 中添加如下内容：

```bash
network={
        ssid="wifi1"
        psk=6ad077ee70b4541967ee9c0bf0dc902
}
```

如果你添加了多个网络，可以使用 `priority` 变量设置连接优先级，数字越大，优先级越高：

```bash
network={
        ssid="wifi1"
        psk=6ad077ee70b4541967ee9c0bf0dc90
        priority=10
}
```

> 其它可用的变量见 [wpa\_supplicant.conf(5)](https://www.daemon-systems.org/man/wpa_supplicant.conf.5.html) 中的 `NETWORK BLOCKS` 一节。

最后，连接网络 + 获取IP：

```bash-session
# wpa_supplicant -B -i wlp4s0 -c /etc/wpa_supplicant/wpa_supplicant.conf
# dhclient -i wlp4s0 -v
```

 

## 开机启动 - OpenRC

编辑 `/etc/conf.d/net`， 替换 `wlp4s0` 为你的无线网卡名称：

```bash
modules_wlp4s0="wpa_supplicant"
config_wlp4s0="dhcp"
```


添加开机启动：

```bash-session
# cd /etc/init.d
# ln -s net.lo net.wlp4s0
# rc-update add net.wlp4s0 default
```

`dhcpd` 不用添加，由 `wpa_supplicant` 启动

## wpa\_cli 交互式命令行工具

直接在终端执行 `wpa_cli` 命令，即可进入交互模式：

```bash-session
$ wpa_cli -i wlp4s0
Interactive mode
> help           # 列出所有指令，及其用法
略...
> list_networks  # 打印已添加的网络
network id / ssid / bssid / flags
0       wifi1    any
1       wifi2    any     [CURRENT]
> scan           # 扫描网络
OK
<3>CTRL-EVENT-SCAN-STARTED
<3>CTRL-EVENT-SCAN-RESULTS
> scan_results   # 查看扫描结果
1c:16:a1:12:1d:a8       5765    -27     [WPA-PSK-CCMP][WPA2-PSK-CCMP][ESS]      wifi1
10:1b:13:d4:14:6c       5200    -62     [WPA-PSK-CCMP][WPA2-PSK-CCMP][ESS]      wifi2
1c:16:a7:12:4d:a6       2412    -23     [WPA-PSK-CCMP][WPA2-PSK-CCMP][ESS]      wifi3
> add_network    # 添加网络
2
<3>CTRL-EVENT-NETWORK-ADDED 2
> set_network 2 ssid "wifi3"       # 设置网络2的ssid (配置文件中 network 的 ssid 变量)
> set_network 2 psk "passphrase"   # 设置网络2的密码
> enable_network 2                 # 使能网络2
> save_config                      # 保存到配置文件
> select_network 2                 # 连接到网络2
```

非交互模式，直接在命令后面跟指令，例如：

```bash-session
$ wpa_cli -i wlp4s0 list_networks
```

## ssid 中文字符无法显示

```bash-session
$ wpa_cli -i wlp4s0 scan
$ wpa_cli -i wlp4s0 scan_result | sed 's@\\@\\\\@g' | xargs -L1 echo -e
```

或者使用 `iw` 命令扫描：

```bash-session
# iw dev wlp4s0 scan | grep -i ssid | sed 's@\\@\\\\@g' | xargs -L1 echo -e
```

找到对应的中文 `ssid` 后，在 `wpa_cli` 中按之前的步骤操作。

> 注意：不能直接在 `wpa_supplicant.conf` 中添加中文字符的 `ssid`。



## 其它

CTRL-EVENT-DISCONNECTED

```bash-session
> disable_network 0
OK
<3>CTRL-EVENT-{{< text fg="red">}}DISCONNECTED{{< /text >}} bssid=3c:06:a7:a2:4d:a8 reason=3 locally_generated=1
<3>CTRL-EVENT-DSCP-POLICY clear_all
```

wpa_supplicant 广播事件：当你执行 disconnect 后，wpa_supplicant 检测到接口状态变化，通过控制接口发送一条 DISCONNECTED 事件通知。

wpa_cli 接收并判断：常驻的 wpa_cli 进程（通常由 OpenRC 服务在启动 wpa_supplicant 时拉起，并带有 -a 参数）收到这个事件。

wpa_cli 执行脚本：wpa_cli 根据事件类型（如 CONNECTED 或 DISCONNECTED），去执行指定的脚本（即 /etc/wpa_supplicant/wpa_cli.sh），并把接口名和动作名作为参数传给脚本。


## dns

/etc/dhcpcd.conf

static domain_name_servers=192.168.0.1 8.8.8.8












## 参考链接

- [Netifrc / Gentoo wiki](https://wiki.gentoo.org/wiki/Netifrc)
- [wpa_supplicant / Gentoo wik](https://wiki.gentoo.org/wiki/Wpa_supplicant)
- [wpa_supplicant / Arch wiki](https://wiki.archlinux.org/title/Wpa_supplicant)
- [wpa_supplicant.conf(5)](https://www.daemon-systems.org/man/wpa_supplicant.conf.5.html)
