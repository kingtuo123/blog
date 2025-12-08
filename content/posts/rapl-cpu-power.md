---
title: "RAPL 获取 CPU 功耗"
date: "2025-10-09"
toc: false
---


## 简介

PARL（Running Average Power Limit），Intel 的 CPU 硬件级功耗监控和管理接口。AMD 亦可用，但支持会比 Intel 差。

RAPL 支持通过 sysfs 和 msr 两种方式读取数据。


## 内核配置


```text
CONFIG_X86_MSR=y
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y
```




## Sysfs 接口

```text
/sys/class/powercap/intel-rapl/intel-rapl:0/   # 第 0 颗物理 CPU 封装
├──name                                        # 域的名称，通常是 "package-0"
├──energy_uj                                   # 累计能耗计数器，单位是微焦耳
├──max_energy_range_uj                         # 能耗计数器的最大值，溢出后会归零
├──enabled                                     # 功耗限制是否启用，默认 0 不启用
├──power_uw                                    # 瞬时功率，单位是微瓦（不一定支持）
└──intel-rapl:0:0/                             # 子域，例如 core，核心功耗
```

## Udev 配置

```bash-session
$ cd /sys/class/powercap/intel-rapl/intel-rapl:0
$ ls -l energy_uj 
-r-------- 1 root root 4096 Oct  9 09:15 energy_uj
$ udevadm info --attribute-walk --path=/sys/class/powercap/intel-rapl:0
KERNEL=="intel-rapl:0"
SUBSYSTEM=="powercap"
DRIVER==""
ATTR{enabled}=="0"
ATTR{energy_uj}=="(not readable)"
ATTR{max_energy_range_uj}=="65532610987"
ATTR{name}=="package-0"
```

普通用户对 `energy_uj` 无可读权限，通过 udev 规则设置权限


<div class="code-bar"><span>文件</span><span>/etc/udev/rules.d/99-powercap.rules</span></div>

```bash
SUBSYSTEM=="powercap", KERNEL=="intel-rapl:0", RUN+="/usr/bin/chmod a+r /sys/class/powercap/%k/energy_uj"
```

重新加载 + 触发规则：

```bash-session
# udevadm control --reload
# udevadm trigger
```

## Bash 脚本

```bash
#!/bin/bash

file_energy_uj="/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj"
file_max_energy_range_uj="/sys/class/powercap/intel-rapl/intel-rapl:0/max_energy_range_uj"

energy_max=$(<$file_max_energy_range_uj)
energy_old=$(<$file_energy_uj)

while true; do
	sleep 1
	energy_now=$(<$file_energy_uj)
	if [[ $energy_now -ge $energy_old ]]; then
		watt=$(( (energy_now - energy_old) / 100000 ))
	else
		watt=$(( (energy_max - energy_old + energy_now) / 100000 ))
	fi
	energy_old=$energy_now
	watt="$((watt/10)).$((watt%10))"
	printf "   功耗 %5sw   \n" $watt
done
```
