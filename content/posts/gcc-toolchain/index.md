---
title: "ARM GCC 工具链"
date: "2026-03-17"
draft: true
---






## 前缀命名

**`arch-[vendor]-[os]-[abi]`**

{{< table thead=false min-width="150,200" >}}
|                           |                   |                          |
|:--------------------------|:------------------|:-------------------------|
|**arch**                   |`arm`              |32 位                     |
|                           |`aarch64`          |64 位                     |
|                           |`aarch64_be`       |64 位大端                 |
|**vendor**                 |`none`             |无特定厂商                |
|**os**                     |`elf`              |裸机                      |
|                           |`linux`            |目标系统运行 Linux        |
|**abi**                    |`eabi`             |嵌入式 ABI（软浮点）      |
|                           |`eabihf`           |嵌入式 ABI（硬浮点）      |
|                           |`gnu`              |GNU ABI（硬浮点）         |
|                           |`gnueabi`          |GNU 嵌入式 ABI （软浮点） |
|                           |`gnueabihf`        |GNU 嵌入式 ABI （硬浮点） |
{{< /table >}}




## 工具链

{{< table thead=false min-width="150,200" >}}
|                   |          |                               |
|:------------------|:---------|:------------------------------|
|**编译工具**       |`gcc`     |C 编译器                       |
|                   |`g++`     |C++ 编译器                     |
|                   |`cpp`     |C 预处理器                     |
|**汇编/链接器**    |`as`      |汇编器                         |
|                   |`ld`      |链接器                         |
|**二进制工具**     |`objcopy` |格式转换器                     |
|                   |`objdump` |显示目标文件信息与反汇编       |
|                   |`size`    |列出目标文件中各段的大小       |
|                   |`nm`      |列出目标文件中的符号表         |
|                   |`strings` |从二进制文件中提取可打印字符串 |
|                   |`strip`   |去除目标文件中的符号信息       |
|                   |`readelf` |显示 ELF 格式文件的详细信息    |
{{< /table >}}




## GCC 参数

{{< table thead=false mono=true min-width="150,200" >}}
||||
|:--|:--|:--|
|**基本选项**  |`-c`                  |只编译不链接：`gcc -c test.c -o test.o`                           |
|              |`-o`                  |指定输出文件名                                                    |
|              |`-E`                  |只运行预处理器：`gcc -E test.c -o test.i`                         |
|              |`-S`                  |只编译成汇编代码：`gcc -S test.c -o test.s`                       |
|              |`-x`                  |指定输入文件的语言：`c` `c++` `assembler` `assembler-with-cpp`|
|              |`-g`                  |生成调试信息（供 GDB 使用）                                       |
|              |`-v`                  |显示编译过程的详细信息                                            |
|**目标架构**  |`-mcpu=`              |指定目标 CPU：`cortex-m3` `cortex-m4`                             |
|              |`-mthumb`             |使用 Thumb 指令集：Cortex-M 系列                                  |
|              |`-marm`               |使用 ARM 指令集：Cortex-A/R 系列                                  |
|              |`-mfloat-abi=`        |浮点 ABI：`soft` `softfp` `hard`                                  |
|              |`-mfpu=`              |指定 FPU 类型：`fpv4-sp-d16`                                      |
|**优化选项**  |`-O`                  |优化级别：0 ~ 3 优化级别逐级提高                                  |
|              |`-Os`                 |优化代码大小                                                      |
|              |`-Og`                 |适合调试的优化                                                    |
|              |`-ffunction-sections` |为每个函数创建独立的段：`func1` → 编译 → `.section .text.func1,"ax"` |
|              |`-fdata-sections`     |为每个变量创建独立的段
|**预处理**    |`-D`                  |定义宏：`gcc -D STM32F10X_HD -D HSE_VALUE=8000000`                |
|**包含路径**  |`-I`                  |添加头文件搜索路径：`gcc -I dir`                                  |
|**警告选项**  |`-Wall`               |启用大多数警告                                                    |
|              |`-Wextra`             |启用额外警告                                                      |
|              |`-Werror`             |将所有警告视为错误                                                |
|**链接选项**  |`-T`                  |指定链接脚本                                                      |
|              |`-L`                  |添加库文件搜索路径                                                |
|              |`-l`                  |链接指定的库：`-lc` 链接标准库 `-lm` 链接数学库                   |
|              |`-Wl,`                |传递参数给链接器：多个参数用逗号分隔 `-Wl,-Map=target.map,-cref,--gc-sections` |
|**其它**      |`-MMD`                |编译时自动生成 `.d` 依赖文件，忽略系统头文件（与 `.o` 在同一目录）|
|              |`-MP`                 |为 `.d` 依赖文件中的每个头文件生成一个伪目标（Phony）规则         |
{{< /table >}}




## AS 参数

{{< table thead=false mono=true min-width="150,200" >}}
|              |                      |                                             |
|:-------------|:---------------------|:--------------------------------------------|
|**基本选项**  |`-o`                  |指定输出文件名：`as startup.s -o startup.o`  |
|              |`-g`                  |生成调试信息                                 |
|              |`-I`                  |添加包含路径（用于 `.include` 指令）         |
|              |`--defsym`            |定义符号：`as -defsym BUFFER_SIZE=1024`      |
|**目标架构**  |`-mcpu=`              |指定目标 CPU：`cortex-m3` `cortex-m4`        |
|              |`-mthumb`             |使用 Thumb 指令集：Cortex-M 系列             |
|              |`-marm`               |使用 ARM 指令集：Cortex-A/R 系列             |
|              |`-mfloat-abi=`        |浮点 ABI：`soft` `softfp` `hard`             |
|              |`-mfpu=`              |指定 FPU 类型：`fpv4-sp-d16`                 |
|**警告选项**  |`--warn`              |启用警告                                     |
|              |`--fatal-warnings`    |将警告视为错误                               |
{{< /table >}}




## LD 参数

{{< table thead=false mono=true min-width="150,200" >}}
|              |                         |                                                  |
|:-------------|:------------------------|:-------------------------------------------------|
|**基本选项**  |`-T`                     |指定链接脚本                                      |
|              |`-o`                     |指定输出文件名                                    |
|              |`-Map=`                  |生成链接映射文件                                  |
|**库选项**    |`-L`                     |添加库文件搜索路径                                |
|              |`-l`                     |链接指定的库                                      |
|              |`-static`                |静态链接                                          |
|**段控制**    |`--gc-sections`          |删除未使用的段                                    |
|              |`--print-gc-sections`    |打印被删除的段                                    |
|**其它**      |`--print-memory-usage`   |打印内存使用统计                                  |
|              |`--specs=nano.specs`     |使用 newlib-nano（精简 C 库）替换 libc、libm 等   |
|              |`--no-warn-rwx-segments` |禁用关于内存段同时具有读、写、执行权限的警告信息  |
|              |`--cref`                 |输出交叉引用表                                    |

{{< /table >}}




## 疑问

**`1.` 直接使用 `as` 汇编器和使用 `gcc -x assembler-with-cpp` 有什么区别？**

- 使用 `as` 时，汇编器接收的是纯汇编代码，不经过任何预处理。支持汇编的宏 `.macro` 。
- 使用 `gcc -x assembler-with-cpp` 时，代码会先经过 C 预处理器处理，然后再交给汇编器。支持 C 预处理器的宏 `#define` 。




## 参考链接

- 工具链下载地址：[arm-gnu-toolchain-downloads](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
