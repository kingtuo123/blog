---
title: "FreeRTOS 内核源码解析"
date: "2026-03-11"
draft: true
---

> 基于 Cortex-M3 。

## 基本概念

### SCV 异常

SVC 异常由 SVC 指令产生，机器编码格式如下：

{{< img src="svc-format.svg" margin="0 10px" >}}


```armasm
SVC #0x3    ; 调用 SVC 服务 3
```

当异常产生后，栈帧如下：

{{< img src="get-imm8.svg" margin="20px 0 0 0" >}}

若要获取 SVC 编号，汇编如下：

```armasm
SVC_Handler:
    TST    LR, #4           ; 按位与，计算 LR & 4 （EXC_RETURN[2] = 0 使用 MSP， EXC_RETURN[2] = 1 使用 PSP）
    ITE    EQ               ; 如果 Z = 1（结果为零），执行下一条；否则执行再下一条
    MRSEQ  R0, MSP          ; 若 Z = 1，R0 = MSP
    MRSNE  R0, PSP          ; 若 Z = 0，R0 = PSP
    LDR    R1, [R0, #24]    ; R1 = *(R0 + 24) = 返回地址
    LDRB   R0, [R1, #-2]    ; 取 8 位，R0 = *(R1 - 2) = SVC 编号
```

在 RTOS 中，SVC 异常的作用就是根据不同的编号调用不同的系统服务函数。


### PendSV 异常

PendSV 异常由 ICSR 寄存器中的 PENDSVSET 位设置挂起，异步执行（延迟到所有更高优先级 ISR 完成后）。

在 RTOS 中，PendSV 异常的作用就是切换任务上下文。
通常 PendSV 被设置为最低优先级，以确保实时性要求高的中断能被优先处理。


### SysTick 异常

在 RTOS 中，SysTick 异常的作用是为系统提供时间基准、任务调度（通过设置 PENDSVSET 位触发 PendSV 异常来完成实际的上下文切换）。




## 内核源码


```text{class="none-bg hover"}
{{< text fg="blue" >}}󰉋 {{< /text >}}FreeRTOS-Kernel
├── {{< text fg="green" >}} {{< /text >}}croutine.c         {{< text fg="gray-1" >}}协程{{< /text >}}
├── {{< text fg="green" >}} {{< /text >}}event_groups.c     {{< text fg="gray-1" >}}事件组{{< /text >}}
├── {{< text fg="green" >}} {{< /text >}}list.c             {{< text fg="gray-1" >}}链表数据结构{{< /text >}}
├── {{< text fg="green" >}} {{< /text >}}queue.c            {{< text fg="gray-1" >}}队列和信号量{{< /text >}}
├── {{< text fg="green" >}} {{< /text >}}stream_buffer.c    {{< text fg="gray-1" >}}流缓冲区{{< /text >}}
├── {{< text fg="green" >}} {{< /text >}}tasks.c            {{< text fg="gray-1" >}}任务创建、任务调度、任务切换、延时函数、空闲任务{{< /text >}}
├── {{< text fg="green" >}} {{< /text >}}timers.c           {{< text fg="gray-1" >}}软件定时器{{< /text >}}
├── {{< text fg="blue" >}}󰉋 {{< /text >}}include
│   ├── {{< text fg="yellow" >}} {{< /text >}}atomic.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}croutine.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}deprecated_definitions.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}event_groups.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}FreeRTOS.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}list.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}message_buffer.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}mpu_prototypes.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}mpu_syscall_numbers.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}mpu_wrappers.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}newlib-freertos.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}picolibc-freertos.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}portable.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}projdefs.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}queue.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}semphr.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}stack_macros.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}StackMacros.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}stream_buffer.h
│   ├── {{< text fg="yellow" >}} {{< /text >}}task.h
│   └── {{< text fg="yellow" >}} {{< /text >}}timers.h
└── {{< text fg="blue" >}}󰉋 {{< /text >}}portable
    └── {{< text fg="blue" >}}󰉋 {{< /text >}}GCC
        └── {{< text fg="blue" >}}󰉋 {{< /text >}}ARM_CM3
            ├── {{< text fg="green" >}} {{< /text >}}port.c
            └── {{< text fg="yellow" >}} {{< /text >}}portmacro.h
```



- 第一阶段：基础数据结构 list.c 和 list.h
- 第二阶段：核心调度机制 tasks.c 和 portable/ 目录下的移植代码
- 第三阶段：同步与通信 queue.c 和 timers.c 和 event_groups.c 
- 第四阶段：内存与高级特性 portable/MemMang/ 5 种内存分配方案和 stream_buffer.c 流式数据传输


{{< text fg="gray-1" >}}{{< /text >}}
