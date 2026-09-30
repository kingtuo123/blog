---
title: "Netifrc"
date: "2026-09-30"
toc: true
---



## 简述

Netifrc 是 Gentoo 在运行 OpenRC 的系统上，用于配置和管理网络接口的默认框架。





## 源码

由 kimi-k3 注释，仅供参考。

{{< insert-file src="files/net.lo.md" >}}




## 接口

### 服务脚本

`/etc/init.d/net.lo` 是 netifrc 自带的服务脚本（通用模板），
当你需要管理其它网络接口，只需创建一个指向 `net.lo` 的符号链接：

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

> `RC_SVCNAME` 就是服务的名称，是 OpenRC 在执行服务脚本时自动设置的环境变量。

### 配置文件

```{ bar="/etc/conf.d/net" }
modules_wlp4s0="wpa_supplicant dhcpcd"
config_wlp4s0="dhcp"
```


{{< table thead=false >}}
|                           |                                                                     |
|:--------------------------|:--------------------------------------------------------------------|
|`modules_<interface_name>` |指定优先使用的模块，模块路径在 `/lib/netifrc/net`。                  |
|`config_<interface_name>`  |网络接口配置，可以是 `dhcp`、`null`、`192.168.1.10/24`（静态 IP）等。|
{{< /table >}}

禁用模块，在模块前加 `!`：

```
modules_wlp4s0="!ifconfig"
```

查看 net 示例配置文件（包含详细说明）：

```bash-session
$ less /usr/share/doc/netifrc-*/net.example.bz2
```







## 模块

`net.lo` 会遍历 `/lib/netifrc/net` 下的所有模块，并执行其 `depend` 函数来建立顺序关系。

以 `wpa_supplicant` 和 `iwconfig` 模块为例：

```bash{ bar="/lib/netifrc/net/wpa_supplicant.sh" }
wpa_supplicant_depend()
{
    after macnet plug
    before interface
    provide wireless

    # 比起 iwconfig 我们更偏好当前模块
    after iwconfig
}
...
```

```bash{ bar="/lib/netifrc/net/iwconfig.sh" }
iwconfig_depend()
{
    program iwconfig
    after plug
    before interface
    provide wireless
}
...
```

{{< table >}}
| 语句               | 含义                                                     |
|:-------------------|:---------------------------------------------------------|
| `program iwconfig` | 只有当系统中存在 `iwconfig` 二进制文件时，此模块才生效。 |
| `provide wireless` | 表示提供 `wireless` 功能。                               |
| `after plug`       | 当前模块排在 `plug` 模块后面。                           |
| `before interface` | 当前模块排在 `interface` 模块前面。                      |
{{< /table >}}


{{< notice class="red" >}}
`after/before` 表示的是顺序关系，而不是依赖关系，只影响模块的排序结果。对于 `provide` 相同功能的模块，排在后面的模块会优先被使用。
{{< /notice >}}

查看提供功能的模块：

```bash-session
$ cd /lib/netifrc/net
$ grep -w provide * | sort -k3
{{< text fg="purple" >}}dhclient.sh:         {{< /text >}}provide dhcp
{{< text fg="purple" >}}dhcpcd.sh:           {{< /text >}}provide dhcp
{{< text fg="purple" >}}udhcpc.sh:           {{< /text >}}provide dhcp
{{< text fg="purple" >}}dhclientv6.sh:       {{< /text >}}provide dhcpv6
{{< text fg="purple" >}}ifconfig.sh:         {{< /text >}}provide interface
{{< text fg="purple" >}}iproute2.sh:         {{< /text >}}provide interface
{{< text fg="purple" >}}ipppd.sh:            {{< /text >}}provide isdn
{{< text fg="purple" >}}ifplugd.sh:          {{< /text >}}provide plug
{{< text fg="purple" >}}netplugd.sh:         {{< /text >}}provide plug
{{< text fg="purple" >}}pppd.sh:             {{< /text >}}provide ppp
{{< text fg="purple" >}}iwconfig.sh:         {{< /text >}}provide wireless
{{< text fg="purple" >}}iwd.sh:              {{< /text >}}provide wireless
{{< text fg="purple" >}}iw.sh:               {{< /text >}}provide wireless
{{< text fg="purple" >}}wpa_supplicant.sh:   {{< /text >}}provide wireless
```


