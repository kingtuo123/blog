---
title: "FreeRTOS 内核源码解析"
date: "2026-03-11"
toc: true
draft: true
---

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



### PendSV 异常
