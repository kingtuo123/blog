---
title: "CM3 异常处理"
date: "2026-01-29"
draft: true
---


## 简介

异常包括：

- 系统异常：由内核、内核外设（如 SysTick 、MPU 等）触发。
- 外部中断：由设备外设（如 GPIO 、USART 等）触发。


## 异常编号

- 异常编号：硬件层面的编号体系。
- CMSIS-Core 枚举值：软件层面的编号体系，使用负数区分系统异常与外部中断，能提高部分 API 函数的效率（设置优先级）。

{{< table min-width="100" >}}
|异常编号 |异常类型           |CMSIS-Core 枚举       | CMSIS-Core 枚举值 |异常处理名         |优先级     |
|:--------|:------------------|:---------------------|:------------------|:------------------|:----------|
|1        |复位               |--                    |--                 |Reset_Handler      |-3（最高） |
|2        |不可屏蔽中断       |NonMaskableInt_IRQn   |-14                |NMI_Handler        |-2         |
|3        |硬件故障           |MemoryManagement_IRQn |-13                |HardFault_Handler  |-1         |
|4        |内存管理故障       |BusFault_IRQn         |-12                |MemManage_Handler  |可编程     |
|5        |总线故障           |BusFault_IRQn         |-11                |BusFault_Handler   |可编程     |
|6        |使用故障           |UsageFault_IRQn       |-10                |UsageFault_Handler |可编程     |
|7 ~ 10   |--                 |--                    |--                 |--                 |--         |
|11       |系统服务调用       |SVCall_IRQn           |-5                 |SVC_Handler        |可编程     |
|12       |调试监控           |DebugMonitor_IRQn     |-4                 |DebugMon_Handler   |可编程     |
|13       |--                 |--                    |--                 |--                 |--         |
|14       |可挂起的服务调用   |PendSV_IRQn           |-2                 |PendSV_Handler     |可编程     |
|15       |系统节拍定时器     |SysTick_IRQn          |-1                 |SysTick_Handler    |可编程     |
|16 ~ 255 |外部中断 #0 ~ #239 |设备定义              |0 ~ 239            |设备定义           |可编程     |
{{< /table >}}


## 向量表偏移寄存器

{{< img src="vtor-reg.svg" >}}

- 复位值为 0 。
- TBLOFF：向量表基地址偏移。
- TBLBASE：`0` 表示向量表基于 CODE 区，`1` 表示向量表基于 SRAM 区。



## 向量表

- 向量地址 = 向量表偏移地址 + 异常编号 × 4 。
- 向量的最低位必须置 1 以表示 Thumb 状态。

{{< img src="vector-table.svg" >}}


## CONTROL 寄存器

{{< img src="control-reg.svg" >}}

- 复位值为 0 。
- nPRIV：`0` 表示特权模式，`1` 表示非特权模式。
  - 特权模式：可访问 NVIC 、SCB 等寄存器，主要用于 RTOS 的安全隔离。
- SPSEL：`0` 表示线程模式下使用主栈指针 MSP ，`1` 表示线程模式下使用进程栈指针 PSP 。
  - 线程模式：上电复位后默认进入。
  - 处理模式：发生异常或中断时硬件自动切换，处理模式下 SPSEL 始终为 0 。


## AAPCS

ARM 架构过程调用标准（ARM Architecture Procedure Call Standard）。

|寄存器   |别名     |作用                                   |
|:--------|:--------|:--------------------------------------|
|R0       |a1       |参数1 / 返回值                         |
|R1       |a2       |参数2 / 返回值（64 位结果时与 R0 组合）|
|R2       |a3       |参数3                                  |
|R3       |a4       |参数4                                  |
|R4 - R11 |v1 - v8  |变量寄存器                             |
|R12      |IP       |内部调用临时寄存器                     |
|R13      |SP       |堆栈指针                               |
|R14      |LR       |链接寄存器                             |
|R15      |PC       |程序计数器                             |
|xPSR     |         ||

- 普通的 C 函数调用：
  - R0-R3 、 R12 、R14（LR）： 调用者无需保存，被调用者（函数）可以随意改。
  - R0-R3 、 R12 、R14（LR）、xPSR： 调用者无需保存，被调用者（函数）可以随意改。
  - R4-R11, SP, LR： 被调用者（函数）保存，必须保证返回时与进入时相同（要么不动，要么压栈后恢复）。


```text
函数调用
```


## 异常进入和压栈

1. 将 xPSR 、返回地址、LR 、R12 、R3 、R2 、R1 、R0 共八个值依次压栈。
2. LR 被设置为 EXC_RETURN
3. 正常函数流程
2. 异常返回时，执行 BX 或 POP 等指令将 LR 加载到 PC 。
3. 硬件检测到 PC = EXC_RETURN ，触发异常返回流程。





## 其它

普通函数调用不需要保存 xPSR ，中断需要，为什么？

中断为什么要保存 R12 ？

硬件检测到PC=EXC_RETURN，触发异常返回序列

外部中断信号从核外发出，信号最终要传递到NVIC(嵌套向量中断控制器)。NVIC跟内核紧密耦合，它控制着整个芯片中断的相关功能

SysTick中断会经过NVIC的优先级比较和仲裁机制

SysTick中断的使能/禁止不通过NVIC，而是通过自己的控制寄存器

SysTick的优先级通过NVIC的优先级寄存器配置

SysTick的挂起状态在SCB中，不在NVIC