### 加载顺序

简化了下 `net.lo` 脚本，方便查看模块排序：

```bash{ bar="load_modules.sh" lineNos=inline height=60 copy=true }
#!/usr/bin/sh

SHDIR="/lib/netifrc/sh"
MODULESDIR="/lib/netifrc/net"
. "$SHDIR/functions.sh"
MODULESLIST=./nettree
IFACE=wlp4s0
IFVAR=$IFACE

_program_available()
{
    [ -z "$1" ] && return 0
    local x=
    for x; do
        case "${x}" in
            /*) [ -x "${x}" ] && break;;
            *) type "${x}" >/dev/null 2>&1 && break;;
        esac
        x=
    done
    [ -n "${x}" ] && echo $x && return 0
    return 1
}

_gen_module_list()
{
    local x='' f='' force="$1"
    if ! ${force} ; then
        if [ -s "${MODULESLIST}" ] && [ "${MODULESLIST}" -nt /proc/$$/status ]; then
            echo "Discarding cached module list ($MODULESLIST) as it's newer current time!"
        elif [ -s "${MODULESLIST}" ] && [ "${MODULESLIST}" -nt "${MODULESDIR}" ]; then
            local update=false
            for x in "${MODULESDIR}"/*.sh; do
                [ -e "${x}" ] || continue
                if [ "${x}" -nt "${MODULESLIST}" ]; then
                    update=true
                    break
                fi
            done
            ${update} || return 0
        fi
    fi

    # Run in a subshell to protect the main script
    (
    after() {
        eval ${MODULE}_after="\"\${${MODULE}_after}\${${MODULE}_after:+ }$*\""
    }

    before() {
        local mod=${MODULE}
        local MODULE=
        for MODULE; do
            after "${mod}"
        done
    }

    program() {
        if [ "$1" = "start" ] || [ "$1" = "stop" ]; then
            local s="$1"
            shift
            eval ${MODULE}_program_${s}="\"\${${MODULE}_program_${s}}\${${MODULE}_program_${s}:+ }$*\""
        else
            eval ${MODULE}_program="\"\${${MODULE}_program}\${${MODULE}_program:+ }$*\""
        fi
    }

    provide() {
        eval ${MODULE}_provide="\"\${${MODULE}_provide}\${${MODULE}_provide:+ }$*\""
        local x
        for x in "$@"; do
            eval ${x}_providedby="\"\${${MODULE}_providedby}\${${MODULE}_providedby:+ }${MODULE}\""
        done
    }

    for MODULE in "${MODULESDIR}"/*.sh; do
        sh -n "${MODULE}" || continue
        # shellcheck disable=SC1090
        . "${MODULE}" || continue
        MODULE=${MODULE#${MODULESDIR}/}
        MODULE=${MODULE%.sh}
        eval "${MODULE}_depend"
        MODULES="${MODULES} ${MODULE}"
    done

    VISITED=
    SORTED=
    visit() {
        case " ${VISITED} " in
            *" $1 "*) return;;
        esac
        VISITED="${VISITED} $1"

        eval AFTER=\$${1}_after
        for MODULE1 in ${AFTER}; do
            eval PROVIDEDBY=\$${MODULE1}_providedby
            if [ -n "${PROVIDEDBY}" ]; then
                for MODULE2 in ${PROVIDEDBY}; do
                    visit "${MODULE2}"
                done
            else
                visit "${MODULE1}"
            fi
        done

        eval PROVIDE=\$${1}_provide
        for MODULE in ${PROVIDE}; do
            visit "${MODULE}"
        done

        eval PROVIDEDBY=\$${1}_providedby
        [ -z "${PROVIDEDBY}" ] && SORTED="${SORTED} $1"
    }

    for MODULE in ${MODULES}; do
        visit "${MODULE}"
    done

    echo -e "\n按顺序关系排序后的模块列表："
    for mod in ${SORTED}; do
        echo -e "\t$mod"
    done

    # Create atomically
    TMPMODULESLIST=${MODULESLIST}.$$
    printf "" > "${TMPMODULESLIST}"
    i=0
    for MODULE in ${SORTED}; do
        eval PROGRAM=\$${MODULE}_program
        eval PROGRAM_START=\$${MODULE}_program_start
        eval PROGRAM_STOP=\$${MODULE}_program_stop
        eval PROVIDE=\$${MODULE}_provide
        echo "module_${i}='${MODULE}'"
        echo "module_${i}_program='${PROGRAM}'"
        echo "module_${i}_program_start='${PROGRAM_START}'"
        echo "module_${i}_program_stop='${PROGRAM_STOP}'"
        echo "module_${i}_provide='${PROVIDE}'"
        : $(( i += 1 ))
    done >> "${TMPMODULESLIST}"
    echo "module_${i}=" >> "${TMPMODULESLIST}"
    mv -f "${TMPMODULESLIST}" "${MODULESLIST}"
    )

    return 0
}

_load_modules()
{
    local starting=$1 mymods=

    _gen_module_list true
    . "${MODULESLIST}"

    MODULES=
    if [ "${IFACE}" != "lo" ] && [ "${IFACE}" != "lo0" ]; then
        eval mymods=\$modules_${IFVAR}
        # shellcheck disable=SC2154
        [ -z "${mymods}" ] && mymods=${modules}
    fi

    local i=-1 x='' mod='' f='' provides=''
    echo -e "\n跳过的模块："
    while true; do
        : $(( i += 1 ))
        eval mod=\$module_${i}
        [ -z "${mod}" ] && break
        [ -e "${MODULESDIR}/${mod}.sh" ] || printf "\t%-20s：模块不存在 %s\n" $mod "${MODULESDIR}/${mod}.sh"
        [ -e "${MODULESDIR}/${mod}.sh" ] || continue

        eval set -- \$module_${i}_program
        if [ -n "$1" ]; then
            if ! _program_available "$@" >/dev/null; then
                printf "\t%-20s：缺失可执行程序 %s\n" $mod "$*"
                continue
            fi
        fi
        if ${starting}; then
            eval set -- \$module_${i}_program_start
        else
            eval set -- \$module_${i}_program_stop
        fi
        if [ -n "$1" ]; then
            if ! _program_available "$@" >/dev/null; then
                printf "\t%-20s：缺失可执行程序 %s\n" $mod "$*"
                continue
            fi
        fi

        eval provides=\$module_${i}_provide
        if ${starting}; then
            case " ${mymods} " in
                *" !${mod} "*) continue;;
                *" !${provides} "*) [ -n "${provides}" ] && continue;;
            esac
        fi
        MODULES="${MODULES}${MODULES:+ }${mod}"

        # Now load and wrap our functions
        # shellcheck disable=SC1090
        if ! . "${MODULESDIR}/${mod}.sh"; then
            echo "${RC_SVCNAME}: error loading module \`${mod}'"
            exit 1
        fi

        [ -z "${provides}" ] && continue

        # Wrap our provides
        local f=
        for f in pre_start start post_start; do
            inner=$(command -v "${mod}_${f}")
            eval "${provides}_${f}() { [ '${inner}' = '${mod}_${f}' ] || return 0; ${mod}_${f} \"\$@\"; }"
        done

        eval module_${mod}_provides="${provides}"
        eval module_${provides}_providedby="${mod}"
    done

    # Wrap our preferred modules
    for mod in ${mymods}; do
        case " ${MODULES} " in
            *" ${mod} "*)
            eval x=\$module_${mod}_provides
            [ -z "${x}" ] && continue
            for f in pre_start start post_start; do
                inner=$(command -v "${mod}_${f}")
                eval "${x}_${f}() { [ '${inner}' = '${mod}_${f}' ] || return 0; ${mod}_${f} \"\$@\"; }"
            done
            eval module_${x}_providedby="${mod}"
            ;;
        esac
    done

    # Finally remove any duplicated provides from our list if we're starting
    # Otherwise reverse the list
    local LIST="${MODULES}" p=
    MODULES=
    if ${starting}; then
        for mod in ${LIST}; do
            eval x=\$module_${mod}_provides
            if [ -n "${x}" ]; then
                eval p=\$module_${x}_providedby
                [ "${mod}" != "${p}" ] && printf "\t%-20s：功能重复 %s -> %s\n" ${mod} ${x} ${p} && continue
            fi
            MODULES="${MODULES}${MODULES:+ }${mod}"
        done
    else
        for mod in ${LIST}; do
            MODULES="${mod}${MODULES:+ }${MODULES}"
        done
    fi

    echo -e "\n最终的模块列表："

    for mod in ${MODULES}; do
        echo -e "\t$mod"
    done
}

_load_modules true
```

