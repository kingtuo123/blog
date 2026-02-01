---
title: "CM3 深入了解异常处理"
date: "2026-01-29"
draft: true
---


## 异常与中断

异常：由内核触发（如复位、硬件错误、SysTick 等）触发的事件。

中断：是异常的一个子集，由外部外设（如GPIO、定时器、USART等）触发的事件。



中断是指系统停止当前正在运行的程序转到其他的服务，可能是程序接收了比自身高优先级的请求，或者是人为设置中断，中断是属于正常现象。

异常是指由于CPU本身故障、程序故障或者请求服务等引起的错误，异常属于不正常现象。

## 异常编号

异常编号是ARM Cortex-M内核硬件上定义和实现的。它是一个固定的、标准化的编号体系，所有Cortex-M内核都遵循这一规范。

异常编号直接决定了该异常在异常向量表中的位置（偏移量）。向量表是一块连续的内存区域，每个条目（4字节）存放一个异常处理函数的地址。CPU根据异常号计算偏移量：

```text
向量地址 = 向量表基址 + 异常号 × 4
```

core 枚举值是 stm32f10x.h


{{< table min-width="100" >}}
|异常编号 |异常类型           |CMSIS-Core 枚举       | CMSIS-Core 枚举值 |异常处理名         |优先级     |
|:--------|:------------------|:---------------------|:------------------|:------------------|:----------|
|1        |复位               |--                    |--                 |Reset_Handler      |-3（最高） |
|2        |不可屏蔽中断       |NonMaskableInt_IRQn   |-14                |NMI_Handler        |-2         |
|3        |硬件错误           |MemoryManagement_IRQn |-13                |HardFault_Handler  |-1         |
|4        |内存管理错误       |BusFault_IRQn         |-12                |MemManage_Handler  |可编程     |
|5        |总线错误           |BusFault_IRQn         |-11                |BusFault_Handler   |可编程     |
|6        |使用错误           |UsageFault_IRQn       |-10                |UsageFault_Handler |可编程     |
|7 ~ 10   |--                 |--                    |--                 |--                 |--         |
|11       |系统服务调用       |SVCall_IRQn           |-5                 |SVC_Handler        |可编程     |
|12       |调试监控           |DebugMonitor_IRQn     |-4                 |DebugMon_Handler   |可编程     |
|13       |--                 |--                    |--                 |--                 |--         |
|14       |可挂起的服务调用   |PendSV_IRQn           |-2                 |PendSV_Handler     |可编程     |
|15       |系统节拍定时器     |SysTick_IRQn          |-1                 |SysTick_Handler    |可编程     |
|16 ~ 255 |外部中断 #0 ~ #239 |设备定义              |0 ~ 239            |设备定义           |可编程     |
{{< /table >}}



## 其它

异常不走 NVIC ，优先级配置 SCB->SHP

外部中断走 NVIC ，优先级配置 NVIC->IP

外部中断信号从核外发出，信号最终要传递到NVIC(嵌套向量中断控制器)。NVIC跟内核紧密耦合，它控制着整个芯片中断的相关功能

SysTick中断会经过NVIC的优先级比较和仲裁机制

SysTick中断的使能/禁止不通过NVIC，而是通过自己的控制寄存器

SysTick的优先级通过NVIC的优先级寄存器配置

SysTick的挂起状态在SCB中，不在NVIC

## AAPCS
