---
title: "Gentoo 内核配置"
date: "2026-09-13"
draft: true
ontop: -1
---



## 我的

```
I2C_CHARDEV      字符设备 /dev/i2c-*（如 HDMI 设备的亮度控制等）

# 沙盒
CONFIG_SECURITY=y
CONFIG_SECURITY_LANDLOCK=y
CONFIG_LSM="landlock"
```
