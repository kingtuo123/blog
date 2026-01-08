---
title: "Gentoo chrony 时间同步"
date: "2025-09-20"
toc: false
---


## USE 标志

```bash
net-misc/chrony    -* caps rtc cmdmon readline seccomp
```


## 配置

{{< bar title="/etc/chrony/chrony.conf" >}}

```bash
# NTP 源，chrony 会自动选择最优服务器，无须排序
# 上海交大
server ntp.sjtu.edu.cn           iburst
# 国家授时中心
server ntp.ntsc.ac.cn            iburst
# 阿里云
server ntp1.aliyun.com           iburst
# 腾讯云
server ntp.tencent.com           iburst
# 清华大学
server ntp.tuna.tsinghua.edu.cn  iburst

# 记录时钟漂移
driftfile /var/lib/chrony/drift

# 如果系统时间偏差大于 1 秒，前 3 次更新用步进方式修正
makestep 1.0 3

# 启用 RTC（硬件时钟）同步
rtcsync
```

> `rtcsync` 可能需要启用内核选项 `CONFIG_RTC_SYSTOHC`，当有时间同步事件时内核间隔 11 分钟写入一次硬件时间


## 启用服务

```bash-session
# rc-service chronyd start 
# rc-update add chronyd default
```


## 命令行工具

查看服务器状态：

```bash-session
$ chronyc -N sources
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
^- ntp.sjtu.edu.cn               1   6   377   117  +5213us[+5577us] +/-   62ms
^+ ntp.ntsc.ac.cn                3   6   377    50  -6185us[-6185us] +/-   41ms
^* ntp1.aliyun.com               2   6   377    53  +1905us[+2283us] +/-   20ms
^+ ntp.tencent.com               2   6   377    56  +2178us[+2555us] +/-   46ms
^? ntp.tuna.tsinghua.edu.cn      0   8     0     -     +0ns[   +0ns] +/-    0ns
```

{{< table thead="false" >}}

|             |                                                                                               |
|:------------|:----------------------------------------------------------------------------------------------|
|`^*`         | 当前源                                                                                        |
|`^+`         | 备用源                                                                                        |
|`^-`         | 未被选用                                                                                      |
|`^?`         | 状态未知或无法使用                                                                            |
|`Stratum`    | 服务器在 NTP 层级中的位置，数字越小越接近原始时间源，理论上越精确                             |
|             |`Stratum 1`: 表示该服务器直连高精度的硬件时钟（如原子钟、GPS）                                 |
|             |`Stratum 2`: 从 Stratum 1 服务器同步时间的服务器                                               |
|`Poll`       |轮询间隔，如 6 表示 2^6 = 64 秒                                                                |
|`Reach`      |可达性寄存器，8 进制数，表示最近 8 次轮询请求的成功/失败历史记录                               |
|`LastRx`     |最后一次收到响应是在多久之前，单位是秒，`-` 表示从未收到过响应                                 |
|`Last sample`|最后一次测量的时间偏移 `调整的偏移量 [测量的偏移量] 估计误差`                                  |

{{< /table >}}
