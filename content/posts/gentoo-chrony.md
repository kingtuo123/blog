---
title: "Gentoo chrony 时间同步"
date: "2025-09-20"
toc: false
---


## USE 标记

```bash
net-misc/chrony	-* caps rtc cmdmon readline seccomp
```


## 配置

主配置文件 `/etc/chrony/chrony.conf`

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

<div class="table-container no-thead"> 

|             |                                                                                               |
|:------------|:----------------------------------------------------------------------------------------------|
|`^*`         | 当前源                                                                                        |
|`^+`         | 备用源                                                                                        |
|`^-`         | 被弃用的源（不可靠）                                                                          |
|`^?`         | 状态未知或无法连接                                                                            |
|`Stratum`    | 表示服务器在 NTP 层级中的位置。数字越小，越接近原始时间源，理论上越精确                       |
|             |`Stratum 0`: 参考时钟（如原子钟、GPS）                                                         |
|             |`Stratum 1`: 从 Stratum 0 设备同步的服务器                                                     |
|             |`Stratum 2`: 从 Stratum 1 服务器同步的服务器                                                   |
|`Poll`       |轮询间隔，如 6 表示 2^6 = 64 秒                                                                |
|`Reach`      |可达性寄存器，这是一个 8 进制的数字，显示最近 8 次轮询的成功与否历史                           |
|`LastRx`     |表示距离上次成功从该服务器收到响应过去了多秒，`-` 表示从未收到过响应                           |
|`Last sample`|系统时钟与服务器时间之间的差值                                                                 |
|             |`+1905us[+2283us] +/-   20ms`                                                                  |
|             |`+1905us` 原始偏移量，即未经任何调整的测量值，系统时钟比服务器快 1905 微秒                     |
|             |`[+2283us]` 调整后的偏移量, Chrony 在考虑了测量时的网络延迟等因素后，计算出的更精确的时钟偏差  |
|             |`+/- 20ms` 估计误差范围                                                                        |

</div>
