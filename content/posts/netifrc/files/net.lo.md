
```bash{ bar="/etc/init.d/net.lo" lineNos=inline height=60 }
#!/sbin/openrc-run
# 声明这是 OpenRC 服务脚本，由 openrc-run 解释执行（而不是普通的 sh/bash）
# shellcheck shell=sh disable=SC1008
# Copyright (c) 2007-2009 Roy Marples <roy@marples.name>
# Copyright (c) 2010-2016 Gentoo Foundation
# Released under the 2-clause BSD license.

# ---- 全局常量定义 ----
SHDIR="/lib/netifrc/sh"              # 共享 shell 函数库目录（functions.sh 等）
MODULESDIR="/lib/netifrc/net"        # 网络模块目录（dhcpcd.sh、iproute2.sh、wireless.sh 等）
_config_vars="config metric routes"  # 允许按"接口类型/接口名"覆盖的配置变量列表

# IN_BACKGROUND 表示本服务是否由后台事件（如 devd/udev 热插拔）触发启动。
# 后台模式下 stop 时不会真正关闭接口（例如 PPP 按需拨号场景）
# -z : 判断字符串长度为 0
[ -z "${IN_BACKGROUND}" ] && IN_BACKGROUND="NO"

# shellcheck disable=SC2034
# OpenRC 服务描述（rc-service ... describe 显示）
description="Configures network interfaces."

# 定义一个包含"换行符"的变量，用于之后把 IFS 设为换行符，
# 从而实现"按行分割配置数组"（netifrc 用换行分隔多值配置项）
__IFS="
"

# 如果此文件被直接调用（而非经由 OpenRC），默认 INIT 系统为 openrc，
# 这个变量会被 functions.sh 中的函数引用
# 当 INIT 未设置或为空，返回 openrc 并设置 INIT=openrc
: "${INIT:=openrc}"

# ---- 加载共享函数库 ----
# functions.sh 提供 _exists、_up、_down、_add_address、_add_route、
# get_interface、shell_var、yesno、einfo/ewarn/eerror 包装等核心函数
if [ -f "$SHDIR/functions.sh" ]; then
    # shellcheck disable=SC1090
    . "$SHDIR/functions.sh"
else
    echo "$SHDIR/functions.sh missing. Exiting"
    exit 1
fi

# 为每个接口生成独立的"模块排序缓存文件"路径。
# get_interface 从 RC_SVCNAME（如 net.eth0）中提取接口名（eth0）。
# 按接口分开缓存可避免多接口并发启动时的竞态条件，
# 也允许每个接口使用不同的自定义模块集合。
# RC_* 的变量由 OpenRC 设置，net.lo 只是直接继承使用
MODULESLIST="${RC_SVCDIR}/nettree$(get_interface)"

# ====================================================================
# depend() —— OpenRC 依赖声明函数
# 由 rc 依赖解析器在生成依赖树时调用（不是运行时调用）
# ====================================================================
depend()
{
    local IFACE IFVAR
    IFACE=$(get_interface)               # 接口名，如 eth0
    IFVAR=$(shell_var "${IFACE}")        # 转成合法 shell 变量名，如 eth0（ wlan0-1 -> wlan0_1 ）

    # Linux 下非 lo 接口：必须先挂载 sysfs（读取 /sys/class/net），
    # 且在内核模块加载（modules 服务）之后启动
    if [ "$RC_UNAME" = Linux ] && [ "$IFACE" != lo ]; then
        need sysfs
        after modules
    fi
    after bootmisc                       # 在 bootmisc 之后（保证 /run 等就绪）
    keyword -jail -prefix -vserver       # 声明在 jail/prefix/vserver 环境中不自动加入运行级别

    case "${IFACE}" in
        lo|lo0) ;;                       # 回环接口：无额外依赖（最底层）
        *)                               # net.lo0 是 BSD 系统上的回环（loopback）接口服务，兼容 BSD 系统
            after net.lo net.lo0 dbus    # 其他接口在 lo 和 dbus 之后
            need localmount              # 需要本地文件系统已挂载（模块文件在磁盘上）
            provide net                  # 提供虚拟服务 "net"，让依赖 net 的服务（如 sshd）可以启动
            ;;
    esac

    # 允许用户为特定接口定义 depend_<接口> 函数来追加依赖
    if [ "$(command -v "depend_${IFVAR}")" = "depend_${IFVAR}" ]; then
        "depend_${IFVAR}"
    fi

    # 兼容旧式变量 rc_need_eth0 / rc_use_eth0 等，转换为新式 rc_net_eth0_need 形式
    local dep prov
    for dep in need use before after provide keyword; do
        eval prov=\$rc_${dep}_${IFVAR}
        if [ -n "${prov}" ]; then
            "${dep}" "${prov}"
            ewarn "rc_${dep}_${IFVAR} is deprecated."
            ewarn "Please use rc_net_${IFVAR}_${dep} instead."
        fi
    done
}

# ====================================================================
# 数组处理辅助函数
# netifrc 新式配置用"换行分隔的字符串"模拟数组；
# 老配置可能是 bash 数组或空格分隔字符串，这里做兼容。
# ====================================================================

# _array_helper <变量名>
# 读取变量值，去掉每行首尾空白、删除空行、把行内连续空白压缩成单个空格，
# 然后按行输出（供调用方以 IFS=换行 方式读回）
_array_helper()
{
    local _a=

    eval _a=\$$1
    _a=$(echo "${_a}" | sed -e 's:^[[:space:]]*::' -e 's:[[:space:]]*$::' -e '/^$/d' -e 's:[[:space:]]\{1,\}: :g')

    [ -n "${_a}" ] && printf "%s\n" "${_a}"
}

# _get_array <变量名>
# 以"每行一个元素"的形式输出配置变量的内容。
# 若运行在 bash 且该变量是 bash 数组（旧式写法），则给出弃用警告并逐元素输出。
_get_array()
{
    local _a=''
    if [ -n "${BASH}" ]; then
        # shellcheck disable=SC2039
        case "$(declare -p "$1" 2>/dev/null)" in
            "declare -a "*)
                ewarn "You are using a bash array for $1."
                ewarn "This feature will be removed in the future."
                ewarn "Please see net.example for the correct format for $1."
                eval "set -- \"\${$1[@]}\""     # 把数组元素展开为位置参数
                for _a; do
                    printf "%s\n" "${_a}"     # 每元素一行输出
                done
                return 0
                ;;
        esac
    fi

    _array_helper "$1"                          # 非 bash 数组：走普通字符串路径
}

# _flatten_array <变量名>
# 把（可能是 bash 数组的）变量压平为单行 shell 引号包裹的字符串，
# 用于把配置原样传递/嵌入到 eval 语句中（注意对单引号的转义处理）
_flatten_array()
{
    if [ -n "${BASH}" ]; then
        # shellcheck disable=SC2039
        case "$(declare -p "$1" 2>/dev/null)" in
            "declare -a "*)
                ewarn "You are using a bash array for $1."
                ewarn "This feature will be removed in the future."
                ewarn "Please see net.example for the correct format for $1."
                eval "set -- \"\${$1[@]}\""
                for x; do
                    # shellcheck disable=SC2059
                    # 先 printf 解释转义，再把 ' 替换为 '\'' 以安全嵌入单引号串
                    printf "'%s' " "$(printf "$x" | sed "s:':'\\\'':g")"
                done
                return 0
                ;;
        esac
    fi

    _array_helper "$1"
}

# ====================================================================
# _wait_for_presence —— 等待接口出现在系统中
# 用于 USB 网卡等可能需要时间才被内核创建的设备
# 超时由 presence_timeout_<IFVAR> 或全局 presence_timeout 控制（秒）
# ====================================================================
_wait_for_presence()
{
    local timeout=
    local rc=

    _exists && return 0                       # 已存在则直接返回

    eval timeout=\$presence_timeout_${IFVAR}
    timeout=${timeout:-${presence_timeout:-0}}

    [ ${timeout} -le 0 ] && return 1          # 未配置等待 -> 直接失败

    einfon "Waiting for ${IFACE} to show up (${timeout} seconds)"
    while [ ${timeout} -gt 0 ]; do
        _exists
        rc=$?
        [ $rc -eq 0 ] && break

        sleep 1
        printf "."
        : $(( timeout -= 1 ))
    done

    if [ ${timeout} -le 0 ]; then
        _exists                               # 最后再检查一次
        rc=$?
    fi
    echo
    eend $rc                                  # 输出 [ ok ] / [ !! ] 并返回状态码
}

# ====================================================================
# _wait_for_carrier —— 等待链路载波（网线插入/无线关联成功）
# 超时由 carrier_timeout_<IFVAR> 或全局 carrier_timeout 控制
# 注意：超时<=0 时返回 0（成功），即"用户不想等就不等"，
# 与 _wait_for_presence 的语义相反
# ====================================================================
_wait_for_carrier()
{
    local timeout=

    _has_carrier  && return 0

    eval timeout=\$carrier_timeout_${IFVAR}
    timeout=${timeout:-${carrier_timeout:-0}}

    # 如果用户不需要这个特性
    [ ${timeout} -le 0 ] && return 0

    einfon "Waiting for carrier (${timeout} seconds) "
    while [ ${timeout} -gt 0 ]; do
        if _has_carrier; then
            echo
            eend 0
            return 0
        fi
        sleep 1
        : $(( timeout -= 1 ))
        printf "."
    done

    echo
    eend 1
    return 1
}

# ====================================================================
# _netmask2cidr —— 把子网掩码转换为 CIDR 前缀长度
# 支持点分十进制（255.255.255.0）和十六进制（0xffffff00）两种形式
# 算法：对掩码的每个字节统计二进制中 1 的个数并累加
# ====================================================================
_netmask2cidr()
{
    # 某些 shell（FreeBSD sh、dash、busybox）不能正确处理十六进制算术，
    # 这里把 0xffffff00 拆成 0xff.0xff.0xff.0x00 的形式绕过该 bug。
    # bash 和 NetBSD sh 不需要此处理。
    case $1 in
        0x*)
        local hex=${1#0x*} quad=
        while [ -n "${hex}" ]; do
            local lastbut2=${hex#??*}                    # 去掉前两个十六进制字符
            quad=${quad}${quad:+.}0x${hex%${lastbut2}*}  # 取出前两位拼成 0xNN 段
            hex=${lastbut2}
        done
        # shellcheck disable=SC2086
        set -- ${quad}                  # 重新设置为点分形式继续处理
        ;;
    esac

    local i='' len=''
    local IFS=.                         # 按点分段
    for i in $1; do
        case $i in
            0x*)    i=$((i)) ;;         # 十六进制段先转十进制
        esac
        while [ ${i} -ne 0 ]; do        # 统计该字节中 1 的位数
            : $(( len += i % 2 ))
            : $(( i >>= 1 ))
        done
    done

    echo "${len}"                       # 最后 len 的值是掩码二进制中 1 的个数
}

# ====================================================================
# _configure_variables —— 实现配置变量的"回退查找"
# 对 _config_vars 里的每个变量（config/metric/routes），
# 依次按位置参数 $1 $2 ...（通常是 接口类型、接口名 之类的层级）
# 查找 config_$1、config_$2 ...，找到第一个非空的就赋给 config_<IFVAR>
# 用法示例：_configure_variables $iface_type  → 允许按接口类型统一配置
# ====================================================================
_configure_variables()
{
    local var='' v='' t=''

    for var in ${_config_vars}; do
        local v=
        for t; do
            eval v="\"\$${var}_${t}\""
            if [ -n "${v}" ]; then
                eval "${var}_${IFVAR}=\"\$${var}_${t}\""
                continue 2              # 跳到下一个 var
            fi
        done
    done
}

# ====================================================================
# _which —— 在 PATH 中查找可执行文件，输出完整路径
# （不依赖外部 which 命令，纯 shell 实现）
# ====================================================================
_which()
{
    local i OIFS
    # Empty
    [ -z "$1" ] && return
    # check paths
    OIFS="$IFS"
    IFS=:
    for i in $PATH ; do
        [ -x "$i/$1" ] && echo "$i/$1" && break
    done
    IFS=$OIFS
}

# ====================================================================
# _program_available —— 检查程序是否可用（支持多个候选、shell 内建命令）
# 参数为空返回 0；找到第一个可用的候选就输出它并返回 0
# 绝对路径直接测 -x；裸命令名用 type（能识别 builtin/alias/函数）
# ====================================================================
_program_available()
{
    [ -z "$1" ] && return 0
    local x=
    # for x; do 是 for x in "$@"; do 的省略写法
    for x; do
        case "${x}" in
            # 以 / 开头 → 绝对路径
            # 直接测"文件存在且可执行"，成功就 break 跳出循环
            /*) [ -x "${x}" ] && break;;
            # 用 shell 内建的 type 探测（屏蔽它的输出和报错），成功就 break
            *) type "${x}" >/dev/null 2>&1 && break;;
        esac
        x=
    done
    [ -n "${x}" ] && echo $x && return 0
    return 1
}

# 显示接口当前获取到的 IPv4 / IPv6 地址（供 DHCP 等模块回调打印日志）
_show_address()
{
    einfo "received address $(_get_inet_address "${IFACE}")"
}

# ====================================================================
# _get_errorhandler_behavior —— 查询"错误处理策略"配置
# 当添加地址/路由遇到 EEXIST（已存在）等错误时，用户可配置忽略/告警/失败。
# 按从具体到一般的顺序查找变量，找到第一个非空值即返回：
#   errh_<IFVAR>_<对象>_<错误>  →  errh_<IFVAR>_<对象>_DEFAULT
#   → errh_<IFVAR>_DEFAULT_<错误> → errh_<IFVAR>_DEFAULT_DEFAULT
#   → errh_DEFAULT_... → 最后回退到传入的 fallback
# 典型配置：
#   errh_eth0_address_EEXIST=warn   # 地址已存在只警告
#   errh_eth0_route_EEXIST=warn
# ====================================================================
_get_errorhandler_behavior() {
    IFVAR="$1"
    object="$2"
    error="$3"
    fallback="$4"
    value=
    for key in \
        "errh_${IFVAR}_${object}_${error}" \
        "errh_${IFVAR}_${object}_DEFAULT" \
        "errh_${IFVAR}_DEFAULT_${error}" \
        "errh_${IFVAR}_DEFAULT_DEFAULT" \
        "errh_DEFAULT_${object}_${error}" \
        "errh_DEFAULT_${object}_DEFAULT" \
        "errh_DEFAULT_DEFAULT_${error}" \
        "errh_DEFAULT_DEFAULT_DEFAULT" \
        "errh" \
        "fallback" ; do
        eval value="\${${key}}"
        if [ -n "$value" ]; then
            echo "$value" && break
        fi
    done
}

_show_address6()
{
    einfo "received address $(_get_inet6_address "${IFACE}")"
}

# ====================================================================
# _gen_module_list —— 扫描所有模块并做拓扑排序，缓存结果
#
# 每个模块文件（/lib/netifrc/net/xxx.sh）里定义了 <mod>_depend() 函数，
# 其中调用 after/before/program/provide 声明自己的依赖关系：
#   after dhcp        —— 本模块要在提供 "dhcp" 的模块之后
#   before net.lo     —— （before 是反向的 after）
#   program dhcpcd    —— 本模块需要系统里存在 dhcpcd 程序
#   provide dhcp      —— 本模块提供 "dhcp" 这个虚拟能力
#
# 本函数：
#  1) 检查缓存（nettree 文件）是否比模块目录新，新则直接复用
#  2) 否则在子 shell 中加载所有模块、收集依赖、DFS 拓扑排序
#  3) 把排序结果以 shell 变量赋值形式原子地写入缓存文件
# ====================================================================
_gen_module_list()
{
    local x='' f='' force="$1"
    if ! ${force} ; then
        # 缓存文件比本进程还新？说明时间戳异常（如系统时钟回拨），弃用
        if [ -s "${MODULESLIST}" ] && [ "${MODULESLIST}" -nt /proc/$$/status ]; then
            ewarn "Discarding cached module list ($MODULESLIST) as it's newer current time!"
        # 缓存比模块目录新时，再逐个检查有没有比缓存更新的模块文件
        elif [ -s "${MODULESLIST}" ] && [ "${MODULESLIST}" -nt "${MODULESDIR}" ]; then
            local update=false
            for x in "${MODULESDIR}"/*.sh; do
                [ -e "${x}" ] || continue
                if [ "${x}" -nt "${MODULESLIST}" ]; then
                    update=true
                    break
                fi
            done
            ${update} || return 0             # 缓存有效，直接返回
        fi
    fi

    einfo "Caching network module dependencies"
    # 在子 shell 中执行，保护主脚本的变量命名空间不被模块污染
    (
    # ---- 供模块 <mod>_depend() 调用的依赖声明原语 ----

    # after X：把 X 追加到当前模块的 after 列表
    after() {
        eval ${MODULE}_after="\"\${${MODULE}_after}\${${MODULE}_after:+ }$*\""
    }

    # before Y：等价于让 Y after 当前模块
    before() {
        local mod=${MODULE}
        local MODULE=
        for MODULE; do
            after "${mod}"
        done
    }

    # program [start|stop] PROG...：声明模块依赖的外部程序
    # 可以分别声明启动/停止阶段需要的程序
    program() {
        if [ "$1" = "start" ] || [ "$1" = "stop" ]; then
            local s="$1"
            shift
            eval ${MODULE}_program_${s}="\"\${${MODULE}_program_${s}}\${${MODULE}_program_${s}:+ }$*\""
        else
            eval ${MODULE}_program="\"\${${MODULE}_program}\${${MODULE}_program:+ }$*\""
        fi
    }

    # provide V：声明本模块提供虚拟能力 V；
    # 同时记录反向映射 V_providedby（谁提供了 V）
    provide() {
        eval ${MODULE}_provide="\"\${${MODULE}_provide}\${${MODULE}_provide:+ }$*\""
        local x
        for x in "$@"; do
            eval ${x}_providedby="\"\${${MODULE}_providedby}\${${MODULE}_providedby:+ }${MODULE}\""
        done
    }

    # ---- 第一阶段：加载所有模块并执行其 <mod>_depend ----
    for MODULE in "${MODULESDIR}"/*.sh; do
        sh -n "${MODULE}" || continue         # 先做语法检查，失败跳过
        # shellcheck disable=SC1090
        . "${MODULE}" || continue             # source 模块以定义其 _depend 函数
        MODULE=${MODULE#${MODULESDIR}/}       # 去掉目录前缀
        MODULE=${MODULE%.sh}                  # 去掉 .sh 后缀 → 模块名
        eval "${MODULE}_depend"               # 执行依赖声明
        MODULES="${MODULES} ${MODULE}"
    done

    # ---- 第二阶段：DFS 拓扑排序 ----
    VISITED=
    SORTED=
    visit() {
        case " ${VISITED} " in
            *" $1 "*) return;;                # 已访问过，防环
        esac
        VISITED="${VISITED} $1"

        # 先递归访问本模块 after 的所有目标
        # （如果 after 的是虚拟能力名，则展开为提供它的所有模块）
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

        # 再递归访问本模块 provide 的虚拟能力（保证提供者先于使用"能力名"者被处理？——
        # 实际效果是建立 provide 关系的遍历完整性）
        eval PROVIDE=\$${1}_provide
        for MODULE in ${PROVIDE}; do
            visit "${MODULE}"
        done

        # 只有"真实模块"（不提供任何虚拟能力的叶子，或未被登记为提供者）
        # 才被加入排序结果；提供虚拟能力的模块会通过 providedby 间接进入
        eval PROVIDEDBY=\$${1}_providedby
        [ -z "${PROVIDEDBY}" ] && SORTED="${SORTED} $1"
    }

    for MODULE in ${MODULES}; do
        visit "${MODULE}"
    done

    # ---- 第三阶段：原子写入缓存文件 ----
    # 缓存格式为 shell 变量赋值，之后直接 source 即可
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
    echo "module_${i}=" >> "${TMPMODULESLIST}"   # 空值作为列表终止标记
    mv -f "${TMPMODULESLIST}" "${MODULESLIST}"   # mv 保证原子替换
    )

    return 0
}

# ====================================================================
# _load_modules —— 按排序结果实际加载模块，处理虚拟能力包装
# 参数 $1：true=启动阶段加载，false=停止阶段加载
# ====================================================================
_load_modules()
{
    local starting=$1 mymods=

    # Ensure our list is up to date
    _gen_module_list false                    # 生成/复用模块排序缓存
    # shellcheck disable=SC1090
    if ! . "${MODULESLIST}"; then             # source 缓存失败则强制重建
        _gen_module_list true
        # shellcheck disable=SC1090
        . "${MODULESLIST}"
    fi

    MODULES=
    # 非回环接口：读取用户配置 modules_<IFVAR>（如 modules_eth0="dhcpcd"）
    # 未配置则用全局 modules 变量，作为"用户偏好模块"列表
    if [ "${IFACE}" != "lo" ] && [ "${IFACE}" != "lo0" ]; then
        eval mymods=\$modules_${IFVAR}
        # shellcheck disable=SC2154
        [ -z "${mymods}" ] && mymods=${modules}
    fi

    local i=-1 x='' mod='' f='' provides=''
    while true; do
        : $(( i += 1 ))
        eval mod=\$module_${i}
        [ -z "${mod}" ] && break              # 空值 = 列表结束
        [ -e "${MODULESDIR}/${mod}.sh" ] || continue

        # 检查模块声明的通用程序依赖是否满足，不满足则跳过该模块
        eval set -- \$module_${i}_program
        if [ -n "$1" ]; then
            if ! _program_available "$@" >/dev/null; then
                vewarn "Skipping module $mod due to missing program: $*"
                continue
            fi
        fi
        # 再检查阶段特定（start/stop）的程序依赖
        if ${starting}; then
            eval set -- \$module_${i}_program_start
        else
            eval set -- \$module_${i}_program_stop
        fi
        if [ -n "$1" ]; then
            if ! _program_available "$@" >/dev/null; then
                vewarn "Skipping module $mod due to missing program: $*"
                continue
            fi
        fi

        eval provides=\$module_${i}_provide
        if ${starting}; then
            # 用户可用 "!模块名" 或 "!虚拟能力" 显式禁用某模块
            # 例如 modules_eth0="!wpa_supplicant"
            case " ${mymods} " in
                *" !${mod} "*) continue;;
                *" !${provides} "*) [ -n "${provides}" ] && continue;;
            esac
        fi
        MODULES="${MODULES}${MODULES:+ }${mod}"

        # 真正 source 模块文件，把 <mod>_pre_start/_start/_stop 等函数载入
        # shellcheck disable=SC1090
        if ! . "${MODULESDIR}/${mod}.sh"; then
            eend 1 "${RC_SVCNAME}: error loading module \`${mod}'"
            exit 1
        fi

        [ -z "${provides}" ] && continue

        # ---- 虚拟能力包装 ----
        # 如果模块提供虚拟能力（如 dhcp），则定义 dhcp_pre_start/dhcp_start/
        # dhcp_post_start 包装函数，转发到真实模块的实现。
        # 这样 config_eth0="dhcp" 时，主流程调用 dhcp_start 即可，
        # 无需关心底层是 dhcpcd 还是 dhclient。
        local f=
        for f in pre_start start post_start; do
            inner=$(command -v "${mod}_${f}")
            eval "${provides}_${f}() { [ '${inner}' = '${mod}_${f}' ] || return 0; ${mod}_${f} \"\$@\"; }"
        done

        eval module_${mod}_provides="${provides}"        # 记录 mod -> 能力
        eval module_${provides}_providedby="${mod}"      # 记录 能力 -> mod（当前提供者）
    done

    # ---- 用户偏好优先 ----
    # 如果 mymods 里显式列出了某模块（如 modules_eth0="dhcpcd"），
    # 则把该模块提供的虚拟能力包装改指向它（覆盖默认提供者），
    # 实现"多种 dhcp 客户端中用户指定用哪个"
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

    # ---- 收尾 ----
    # 启动时：去掉"被别的模块替代提供虚拟能力"的重复模块
    #   （例如用户指定 dhcpcd，则 dhclient 被从列表剔除）
    # 停止时：反转列表，让模块以相反顺序停止（类似栈的 LIFO）
    local LIST="${MODULES}" p=
    MODULES=
    if ${starting}; then
        for mod in ${LIST}; do
            eval x=\$module_${mod}_provides
            if [ -n "${x}" ]; then
                eval p=\$module_${x}_providedby
                [ "${mod}" != "${p}" ] && continue    # 该能力已由别的模块提供 → 丢弃
            fi
            MODULES="${MODULES}${MODULES:+ }${mod}"
        done
    else
        for mod in ${LIST}; do
            MODULES="${mod}${MODULES:+ }${MODULES}"   # 头插法反转
        done
    fi

    veinfo "Loaded modules: ${MODULES}"
}

# ====================================================================
# _load_config —— 解析接口配置到 config_0, config_1, ... 伪数组
# 配置来源（/etc/conf.d/net）：
#   config_eth0="192.168.1.10/24
#   192.168.2.10/24"
#   fallback_eth0="dhcp"     ← 主配置失败时的后备
# 结果存为 config_0='...' config_1='...' config_2= （空为终止）
# ====================================================================
_load_config()
{
    local config='' fallback=''
    config="$(_get_array "config_${IFVAR}")"
    fallback="$(_get_array fallback_${IFVAR})"

    config_index=0
    local IFS="$__IFS"                        # IFS=换行：按行拆分
    set -- ${config}

    # 兼容"空格分隔的多个 CIDR 写在同一行"的旧式写法：
    # config_eth0="10.0.0.1/24 10.0.0.2/24"
    # 但如果空格后面的内容不是 IP 地址（而是参数，如 "dhcp" 的选项），
    # 则不按空格拆分，仍按整行处理
    if [ $# = 1 ]; then
        unset IFS
        set -- ${config}
        # 如果第 2 个字段既不含 . 也不含 :，说明它不是 IP 地址，
        # 而是第一个配置的参数 → 恢复按换行拆分
        if [ "${2#*.*}" = "${2}" ] && [  "${2#*:*}" = "${2}" ]; then
            # Not an IPv4/IPv6
            local IFS="$__IFS"
            set -- ${config}
        fi
    fi

    # 回环接口强制配置 127.0.0.1/8（除非用户显式写了 "null"）
    if [ "${IFACE}" = "lo" ] || [ "${IFACE}" = "lo0" ]; then
        if [ "$1" != "null" ]; then
               config_0="127.0.0.1/8"
            config_index=1
        fi
    else
        # 没写配置 → 默认 DHCP，并给出警告
        if [ -z "$1" ]; then
            ewarn "config_${IFVAR} not specified; defaulting to DHCP"
            config_0="dhcp"
            config_index=1
        fi
    fi


    # 把每条配置存入 config_<n> 变量（伪数组），
    # 用变量而非真实数组是为了让模块可以动态修改配置
    for cmd; do
        eval config_${config_index}="'${cmd}'"
        : $(( config_index += 1 ))
    done
    # Terminate the list
    eval config_${config_index}=              # 空字符串作为结束标志

    # 同样处理 fallback 列表
    config_index=0
    for cmd in ${fallback}; do
        eval fallback_${config_index}="'${cmd}'"
        : $(( config_index += 1 ))
    done
    # Terminate the list
    eval fallback_${config_index}=

    # 置为 -1 而不是 0：调用方使用前先 +1，
    # 这样模块即使不重置索引也能正常工作
    config_index=-1
}

# ====================================================================
# 供模块/用户钩子调用的辅助函数
# ====================================================================

# _run_if CMD [IFACE] —— 在"指定的另一个接口"上下文里执行 CMD，
# 同时保存/恢复当前的 IFACE/IFVAR，防止互相覆盖
_run_if()
{
    local cmd=$1 iface=$2 ifr=${IFACE} ifv=${IFVAR}
    # Ensure that we don't stamp on real values
    local IFACE='' IFVAR=''
    shift
    if [ -n "${iface}" ]; then
        IFACE="${iface}"
        [ "${iface}" != "${ifr}" ] && IFVAR=$(shell_var "${IFACE}")
    else
        IFACE=${ifr}
        IFVAR=${ifv}
    fi
    ${cmd}
}
# 以下四个是模块常用接口：可以操作别的接口（如网桥先 up 成员口）
interface_exists()
{
    _run_if _exists "$@"
}
interface_up()
{
    _run_if _up "$@"
}
interface_down()
{
    _run_if _down "$@"
}
# 接口类型记录/查询（存入 service 的 kv 存储，跨函数调用持久）
set_interface_type()
{
    service_set_value iface_type "$@"
}
get_interface_type()
{
    ( RC_SVCNAME="net.$IFACE" service_get_value iface_type )
}
is_interface_type()
{
    [ "$(get_interface_type)" = "$1" ]
}

# ====================================================================
# start() —— 启动接口（OpenRC 服务入口）
# ====================================================================
start()
{
    local IFACE=''
    local IFVAR=''
    local oneworked=false          # 是否至少有一条配置成功
    local fallback=false           # 是否正在使用 fallback 配置
    local module=''
    local cmd=''
    local our_metric=''
    local metric=0
    local _up_before_preup=''
    IFACE=$(get_interface)
    IFVAR=$(shell_var "${IFACE}")
    # up_before_preup_<IFVAR>：执行 preup 钩子前是否先 ifconfig up 接口
    eval _up_before_preup="\$up_before_preup_${IFVAR}"
    # shellcheck disable=SC2154
    [ -z "${_up_before_preup}" ] && _up_before_preup=$up_before_preup

    einfo "Bringing up interface ${IFACE}"
    eindent                                   # 输出缩进一级

    # 加载模块（若上层流程尚未加载）
    if [ -z "${MODULES}" ]; then
        local MODULES=
        _load_modules true
    fi

    # 阶段 1：各模块的 <mod>_pre_up（如创建 tun/tap 设备、vlan 接口）
    for module in ${MODULES}; do
        if [ "$(command -v "${module}_pre_up")" = "${module}_pre_up" ]; then
            ${module}_pre_up || exit $?
        fi
    done

    # 阶段 2：用户自定义 preup() 钩子
    # 在 preup 前后各 up 一次接口：先 up 是为了 preup 里能操作接口；
    # preup 后再 up 是防止用户在 preup 里误把它 down 掉
    if [ "$(command -v preup)" = "preup" ]; then
        yesno "${_up_before_preup:-yes}" && _up 2>/dev/null
        ebegin "Running preup"
        eindent
        preup || return 1
        eoutdent
    fi

    _up 2>/dev/null                           # 正式把接口置为 UP

    # 阶段 3：各模块 <mod>_pre_start（如启动 wpa_supplicant）
    for module in ${MODULES}; do
        if [ "$(command -v "${module}_pre_start")" = "${module}_pre_start" ]; then
            ${module}_pre_start || exit $?
        fi
    done

    # 阶段 4：确认接口真实存在（可能 pre_start 刚创建了它，或等待 USB 设备出现）
    if ! _wait_for_presence; then
        eerror "ERROR: interface ${IFACE} does not exist"
        eerror "Ensure that you have loaded the correct kernel module for your hardware"
        return 1
    fi

    # 阶段 5：等待载波。若系统有 devd（热插拔守护）在跑，
    # 没有载波也不算致命——把服务标记为 inactive，等插线后 devd 会重新触发启动
    if ! _wait_for_carrier; then
        if service_started devd; then
            ewarn "no carrier, but devd will start us when we have one"
            mark_service_inactive "${RC_SVCNAME}"
        else
            eerror "no carrier"
        fi
        return 1
    fi

    # 阶段 6：加载配置（config_<IFVAR> → config_0, config_1, ...）
    local config='' config_index=''
    _load_config
    config_index=0

    # 计算路由 metric：用户显式配置优先；
    # 否则非 lo 接口用接口索引号（ifindex），保证多接口默认路由有确定优先级
    eval our_metric=\$metric_${IFVAR}
    if [ -n "${our_metric}" ]; then
        metric=${our_metric}
    elif [ "${IFACE}" != "lo" ] && [ "${IFACE}" != "lo0" ]; then
        : $(( metric += $(_ifindex) ))
    fi

    # 阶段 7：逐条执行配置
    while true; do
        eval config=\$config_${config_index}
        [ -z "${config}" ] && break           # 空值 = 结束

        set -- ${config}
        if [ "$1" != "null" ] && [ "$1" != "noop" ]; then
            ebegin "$1"                       # 打印 " * <config> ..."
        fi
        eindent
        case "$1" in
            noop)
                # noop：只检查接口是否已有地址（用于"别的工具已配好"的场景）
                if [ -n "$(_get_inet_address)" ]; then
                    oneworked=true
                    break
                fi
                ;;
            null) :;;                         # null：什么都不做
            [0-9]*|*:*)
                # 以数字开头 → IPv4/CIDR；含冒号 → IPv6：直接添加静态地址
                _add_address ${config};;
            *)
                # 其他关键字（如 dhcp、pppoe）→ 调用虚拟能力函数 <关键字>_start
                # （即 _load_modules 里包装好的，转发到具体模块）
                if [ "$(command -v "${config}_start")" = "${config}_start" ]; then
                    "${config}"_start
                else
                    eerror "nothing provides \`${config}'"
                fi
                ;;
        esac
        # ---- 失败处理与 fallback ----
        if eend $?; then
            oneworked=true
        else
            eval config=\$fallback_${config_index}
            if [ -n "${config}" ]; then
                fallback=true
                eoutdent
                ewarn "Trying fallback configuration ${config}"
                eindent
                # 用 fallback 配置替换当前条目，索引 -1 使其下一轮重新执行
                eval config_${config_index}=\$config
                unset fallback_${config_index}
                : $(( config_index -= 1 ))
            fi
        fi
        eoutdent
        : $(( config_index += 1 ))
    done

    # 一条配置都没成功 → 执行 failup 钩子（若定义）后返回失败
    if ! ${oneworked}; then
        if [ "$(command -v failup)" = "failup" ]; then
            ebegin "Running failup"
            eindent
            failup
            eoutdent
        fi
        return 1
    fi

    # 阶段 8：添加路由
    # 若使用了 fallback 配置，优先读 fallback_routes_<IFVAR>
    local first=true routes=
    if ${fallback}; then
        routes="$(_get_array "fallback_routes_${IFVAR}")"
    fi
    if [ -z "${routes}" ]; then
        routes="$(_get_array "routes_${IFVAR}")"
    fi
    # lo 接口自动补 127.0.0.0/8 的本地路由
    if [ "${IFACE}" = "lo" ] || [ "${IFACE}" = "lo0" ]; then
        if [ "${config_0}" != "null" ]; then
            routes="127.0.0.0/8 via 127.0.0.1
${routes}"
        fi
    fi

    service_set_value "nodev_routes" ""       # 清空"非本设备路由"记录（供后续查询）

    local OIFS="${IFS}" SIFS="${IFS-y}"
    local IFS="$__IFS"                        # 路由按行拆分
    local cmd_head fam
    for cmd in ${routes}; do
        unset IFS                             # 行内再按空格分词
        if ${first}; then
            first=false
            einfo "Adding routes"
        fi

        # 行首可写 "-6 "/"-4 " 强制指定地址族
        case ${cmd} in
            -6" "*) fam="-6"; cmd=${cmd#-6 };;
            -4" "*) fam="-4"; cmd=${cmd#-4 };;
        esac

        # 识别特殊路由类型关键字（blackhole/prohibit/throw/unreachable）
        cmd_head=
        case ${cmd%% *} in
            blackhole|prohibit|throw|unreachable) cmd_head="${cmd_head} ${cmd%% *}"; cmd=${cmd#* };;
        esac

        eindent
        ebegin ${cmd_head} ${cmd}
        # 用户没写 -net/-host 时，根据目标形式自动推断：
        #   带 netmask 关键字 / 带前缀长度的 IPv4 / default → -net
        #   IPv4/32 或 IPv6/128 → -host
        #   其余裸 IP → -host
        case ${cmd} in
            -net\ *|-host\ *);;
            *\ netmask\ *)                     cmd="-net ${cmd}";;
            *.*.*.*/32*)                       cmd="-host ${cmd}";;
            *.*.*.*/*|0.0.0.0|0.0.0.0\ *)     cmd="-net ${cmd}";;
            default|default\ *)               cmd="-net ${cmd}";;
            *:*/128*)                          cmd="-host ${cmd}";;
            *:*/*)                             cmd="-net ${cmd}";;
            *)                                 cmd="-host ${cmd}";;
        esac
        _add_route ${fam} ${cmd_head} ${cmd}
        eend $?
        eoutdent
    done
    # 恢复 IFS 原状
    if [ "${SIFS}" = "y" ]; then
        unset IFS
    else
        IFS="${OIFS}"
    fi

    # 阶段 9：各模块 <mod>_post_start（如启动防火墙规则、通告）
    for module in ${MODULES}; do
        if [ "$(command -v "${module}_post_start")" = "${module}_post_start" ]; then
            ${module}_post_start || exit $?
        fi
    done

    # 阶段 10：用户 postup() 钩子
    if [ "$(command -v postup)" = "postup" ]; then
        ebegin "Running postup"
        eindent
        postup
        eoutdent
    fi

    return 0
}

# ====================================================================
# stop() —— 停止接口（OpenRC 服务入口）
# ====================================================================
stop()
{
    # 系统关机时不真正关闭网络（根文件系统可能挂在 NFS 上等场景）；
    # 不使用 noshutdown 关键字是为了从单用户模式切回多用户时能被正确重启。
    # keep_network=NO 可覆盖此行为。
    yesno ${keep_network:-YES} && yesno $RC_GOINGDOWN && return 0

    local IFACE='' module=''
    local IFVAR=''
    IFACE=$(get_interface)
    IFVAR=$(shell_var "${IFACE}")

    einfo "Bringing down interface ${IFACE}"
    eindent

    # 停止模式加载模块（列表会被反转）
    if [ -z "${MODULES}" ]; then
        local MODULES=''
        _load_modules false
    fi

    # 用户 predown() 钩子优先；
    # 未定义钩子时做安全检查：根分区是网络文件系统则禁止停网
    if [ "$(command -v predown)" = "predown" ]; then
        ebegin "Running predown"
        eindent
        predown || return 1
        eoutdent
    else
        if is_net_fs /; then
            eerror "root filesystem is network mounted -- can't stop ${IFACE}"
            return 1
        fi
    fi

    # 各模块 <mod>_pre_stop（如断开 wpa_supplicant 前先通知）
    for module in ${MODULES}; do
        if [ "$(command -v "${module}_pre_stop")" = "${module}_pre_stop" ]; then
            ${module}_pre_stop || exit $?
        fi
    done

    # 各模块 <mod>_stop（停 dhcpcd、kill wpa_supplicant 等）
    for module in ${MODULES}; do
        if [ "$(command -v "${module}_stop")" = "${module}_stop" ]; then
            ${module}_stop
        fi
    done

    # 删除接口上的所有地址（仅当接口仍存在；
    # PPP 后台模式除外——"demand" 按需拨号时地址由 pppd 自己管理）
    if _exists; then
        # PPP can manage it's own addresses when IN_BACKGROUND
        # Important in case "demand" set on the ppp link
        if ! (yesno ${IN_BACKGROUND} && is_ppp) ; then
            _delete_addresses "${IFACE}"
        fi
    fi

    # 各模块 <mod>_post_stop
    for module in ${MODULES}; do
        if [ "$(command -v "${module}_post_stop")" = "${module}_post_stop" ]; then
            ${module}_post_stop
        fi
    done

    # 非后台模式且非回环口：把接口 DOWN 掉
    # 可用 ifdown_<IFVAR>=no 或全局 ifdown=no 禁止
    if ! yesno ${IN_BACKGROUND} && \
    [ "${IFACE}" != "lo" ] && [ "${IFACE}" != "lo0" ]; then
        eval module=\$ifdown_${IFVAR}
        module=${module:-${ifdown:-YES}}
        yesno ${module} && _down 2>/dev/null
    fi

    # 通知 resolvconf 删除该接口注册的 DNS 配置
    command -v resolvconf >/dev/null && resolvconf -d "${IFACE}" 2>/dev/null

    # 用户 postdown() 钩子
    if [ "$(command -v "postdown")" = "postdown" ]; then
        ebegin "Running postdown"
        eindent
        postdown
        eoutdent
    fi

    return 0
}
```