运行结果：

```bash-session{ height=30 }
$ ./load_modules.sh
按顺序关系排序后的模块列表：
	adsl
	apipa
	arping
	bonding
	br2684ctl
	l2tp
	tuntap
	bridge
	ccwgroup
	clip
	ethtool
	dummy
	hsr
	macvlan
	macchanger
	macnet
	rename
	netplugd
	ifplugd
	ipppd
	iwconfig
	iwd
	iw
	qmi
	wpa_supplicant
	ssidnet
	wireguard
	ifconfig
	iproute2
	firewalld
	pppd
	system
	vlan
	udhcpc
	dhclient
	dhclientv6
	dhcpcd
	ip6rd
	ip6to4
	ip6token
	veth

跳过的模块：
	adsl                ：缺失可执行程序 adsl-start pppoe-start
	br2684ctl           ：缺失可执行程序 br2684ctl
	clip                ：缺失可执行程序 atmsigd
	ethtool             ：缺失可执行程序 ethtool
	rename              ：模块不存在 /lib/netifrc/net/rename.sh
	netplugd            ：缺失可执行程序 netplugd
	ifplugd             ：缺失可执行程序 ifplugd
	ipppd               ：缺失可执行程序 ipppd
	iwconfig            ：缺失可执行程序 iwconfig
	iwd                 ：缺失可执行程序 /usr/libexec/iwd
	firewalld           ：缺失可执行程序 firewall-cmd
	pppd                ：缺失可执行程序 pppd
	udhcpc              ：缺失可执行程序 busybox
	dhclient            ：缺失可执行程序 dhclient
	dhclientv6          ：缺失可执行程序 dhclient
	iw                  ：功能重复 wireless -> wpa_supplicant
	ifconfig            ：功能重复 interface -> iproute2

最终的模块列表：
	apipa
	arping
	bonding
	l2tp
	tuntap
	bridge
	ccwgroup
	dummy
	hsr
	macvlan
	macchanger
	macnet
	qmi
	wpa_supplicant
	ssidnet
	wireguard
	iproute2
	system
	vlan
	dhcpcd
	ip6rd
	ip6to4
	ip6token
	veth
```

