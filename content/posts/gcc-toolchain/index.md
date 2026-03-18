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

{{< table thead=false >}}
|                   |                        |                               |
|:------------------|:-----------------------|:------------------------------|
|**编译工具**       |`arm-none-eabi-gcc`     |C 编译器                       |
|                   |`arm-none-eabi-g++`     |C++ 编译器                     |
|                   |`arm-none-eabi-cpp`     |C 预处理器                     |
|**汇编/链接器**    |`arm-none-eabi-as`      |汇编器                         |
|                   |`arm-none-eabi-ld`      |链接器                         |
|**二进制工具**     |`arm-none-eabi-objcopy` |格式转换器                     |
|                   |`arm-none-eabi-objdump` |显示目标文件信息与反汇编       |
|                   |`arm-none-eabi-size`    |列出目标文件中各段的大小       |
|                   |`arm-none-eabi-nm`      |列出目标文件中的符号表         |
|                   |`arm-none-eabi-strings` |从二进制文件中提取可打印字符串 |
|                   |`arm-none-eabi-strip`   |去除目标文件中的符号信息       |
|                   |`arm-none-eabi-readelf` |显示 ELF 格式文件的详细信息    |
{{< /table >}}


## 常用参数

{{< table thead=false mono=true >}}
||||
|:--|:--|:--|
|**基本选项**          |
|`-c`                  |只编译不链接           |`gcc -c test.c -o test.o`                  |
|`-o`                  |指定输出文件名         |                                           |
|`-E`                  |只运行预处理器         |`gcc -E test.c -o test.i`                  |
|`-S`                  |只编译成汇编代码       |`gcc -S test.c -o test.s`                  |
|`-L`                  |添加库搜索路径         |                                           |
|`-x`                  |指定输入文件的语言     |`c` `c++` `assembler` `assembler-with-cpp`（先调用C预处理器再汇编）
|`-v`                  |显示编译过程的详细信息 |                                           |
|**目标架构**          |                       |                                           |
|`-mcpu=`              |指定目标 CPU           |`cortex-m3` `cortex-m4`                    |
|`-mthumb`             |使用 Thumb 指令集      |Cortex-M 系列                              |
|`-marm`               |使用 ARM 指令集        |Cortex-A/R 系列                            |
|`-mfloat-abi=`        |浮点 ABI               |`soft` `softfp` `hard`                     |
|`-mfpu=`              |指定 FPU 类型          |`fpv4-sp-d16`                              |
|**优化选项**          |                       |                                           |
|`-O`                  |优化级别               | 0 ~ 3 优化级别逐级提高                    |
|`-Os`                 |优化代码大小           |                                           |
|`-Og`                 |适合调试的优化         |                                           |
|`-ffunction-sections` |为每个函数创建独立的段 |如 `.text.function_name`                   |
|**预处理**            |                       |                                           |
|`-D`                  |定义宏                 |`gcc -D STM32F10X_HD -D HSE_VALUE=8000000` |
|**包含路径**          |                       |                                           |
|`-I`                  |添加头文件搜索路径     |`gcc -I dir`                               |
|**警告选项**          |                       |                                           |
|`-Wall`               |启用大多数警告         |                                           |
|`-Wextra`             |启用额外警告           |                                           |
|`-Werror`             |将所有警告视为错误     |                                           |
|**链接选项**          |                       |                                           |
|`-T`                  |指定链接脚本           |                                           |
|`-Wl,`                |传递参数给链接器       |多个参数用逗号分隔 `-Wl,-Map=target.map,-cref,--gc-sections` |
|`-l`                  |链接指定的库           |`-lc` 链接标准库 `-lm` 链接数学库          |
{{< /table >}}

## 参考链接

- 工具链下载地址：[arm-gnu-toolchain-downloads](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
