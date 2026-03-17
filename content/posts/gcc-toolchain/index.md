---
title: "ARM GCC 工具链"
date: "2026-03-17"
draft: true
---






## 前缀命名

**`arch-[vendor]-[os]-[abi]`**

{{< table thead=false min-width="100,200" >}}
|               |                   |                          |
|:--------------|:------------------|:-------------------------|
|**arch**       |**架构**           |                          |
|               |`arm`              |32 位                     |
|               |`aarch64`          |64 位                     |
|               |`aarch64_be`       |64 位大端                 |
|**[ vendor ]** |**工具链提供商**   |                          |
|               |`none`             |无特定厂商                |
|**[ os ]**     |**操作系统**       |                          |
|               |`elf`              |裸机                      |
|               |`linux`            |目标系统运行 Linux        |
|**[ abi ]**    |**应用二进制接口** |                          |
|               |`eabi`             |嵌入式 ABI（软浮点）      |
|               |`eabihf`           |嵌入式 ABI（硬浮点）      |
|               |`gnu`              |GNU ABI（硬浮点）         |
|               |`gnueabi`          |GNU 嵌入式 ABI （软浮点） |
|               |`gnueabihf`        |GNU 嵌入式 ABI （硬浮点） |
{{< /table >}}


## 工具链

|||
|:--|:--|:--|
|**核心编译工具**   |`arm-none-eabi-gcc`|C 编译器|
|                   |`arm-none-eabi-g++`|C++ 编译器|
|                   |`arm-none-eabi-cpp`|C 预处理器|
|**汇编器与链接器** |`arm-none-eabi-as` |汇编器|
|                   |`arm-none-eabi-ld` |链接器 |
|**二进制工具**     |||


## 参考链接

- 工具链下载地址：[arm-gnu-toolchain-downloads](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