模拟 net 配置文件，优先使用 `ifconfig` 而不是 `iproute2`：

```bash-session
$ modules_wlp4s0="ifconfig" ./load_modules.sh
	...
	iproute2            ：功能重复 interface -> ifconfig
```

排序好的模块在 `start` 函数中会被遍历执行 `${module}_pre_up`、`${module}_pre_start` 等函数，
一些模块需要在 `/etc/conf.d/net` 中额外配置参数（不需要就不配置，模块会直接返回）。







## wpa_supplicant

### 配置文件

```bash{ bar="/etc/wpa_supplicant/wpa_supplicant.conf" }
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

手动连接网络：

```bash-session
# wpa_supplicant -B -i wlp4s0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```

获取 IP，可用 `dhclient` 或 `dhcpcd`：

```bash-session
# dhclient -i wlp4s0 -v
# dhcpcd wlp4s0
```


### netifrc 配置

```bash{ bar="/etc/conf.d/net" }
modules_wlp4s0="wpa_supplicant dhcpcd"
config_wlp4s0="dhcp"
```


添加开机启动：

```bash-session
# ln -s /etc/init.d/net.lo /etc/init.d/net.wlp4s0
# rc-update add net.wlp4s0 default
```

`dhcpd` 不用添加，由 `net.wlp4s0` 启动。


