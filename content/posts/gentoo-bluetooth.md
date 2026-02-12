---
title: "Gentoo 蓝牙耳机配置"
date: "2025-12-18"
toc: false
---


## 内核配置

```makefile
CONFIG_BT           : 启用蓝牙，必须启用
BT_BREDR            : 经典蓝牙协议栈，必须启用
CONFIG_BT_RFCOMM    : 模拟 RS-232 串口，纯听歌可不启用，设备控制或数据传输要启用
CONFIG_BT_HIDP      : 蓝牙 HID 协议栈，键鼠、手柄等 HID 设备要启用
CONFIG_BT_LE        : 低功耗蓝牙，纯听歌可不启用，传感器/穿戴等低功耗设备要启用
CONFIG_BT_HCIBTUSB  : USB 蓝牙适配器驱动，无线网卡的蓝牙模块大多走 USB 连接
CONFIG_RFKILL       : 用于管理无线射频设备（Wi-Fi、蓝牙、移动网络等）的开关状态
```

设备 `Intel AX210 无线网卡` + `蓝牙耳机` ，仅启用以下：

```text
CONFIG_BT
BT_BREDR
CONFIG_BT_HCIBTUSB
CONFIG_RFKILL
```



## 安装 BlueZ

```bash-session
# emerge -av net-wireless/bluez
```



## OpenRC 启动

```bash-session
# rc-update add bluetooth default
```


## 连接耳机

交互模式，配对与连接：

```bash-session
$ bluetoothctl
[进入交互模式]
> power on
> scan on
> devices
Device 01:10:C4:71:BC:23 SIMGOT EH500
> scan off
> pair 01:10:C4:71:BC:23
> trust 01:10:C4:71:BC:23
> connect 01:10:C4:71:BC:23
```

非交互模式，查看已连接的设备：

```bash-session
$ bluetoothctl devices Connected
Device 01:10:C4:71:BC:23 SIMGOT EH500
```


## PipeWire 切换设备

`media-video/pipewire` 需启用 USE 标志 `bluetooth` 和 `sound-server` 。

```bash-session
$ pactl list sinks short 
53   alsa_output.pci-0000_c6_00.6.analog-stereo    PipeWire	s32le 2ch 48000Hz	SUSPENDED
149  bluez_output.01_10_C4_71_BC_23.1              PipeWire	s16le 2ch 48000Hz	RUNNING
$ pactl set-default-sink bluez_output.01_10_C4_71_BC_23.1
```


## Rfkill

```bash-session
$ rfkill 
ID  TYPE       DEVICE       SOFT       HARD
 0  wlan       phy0    unblocked  unblocked
 1  bluetooth  hci0    unblocked  unblocked
```

```bash-session
$ rfkill block 1       # 关闭蓝牙，可用 bluetooth 代替 1
$ rfkill unblock 1     # 开启蓝牙
```

`HARD` 是物理开关不用理会，`unblock` 后需要手动连接蓝牙。


## Udev 规则

```bash-session
$ ls /sys/class/bluetooth
hci0  hci0:256
$ udevadm info --attribute-walk --path=/sys/class/bluetooth/hci0:256
looking at device '/devices/pci0000:00/0000:00:08.1/0000:c6:00.3/usb1/1-5/1-5:1.0/bluetooth/hci0/hci0:256':
  KERNEL=="hci0:256"
  SUBSYSTEM=="bluetooth"
  DRIVER==""
  ATTR{power/control}=="auto"
  ATTR{power/runtime_active_time}=="0"
  ATTR{power/runtime_status}=="unsupported"
  ATTR{power/runtime_suspended_time}=="0"
```

由于没有能标识设备唯一性的 ATTR 属性，所以只能对所有蓝牙设备应用以下规则：

{{< bar title="/etc/udev/rules.d/88-bluetooth.rules" >}}

```bash
# 当蓝牙设备连接时触发
ACTION=="add", SUBSYSTEM=="bluetooth", RUN+="/usr/bin/su king /home/king/.config/sway/scripts/bluetooth-connected.sh"
# 当蓝牙设备断开时触发
ACTION=="remove", SUBSYSTEM=="bluetooth", RUN+="/usr/bin/su king /home/king/.config/sway/scripts/bluetooth-disconnected.sh"
```

```bash-session
# udevadm control --reload
```


## 参考链接

- [Gentoo wiki / Bluetooth](https://wiki.gentoo.org/wiki/Bluetooth)