### 其它

#### wpa_cli 交互式命令行工具

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


#### 动作脚本

Gentoo 上的 `wpa_supplicant` 附带了一个动作脚本 `/etc/wpa_supplicant/wpa_cli.sh`，
`wpa_cli` 会以守护进程方式监听 `wpa_supplicant` 发出的网络事件，当事件发生时自动执行该脚本。

可以在模块中看到相关代码，通过 `-a` 参数指定动作脚本：

```bash{ bar="/lib/netifrc/net/wpa_supplicant.sh" }
    local actfile=/etc/wpa_supplicant/wpa_cli.sh
    ...
    ebegin "Starting wpa_cli on" "${IFACE}"
    start-stop-daemon --start --exec "${wpac}" \
        --pidfile "/run/wpa_cli-${IFACE}.pid" \
        -- ${cliopts} -a "${actfile}" -p "${ctrl_dir}" -i "${IFACE}" \
        -P "/run/wpa_cli-${IFACE}.pid" -B
```

动作脚本如下：

```bash{ bar="/etc/wpa_supplicant/wpa_cli.sh" height=30 }
#!/bin/sh
# Copyright 1999-2011 Gentoo Foundation
# Written by Roy Marples <uberlord@gentoo.org>
# Distributed under the terms of the GNU General Public License v2
# Alternatively, this file may be distributed under the terms of the BSD License

if [ -z "$1" -o -z "$2" ]; then
	logger -t wpa_cli "Insufficient parameters"
	exit 1
fi

INTERFACE="$1"
ACTION="$2"

# Note, the below action must NOT mark the interface down via ifconfig, ip or
# similar. Addresses can be removed, changed and daemons can be stopped, but
# the interface must remain up for wpa_supplicant to work.

if [ -f /etc/gentoo-release ]; then
	EXEC="/etc/init.d/net.${INTERFACE} --quiet"
else
	logger -t wpa_cli "I don't know what to do with this distro!"
	exit 1
fi

case ${ACTION} in
	CONNECTED)
		EXEC="${EXEC} start"
		;;
	DISCONNECTED)
		EXEC="${EXEC} --nodeps stop"
		;;
	*)
		logger -t wpa_cli "Unknown action ${ACTION}"
		exit 1
		;;
esac

# ${EXEC} can use ${IN_BACKGROUND} so that it knows that the user isn't
# stopping the interface and a background process - like wpa_cli - is.
export IN_BACKGROUND=true

logger -t wpa_cli "interface ${INTERFACE} ${ACTION}"
${EXEC} || logger -t wpa_cli "executing '${EXEC}' failed"
```

`wpa_cli` 会根据事件类型（如 CONNECTED 或 DISCONNECTED），
将接口名和动作名作为参数传给脚本。

可以在 `wpa_cli` 交互模式下看到事件提示，如：

```bash-session
$ wpa_cli
> disable_network 0
OK
<3>CTRL-EVENT-{{< text fg="red" >}}DISCONNECTED{{< /text >}} bssid=3c:06:a7:a2:4d:a8 reason=3 locally_generated=1
```


#### ssid 中文字符无法显示

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




## 参考链接

- [Netifrc / Gentoo wiki](https://wiki.gentoo.org/wiki/Netifrc)
- [wpa_supplicant / Gentoo wik](https://wiki.gentoo.org/wiki/Wpa_supplicant)
- [wpa_supplicant / Arch wiki](https://wiki.archlinux.org/title/Wpa_supplicant)
- [wpa_supplicant.conf(5)](https://www.daemon-systems.org/man/wpa_supplicant.conf.5.html)
