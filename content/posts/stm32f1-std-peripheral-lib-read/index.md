---
title: "STM32F1 标准库源码阅读"
date: "2026-01-14"
toc: true
draft: true
---


## core_cm3.h

```c
#ifndef __CM3_CORE_H__
#define __CM3_CORE_H__

#ifdef __cplusplus                          // 如果使用 C++ 编译器，使用 C 链接约定
    extern "C" {
#endif 

#define __CM3_CMSIS_VERSION_MAIN  (0x01)    // [31:16] CMSIS HAL 主版本号（Hardware Abstraction Layer）
#define __CM3_CMSIS_VERSION_SUB   (0x30)    // [15:0]  CMSIS HAL 子版本号
#define __CM3_CMSIS_VERSION       ((__CM3_CMSIS_VERSION_MAIN << 16) | __CM3_CMSIS_VERSION_SUB)    // CMSIS HAL 版本号

#define __CORTEX_M                (0x03)    // Cortex 核心

#include <stdint.h>                         // 包含标准整数类型

#if defined (__ICCARM__)
    #include <intrinsics.h>                 // IAR 内置函数
#endif

#ifndef __NVIC_PRIO_BITS
    #define __NVIC_PRIO_BITS    4           // NVIC 优先级寄存器实际可用位，STM32F1 系列有 4 位（16级）
#endif


/****************************************************************************************************
 *                                IO 定义: 对外设寄存器的访问限制 
 ***************************************************************************************************/

#ifdef __cplusplus
    #define  __I     volatile              // 定义'只读'权限
#else
    #define  __I     volatile const        // 定义'只读'权限
#endif
#define      __O     volatile              // 定义'只写'权限
#define      __IO    volatile              // 定义'读/写'权限



/****************************************************************************************************
 *                                           寄存器抽象 
 ***************************************************************************************************/

typedef struct                              // 嵌套向量中断控制器的内存映射结构 Nested Vectored Interrupt Controller (NVIC)
{
    __IO uint32_t ISER[8];                  // 偏移: 0x000 中断设置使能寄存器  Interrupt Set Enable Register
         uint32_t RESERVED0[24];                                 
    __IO uint32_t ICER[8];                  // 偏移: 0x080 中断清除使能寄存器  Interrupt Clear Enable Register
         uint32_t RSERVED1[24];
    __IO uint32_t ISPR[8];                  // 偏移: 0x100 中断设置挂起寄存器  Interrupt Set Pending Register 
         uint32_t RESERVED2[24];                                 
    __IO uint32_t ICPR[8];                  // 偏移: 0x180 中断清除挂起寄存器  Interrupt Clear Pending Register
         uint32_t RESERVED3[24];                                 
    __IO uint32_t IABR[8];                  // 偏移: 0x200 中断活动位寄存器    Interrupt Active bit Register
         uint32_t RESERVED4[56];                                 
    __IO uint8_t  IP[240];                  // 偏移: 0x300 中断优先级寄存器    Interrupt Priority Register (8Bit wide)
         uint32_t RESERVED5[644];                                
    __O  uint32_t STIR;                     // 偏移: 0xE00 软件触发中断寄存器  Software Trigger Interrupt Register
}  NVIC_Type;                                               

typedef struct                              // 系统控制块的内存映射结构                System Control Block (SCB)
{
    __I  uint32_t CPUID;                    // 偏移: 0x00 CPU ID 基地址寄存器          CPU ID Base Register
    __IO uint32_t ICSR;                     // 偏移: 0x04 中断控制和状态寄存器         Interrupt Control State Register
    __IO uint32_t VTOR;                     // 偏移: 0x08 向量表偏移寄存器             Vector Table Offset Register
    __IO uint32_t AIRCR;                    // 偏移: 0x0C 应用中断/复位控制寄存器      Application Interrupt / Reset Control Register
    __IO uint32_t SCR;                      // 偏移: 0x10 系统控制寄存器               System Control Register
    __IO uint32_t CCR;                      // 偏移: 0x14 配置控制寄存器               Configuration Control Register
    __IO uint8_t  SHP[12];                  // 偏移: 0x18 系统处理程序优先级寄存器     System Handlers Priority Registers (4-7, 8-11, 12-15)
    __IO uint32_t SHCSR;                    // 偏移: 0x24 系统处理程序控制和状态寄存器 System Handler Control and State Register
    __IO uint32_t CFSR;                     // 偏移: 0x28 可配置故障状态寄存器         Configurable Fault Status Register
    __IO uint32_t HFSR;                     // 偏移: 0x2C 硬件故障状态寄存器           Hard Fault Status Register
    __IO uint32_t DFSR;                     // 偏移: 0x30 调试故障状态寄存器           Debug Fault Status Register
    __IO uint32_t MMFAR;                    // 偏移: 0x34 内存管理地址寄存器           Mem Manage Address Register
    __IO uint32_t BFAR;                     // 偏移: 0x38 总线故障地址寄存器           Bus Fault Address Register
    __IO uint32_t AFSR;                     // 偏移: 0x3C 辅助故障状态寄存器           Auxiliary Fault Status Register
    __I  uint32_t PFR[2];                   // 偏移: 0x40 处理器特性寄存器             Processor Feature Register
    __I  uint32_t DFR;                      // 偏移: 0x48 调试特性寄存器               Debug Feature Register
    __I  uint32_t ADR;                      // 偏移: 0x4C 辅助特性寄存器               Auxiliary Feature Register
    __I  uint32_t MMFR[4];                  // 偏移: 0x50 内存模型特性寄存器           Memory Model Feature Register
    __I  uint32_t ISAR[5];                  // 偏移: 0x60 指令集架构特性寄存器         ISA Feature Register
} SCB_Type;                                                

// SCB CPUID 寄存器定义
#define SCB_CPUID_IMPLEMENTER_Pos          24                                          // 厂商 ID
#define SCB_CPUID_IMPLEMENTER_Msk          (0xFFul << SCB_CPUID_IMPLEMENTER_Pos)
#define SCB_CPUID_VARIANT_Pos              20                                          // 主版本号
#define SCB_CPUID_VARIANT_Msk              (0xFul << SCB_CPUID_VARIANT_Pos)
#define SCB_CPUID_PARTNO_Pos                4                                          // 部件号
#define SCB_CPUID_PARTNO_Msk               (0xFFFul << SCB_CPUID_PARTNO_Pos)
#define SCB_CPUID_REVISION_Pos              0                                          // 修订号
#define SCB_CPUID_REVISION_Msk             (0xFul << SCB_CPUID_REVISION_Pos)

// SCB 中断控制状态寄存器定义
#define SCB_ICSR_NMIPENDSET_Pos            31                                          // NMI 挂起设置位
#define SCB_ICSR_NMIPENDSET_Msk            (1ul << SCB_ICSR_NMIPENDSET_Pos)
#define SCB_ICSR_PENDSVSET_Pos             28                                          // PendSV 设置位
#define SCB_ICSR_PENDSVSET_Msk             (1ul << SCB_ICSR_PENDSVSET_Pos)
#define SCB_ICSR_PENDSVCLR_Pos             27                                          // PendSV 清除位
#define SCB_ICSR_PENDSVCLR_Msk             (1ul << SCB_ICSR_PENDSVCLR_Pos)
#define SCB_ICSR_PENDSTSET_Pos             26                                          // SysTick 挂起设置位
#define SCB_ICSR_PENDSTSET_Msk             (1ul << SCB_ICSR_PENDSTSET_Pos)
#define SCB_ICSR_PENDSTCLR_Pos             25                                          // SysTick 挂起清除位
#define SCB_ICSR_PENDSTCLR_Msk             (1ul << SCB_ICSR_PENDSTCLR_Pos)
#define SCB_ICSR_ISRPREEMPT_Pos            23                                          // ISR 抢占位
#define SCB_ICSR_ISRPREEMPT_Msk            (1ul << SCB_ICSR_ISRPREEMPT_Pos)
#define SCB_ICSR_ISRPENDING_Pos            22                                          // 外部中断挂起位
#define SCB_ICSR_ISRPENDING_Msk            (1ul << SCB_ICSR_ISRPENDING_Pos)
#define SCB_ICSR_VECTPENDING_Pos           12                                          // 当前挂起的中断异常编号
#define SCB_ICSR_VECTPENDING_Msk           (0x1FFul << SCB_ICSR_VECTPENDING_Pos)
#define SCB_ICSR_RETTOBASE_Pos             11                                          // 返回到基址位
#define SCB_ICSR_RETTOBASE_Msk             (1ul << SCB_ICSR_RETTOBASE_Pos)
#define SCB_ICSR_VECTACTIVE_Pos             0                                          // 当前中断异常编号
#define SCB_ICSR_VECTACTIVE_Msk            (0x1FFul << SCB_ICSR_VECTACTIVE_Pos)

// SCB 向量表偏移寄存器定义
#define SCB_VTOR_TBLBASE_Pos               29                                          // 向量表基地址位（0:代码区，1:RAM）
#define SCB_VTOR_TBLBASE_Msk               (0x1FFul << SCB_VTOR_TBLBASE_Pos)
#define SCB_VTOR_TBLOFF_Pos                 7                                          // 基地址偏移
#define SCB_VTOR_TBLOFF_Msk                (0x3FFFFFul << SCB_VTOR_TBLOFF_Pos)

// SCB 应用中断和复位控制寄存器定义
#define SCB_AIRCR_VECTKEY_Pos              16                                          // 向量键，写入 AIRCR 寄存器时必须写入 0x5FA 到 VECTKEY
#define SCB_AIRCR_VECTKEY_Msk              (0xFFFFul << SCB_AIRCR_VECTKEY_Pos)
#define SCB_AIRCR_VECTKEYSTAT_Pos          16                                          // 向量键状态
#define SCB_AIRCR_VECTKEYSTAT_Msk          (0xFFFFul << SCB_AIRCR_VECTKEYSTAT_Pos)
#define SCB_AIRCR_ENDIANESS_Pos            15                                          // 字节大小端
#define SCB_AIRCR_ENDIANESS_Msk            (1ul << SCB_AIRCR_ENDIANESS_Pos)
#define SCB_AIRCR_PRIGROUP_Pos              8                                          // 优先级分组
#define SCB_AIRCR_PRIGROUP_Msk             (7ul << SCB_AIRCR_PRIGROUP_Pos)
#define SCB_AIRCR_SYSRESETREQ_Pos           2                                          // 系统复位请求位
#define SCB_AIRCR_SYSRESETREQ_Msk          (1ul << SCB_AIRCR_SYSRESETREQ_Pos)
#define SCB_AIRCR_VECTCLRACTIVE_Pos         1                                          // 清除活动向量位
#define SCB_AIRCR_VECTCLRACTIVE_Msk        (1ul << SCB_AIRCR_VECTCLRACTIVE_Pos)
#define SCB_AIRCR_VECTRESET_Pos             0                                          // 向量复位位
#define SCB_AIRCR_VECTRESET_Msk            (1ul << SCB_AIRCR_VECTRESET_Pos)

// SCB 系统控制寄存器定义
#define SCB_SCR_SEVONPEND_Pos               4                                          // 挂起时发送事件位
#define SCB_SCR_SEVONPEND_Msk              (1ul << SCB_SCR_SEVONPEND_Pos)
#define SCB_SCR_SLEEPDEEP_Pos               2                                          // 深度睡眠位
#define SCB_SCR_SLEEPDEEP_Msk              (1ul << SCB_SCR_SLEEPDEEP_Pos)
#define SCB_SCR_SLEEPONEXIT_Pos             1                                          // 退出时睡眠位
#define SCB_SCR_SLEEPONEXIT_Msk            (1ul << SCB_SCR_SLEEPONEXIT_Pos)

// SCB 配置控制寄存器定义
#define SCB_CCR_STKALIGN_Pos                9                                          // 栈对齐位
#define SCB_CCR_STKALIGN_Msk               (1ul << SCB_CCR_STKALIGN_Pos)
#define SCB_CCR_BFHFNMIGN_Pos               8                                          // 总线故障、硬件故障和 NMI 忽略位
#define SCB_CCR_BFHFNMIGN_Msk              (1ul << SCB_CCR_BFHFNMIGN_Pos)
#define SCB_CCR_DIV_0_TRP_Pos               4                                          // 除零陷阱位
#define SCB_CCR_DIV_0_TRP_Msk              (1ul << SCB_CCR_DIV_0_TRP_Pos)
#define SCB_CCR_UNALIGN_TRP_Pos             3                                          // 非对齐访问陷阱位
#define SCB_CCR_UNALIGN_TRP_Msk            (1ul << SCB_CCR_UNALIGN_TRP_Pos)
#define SCB_CCR_USERSETMPEND_Pos            1                                          // 用户级设置挂起位
#define SCB_CCR_USERSETMPEND_Msk           (1ul << SCB_CCR_USERSETMPEND_Pos)
#define SCB_CCR_NONBASETHRDENA_Pos          0                                          // 非基级线程使能位
#define SCB_CCR_NONBASETHRDENA_Msk         (1ul << SCB_CCR_NONBASETHRDENA_Pos)

// SCB 系统处理程序控制和状态寄存器定义
#define SCB_SHCSR_USGFAULTENA_Pos          18                                          // 用法故障使能位
#define SCB_SHCSR_USGFAULTENA_Msk          (1ul << SCB_SHCSR_USGFAULTENA_Pos)
#define SCB_SHCSR_BUSFAULTENA_Pos          17                                          // 总线故障使能位
#define SCB_SHCSR_BUSFAULTENA_Msk          (1ul << SCB_SHCSR_BUSFAULTENA_Pos)
#define SCB_SHCSR_MEMFAULTENA_Pos          16                                          // 内存故障使能位
#define SCB_SHCSR_MEMFAULTENA_Msk          (1ul << SCB_SHCSR_MEMFAULTENA_Pos)
#define SCB_SHCSR_SVCALLPENDED_Pos         15                                          // SVC 调用挂起位
#define SCB_SHCSR_SVCALLPENDED_Msk         (1ul << SCB_SHCSR_SVCALLPENDED_Pos)
#define SCB_SHCSR_BUSFAULTPENDED_Pos       14                                          // 总线故障挂起位
#define SCB_SHCSR_BUSFAULTPENDED_Msk       (1ul << SCB_SHCSR_BUSFAULTPENDED_Pos)
#define SCB_SHCSR_MEMFAULTPENDED_Pos       13                                          // 内存故障挂起位
#define SCB_SHCSR_MEMFAULTPENDED_Msk       (1ul << SCB_SHCSR_MEMFAULTPENDED_Pos)
#define SCB_SHCSR_USGFAULTPENDED_Pos       12                                          // 用法故障挂起位
#define SCB_SHCSR_USGFAULTPENDED_Msk       (1ul << SCB_SHCSR_USGFAULTPENDED_Pos)
#define SCB_SHCSR_SYSTICKACT_Pos           11                                          // SysTick 活动位
#define SCB_SHCSR_SYSTICKACT_Msk           (1ul << SCB_SHCSR_SYSTICKACT_Pos)
#define SCB_SHCSR_PENDSVACT_Pos            10                                          // PendSV 活动位
#define SCB_SHCSR_PENDSVACT_Msk            (1ul << SCB_SHCSR_PENDSVACT_Pos)
#define SCB_SHCSR_MONITORACT_Pos            8                                          // 监控活动位
#define SCB_SHCSR_MONITORACT_Msk           (1ul << SCB_SHCSR_MONITORACT_Pos)
#define SCB_SHCSR_SVCALLACT_Pos             7                                          // SVC 调用活动位
#define SCB_SHCSR_SVCALLACT_Msk            (1ul << SCB_SHCSR_SVCALLACT_Pos)
#define SCB_SHCSR_USGFAULTACT_Pos           3                                          // 用法故障活动位
#define SCB_SHCSR_USGFAULTACT_Msk          (1ul << SCB_SHCSR_USGFAULTACT_Pos)
#define SCB_SHCSR_BUSFAULTACT_Pos           1                                          // 总线故障活动位
#define SCB_SHCSR_BUSFAULTACT_Msk          (1ul << SCB_SHCSR_BUSFAULTACT_Pos)
#define SCB_SHCSR_MEMFAULTACT_Pos           0                                          // 内存故障活动位
#define SCB_SHCSR_MEMFAULTACT_Msk          (1ul << SCB_SHCSR_MEMFAULTACT_Pos)

// SCB 可配置故障状态寄存器定义
#define SCB_CFSR_USGFAULTSR_Pos            16                                          // 用法故障状态寄存器
#define SCB_CFSR_USGFAULTSR_Msk            (0xFFFFul << SCB_CFSR_USGFAULTSR_Pos) 
#define SCB_CFSR_BUSFAULTSR_Pos             8                                          // 总线故障状态寄存器
#define SCB_CFSR_BUSFAULTSR_Msk            (0xFFul << SCB_CFSR_BUSFAULTSR_Pos)
#define SCB_CFSR_MEMFAULTSR_Pos             0                                          // 内存管理故障状态寄存器
#define SCB_CFSR_MEMFAULTSR_Msk            (0xFFul << SCB_CFSR_MEMFAULTSR_Pos)

// SCB 硬件故障状态寄存器定义
#define SCB_HFSR_DEBUGEVT_Pos              31                                          // 调试事件位
#define SCB_HFSR_DEBUGEVT_Msk              (1ul << SCB_HFSR_DEBUGEVT_Pos)
#define SCB_HFSR_FORCED_Pos                30                                          // 强制故障位
#define SCB_HFSR_FORCED_Msk                (1ul << SCB_HFSR_FORCED_Pos)
#define SCB_HFSR_VECTTBL_Pos                1                                          // 向量表故障位
#define SCB_HFSR_VECTTBL_Msk               (1ul << SCB_HFSR_VECTTBL_Pos)

// SCB 调试故障状态寄存器定义
#define SCB_DFSR_EXTERNAL_Pos               4                                          // 外部调试请求位
#define SCB_DFSR_EXTERNAL_Msk              (1ul << SCB_DFSR_EXTERNAL_Pos)
#define SCB_DFSR_VCATCH_Pos                 3                                          // 向量捕获位
#define SCB_DFSR_VCATCH_Msk                (1ul << SCB_DFSR_VCATCH_Pos)
#define SCB_DFSR_DWTTRAP_Pos                2                                          // DWT 陷阱位
#define SCB_DFSR_DWTTRAP_Msk               (1ul << SCB_DFSR_DWTTRAP_Pos)
#define SCB_DFSR_BKPT_Pos                   1                                          // 断点位
#define SCB_DFSR_BKPT_Msk                  (1ul << SCB_DFSR_BKPT_Pos)
#define SCB_DFSR_HALTED_Pos                 0                                          // 调试器暂停位
#define SCB_DFSR_HALTED_Msk                (1ul << SCB_DFSR_HALTED_Pos)

/****************************************************************************************************
 *                                  SysTick 定时器的内存映射结构
 ***************************************************************************************************/
typedef struct
{
    __IO uint32_t CTRL;                    // SysTick 控制和状态寄存器  SysTick Control and Status Register
    __IO uint32_t LOAD;                    // SysTick 重载值寄存器      SysTick Reload Value Register
    __IO uint32_t VAL;                     // SysTick 当前值寄存器      SysTick Current Value Register
    __I  uint32_t CALIB;                   // SysTick 校准寄存器        SysTick Calibration Register
} SysTick_Type;

// SysTick 控制/状态寄存器定义
#define SysTick_CTRL_COUNTFLAG_Pos         16                                          // 计数标志位
#define SysTick_CTRL_COUNTFLAG_Msk         (1ul << SysTick_CTRL_COUNTFLAG_Pos)
#define SysTick_CTRL_CLKSOURCE_Pos          2                                          // 时钟源选择位
#define SysTick_CTRL_CLKSOURCE_Msk         (1ul << SysTick_CTRL_CLKSOURCE_Pos)
#define SysTick_CTRL_TICKINT_Pos            1                                          // 中断使能位
#define SysTick_CTRL_TICKINT_Msk           (1ul << SysTick_CTRL_TICKINT_Pos)
#define SysTick_CTRL_ENABLE_Pos             0                                          // 使能位
#define SysTick_CTRL_ENABLE_Msk            (1ul << SysTick_CTRL_ENABLE_Pos)

// SysTick 重载寄存器定义
#define SysTick_LOAD_RELOAD_Pos             0                                          // 重载值
#define SysTick_LOAD_RELOAD_Msk            (0xFFFFFFul << SysTick_LOAD_RELOAD_Pos)

// SysTick 当前值寄存器定义
#define SysTick_VAL_CURRENT_Pos             0                                          // 当前值
#define SysTick_VAL_CURRENT_Msk            (0xFFFFFFul << SysTick_VAL_CURRENT_Pos)

// SysTick 校准寄存器定义
#define SysTick_CALIB_NOREF_Pos            31                                          // 无参考时钟位
#define SysTick_CALIB_NOREF_Msk            (1ul << SysTick_CALIB_NOREF_Pos)
#define SysTick_CALIB_SKEW_Pos             30                                          // 校准值偏斜位
#define SysTick_CALIB_SKEW_Msk             (1ul << SysTick_CALIB_SKEW_Pos)
#define SysTick_CALIB_TENMS_Pos             0                                          // 10ms 校准值
#define SysTick_CALIB_TENMS_Msk            (0xFFFFFFul << SysTick_VAL_CURRENT_Pos)

/****************************************************************************************************
 *                      仪器化跟踪宏单元 (ITM) 的内存映射结构（用途：调试和跟踪）
 ***************************************************************************************************/
typedef struct
{
    __O  union  
    {
        __O  uint8_t    u8;
        __O  uint16_t   u16;
        __O  uint32_t   u32;
    }  PORT [32];
         uint32_t RESERVED0[864];
    __IO uint32_t TER;
         uint32_t RESERVED1[15];
    __IO uint32_t TPR;
         uint32_t RESERVED2[15];
    __IO uint32_t TCR;
         uint32_t RESERVED3[29];
    __IO uint32_t IWR;
    __IO uint32_t IRR;
    __IO uint32_t IMCR;
         uint32_t RESERVED4[43];
    __IO uint32_t LAR;
    __IO uint32_t LSR;
         uint32_t RESERVED5[6];
    __I  uint32_t PID4;
    __I  uint32_t PID5;
    __I  uint32_t PID6;
    __I  uint32_t PID7;
    __I  uint32_t PID0;
    __I  uint32_t PID1;
    __I  uint32_t PID2;
    __I  uint32_t PID3;
    __I  uint32_t CID0;
    __I  uint32_t CID1;
    __I  uint32_t CID2;
    __I  uint32_t CID3;
} ITM_Type;

// 跟踪特权寄存器定义
#define ITM_TPR_PRIVMASK_Pos                0
#define ITM_TPR_PRIVMASK_Msk               (0xFul << ITM_TPR_PRIVMASK_Pos)

// 跟踪控制寄存器定义
#define ITM_TCR_BUSY_Pos                   23
#define ITM_TCR_BUSY_Msk                   (1ul << ITM_TCR_BUSY_Pos)
#define ITM_TCR_ATBID_Pos                  16
#define ITM_TCR_ATBID_Msk                  (0x7Ful << ITM_TCR_ATBID_Pos)
#define ITM_TCR_TSPrescale_Pos              8
#define ITM_TCR_TSPrescale_Msk             (3ul << ITM_TCR_TSPrescale_Pos)
#define ITM_TCR_SWOENA_Pos                  4
#define ITM_TCR_SWOENA_Msk                 (1ul << ITM_TCR_SWOENA_Pos)
#define ITM_TCR_DWTENA_Pos                  3
#define ITM_TCR_DWTENA_Msk                 (1ul << ITM_TCR_DWTENA_Pos)
#define ITM_TCR_SYNCENA_Pos                 2
#define ITM_TCR_SYNCENA_Msk                (1ul << ITM_TCR_SYNCENA_Pos)
#define ITM_TCR_TSENA_Pos                   1
#define ITM_TCR_TSENA_Msk                  (1ul << ITM_TCR_TSENA_Pos)
#define ITM_TCR_ITMENA_Pos                  0
#define ITM_TCR_ITMENA_Msk                 (1ul << ITM_TCR_ITMENA_Pos)

// 集成写寄存器定义
#define ITM_IWR_ATVALIDM_Pos                0
#define ITM_IWR_ATVALIDM_Msk               (1ul << ITM_IWR_ATVALIDM_Pos)

// 集成读寄存器定义
#define ITM_IRR_ATREADYM_Pos                0
#define ITM_IRR_ATREADYM_Msk               (1ul << ITM_IRR_ATREADYM_Pos)

// 集成模式控制寄存器定义
#define ITM_IMCR_INTEGRATION_Pos            0
#define ITM_IMCR_INTEGRATION_Msk           (1ul << ITM_IMCR_INTEGRATION_Pos)

// 锁状态寄存器定义
#define ITM_LSR_ByteAcc_Pos                 2
#define ITM_LSR_ByteAcc_Msk                (1ul << ITM_LSR_ByteAcc_Pos)
#define ITM_LSR_Access_Pos                  1
#define ITM_LSR_Access_Msk                 (1ul << ITM_LSR_Access_Pos)
#define ITM_LSR_Present_Pos                 0
#define ITM_LSR_Present_Msk                (1ul << ITM_LSR_Present_Pos)

/****************************************************************************************************
 *               中断类型的的内存映射结构: memory mapped structure for Interrupt Type
 ***************************************************************************************************/
typedef struct
{
       uint32_t RESERVED0;
  __I  uint32_t ICTR;                      // 中断控制类型寄存器  Interrupt Control Type Register
#if ((defined __CM3_REV) && (__CM3_REV >= 0x200))
  __IO uint32_t ACTLR;                     // 辅助控制寄存器  Auxiliary Control Register
#else
       uint32_t RESERVED1;
#endif
} InterruptType_Type;

// 中断控制器类型寄存器定义
#define InterruptType_ICTR_INTLINESNUM_Pos  0                                             // 中断线数量
#define InterruptType_ICTR_INTLINESNUM_Msk (0x1Ful << InterruptType_ICTR_INTLINESNUM_Pos)

// 辅助控制寄存器定义
#define InterruptType_ACTLR_DISFOLD_Pos     2                                             // 禁止重叠位
#define InterruptType_ACTLR_DISFOLD_Msk    (1ul << InterruptType_ACTLR_DISFOLD_Pos)
#define InterruptType_ACTLR_DISDEFWBUF_Pos  1                                             // 禁止默认写缓冲区位
#define InterruptType_ACTLR_DISDEFWBUF_Msk (1ul << InterruptType_ACTLR_DISDEFWBUF_Pos)
#define InterruptType_ACTLR_DISMCYCINT_Pos  0                                             // 禁止多周期中断位
#define InterruptType_ACTLR_DISMCYCINT_Msk (1ul << InterruptType_ACTLR_DISMCYCINT_Pos)


// __MPU_PRESENT 在 stm32f10x.h 中定义
#if defined (__MPU_PRESENT) && (__MPU_PRESENT == 1)
/****************************************************************************************************
 *                              内存保护单元 (MPU) 的内存映射结构
 ***************************************************************************************************/
typedef struct
{
  __I  uint32_t TYPE;                      // 偏移: 0x00 类型寄存器                MPU Type Register
  __IO uint32_t CTRL;                      // 偏移: 0x04 控制寄存器                MPU Control Register
  __IO uint32_t RNR;                       // 偏移: 0x08 区域编号寄存器            MPU Region RNRber Register
  __IO uint32_t RBAR;                      // 偏移: 0x0C 区域基地址寄存器          MPU Region Base Address Register
  __IO uint32_t RASR;                      // 偏移: 0x10 区域属性和大小寄存器      MPU Region Attribute and Size Register
  __IO uint32_t RBAR_A1;                   // 偏移: 0x14 别名1区域基地址寄存器     MPU Alias 1 Region Base Address Register
  __IO uint32_t RASR_A1;                   // 偏移: 0x18 别名1区域属性和大小寄存器 MPU Alias 1 Region Attribute and Size Register
  __IO uint32_t RBAR_A2;                   // 偏移: 0x1C 别名2区域基地址寄存器     MPU Alias 2 Region Base Address Register
  __IO uint32_t RASR_A2;                   // 偏移: 0x20 别名2区域属性和大小寄存器 MPU Alias 2 Region Attribute and Size Register
  __IO uint32_t RBAR_A3;                   // 偏移: 0x24 别名3区域基地址寄存器     MPU Alias 3 Region Base Address Register
  __IO uint32_t RASR_A3;                   // 偏移: 0x28 别名3区域属性和大小寄存器 MPU Alias 3 Region Attribute and Size Register
} MPU_Type;                                                

// MPU Type Register
#define MPU_TYPE_IREGION_Pos               16                                             // IREGION Position
#define MPU_TYPE_IREGION_Msk               (0xFFul << MPU_TYPE_IREGION_Pos)
#define MPU_TYPE_DREGION_Pos                8                                             // DREGION Position
#define MPU_TYPE_DREGION_Msk               (0xFFul << MPU_TYPE_DREGION_Pos)
#define MPU_TYPE_SEPARATE_Pos               0                                             // SEPARATE Position
#define MPU_TYPE_SEPARATE_Msk              (1ul << MPU_TYPE_SEPARATE_Pos)

// MPU Control Register
#define MPU_CTRL_PRIVDEFENA_Pos             2                                             // PRIVDEFENA Position
#define MPU_CTRL_PRIVDEFENA_Msk            (1ul << MPU_CTRL_PRIVDEFENA_Pos)
#define MPU_CTRL_HFNMIENA_Pos               1                                             // HFNMIENA Position
#define MPU_CTRL_HFNMIENA_Msk              (1ul << MPU_CTRL_HFNMIENA_Pos)
#define MPU_CTRL_ENABLE_Pos                 0                                             // ENABLE Position
#define MPU_CTRL_ENABLE_Msk                (1ul << MPU_CTRL_ENABLE_Pos)

// MPU Region Number Register
#define MPU_RNR_REGION_Pos                  0                                             // REGION Position
#define MPU_RNR_REGION_Msk                 (0xFFul << MPU_RNR_REGION_Pos)

// MPU Region Base Address Register
#define MPU_RBAR_ADDR_Pos                   5                                             // ADDR Position
#define MPU_RBAR_ADDR_Msk                  (0x7FFFFFFul << MPU_RBAR_ADDR_Pos)
#define MPU_RBAR_VALID_Pos                  4                                             // VALID Position
#define MPU_RBAR_VALID_Msk                 (1ul << MPU_RBAR_VALID_Pos) 
#define MPU_RBAR_REGION_Pos                 0                                             // REGION Position
#define MPU_RBAR_REGION_Msk                (0xFul << MPU_RBAR_REGION_Pos)

// MPU Region Attribute and Size Register
#define MPU_RASR_XN_Pos                    28                                             // XN Position
#define MPU_RASR_XN_Msk                    (1ul << MPU_RASR_XN_Pos) 
#define MPU_RASR_AP_Pos                    24                                             // AP Position
#define MPU_RASR_AP_Msk                    (7ul << MPU_RASR_AP_Pos)
#define MPU_RASR_TEX_Pos                   19                                             // TEX Position
#define MPU_RASR_TEX_Msk                   (7ul << MPU_RASR_TEX_Pos)
#define MPU_RASR_S_Pos                     18                                             // Shareable bit Position
#define MPU_RASR_S_Msk                     (1ul << MPU_RASR_S_Pos)
#define MPU_RASR_C_Pos                     17                                             // Cacheable bit Position
#define MPU_RASR_C_Msk                     (1ul << MPU_RASR_C_Pos)
#define MPU_RASR_B_Pos                     16                                             // Bufferable bit Position
#define MPU_RASR_B_Msk                     (1ul << MPU_RASR_B_Pos)
#define MPU_RASR_SRD_Pos                    8                                             // Sub-Region Disable Position
#define MPU_RASR_SRD_Msk                   (0xFFul << MPU_RASR_SRD_Pos)
#define MPU_RASR_SIZE_Pos                   1                                             // Region Size Field Position
#define MPU_RASR_SIZE_Msk                  (0x1Ful << MPU_RASR_SIZE_Pos)
#define MPU_RASR_ENA_Pos                    0                                             // Region enable bit Position
#define MPU_RASR_ENA_Msk                   (0x1Ful << MPU_RASR_ENA_Pos)

#endif


/****************************************************************************************************
 *                              核心调试寄存器的内存映射结构
 ***************************************************************************************************/
typedef struct
{
    __IO uint32_t DHCSR;                   // Offset: 0x00  Debug Halting Control and Status Register
    __O  uint32_t DCRSR;                   // Offset: 0x04  Debug Core Register Selector Register
    __IO uint32_t DCRDR;                   // Offset: 0x08  Debug Core Register Data Register
    __IO uint32_t DEMCR;                   // Offset: 0x0C  Debug Exception and Monitor Control Register
} CoreDebug_Type;

// Debug Halting Control and Status Register
#define CoreDebug_DHCSR_DBGKEY_Pos         16                                             // CoreDebug DHCSR: DBGKEY Position
#define CoreDebug_DHCSR_DBGKEY_Msk         (0xFFFFul << CoreDebug_DHCSR_DBGKEY_Pos)       // CoreDebug DHCSR: DBGKEY Mask
#define CoreDebug_DHCSR_S_RESET_ST_Pos     25                                             // CoreDebug DHCSR: S_RESET_ST Position
#define CoreDebug_DHCSR_S_RESET_ST_Msk     (1ul << CoreDebug_DHCSR_S_RESET_ST_Pos)        // CoreDebug DHCSR: S_RESET_ST Mask
#define CoreDebug_DHCSR_S_RETIRE_ST_Pos    24                                             // CoreDebug DHCSR: S_RETIRE_ST Position
#define CoreDebug_DHCSR_S_RETIRE_ST_Msk    (1ul << CoreDebug_DHCSR_S_RETIRE_ST_Pos)       // CoreDebug DHCSR: S_RETIRE_ST Mask
#define CoreDebug_DHCSR_S_LOCKUP_Pos       19                                             // CoreDebug DHCSR: S_LOCKUP Position
#define CoreDebug_DHCSR_S_LOCKUP_Msk       (1ul << CoreDebug_DHCSR_S_LOCKUP_Pos)          // CoreDebug DHCSR: S_LOCKUP Mask
#define CoreDebug_DHCSR_S_SLEEP_Pos        18                                             // CoreDebug DHCSR: S_SLEEP Position
#define CoreDebug_DHCSR_S_SLEEP_Msk        (1ul << CoreDebug_DHCSR_S_SLEEP_Pos)           // CoreDebug DHCSR: S_SLEEP Mask
#define CoreDebug_DHCSR_S_HALT_Pos         17                                             // CoreDebug DHCSR: S_HALT Position
#define CoreDebug_DHCSR_S_HALT_Msk         (1ul << CoreDebug_DHCSR_S_HALT_Pos)            // CoreDebug DHCSR: S_HALT Mask
#define CoreDebug_DHCSR_S_REGRDY_Pos       16                                             // CoreDebug DHCSR: S_REGRDY Position
#define CoreDebug_DHCSR_S_REGRDY_Msk       (1ul << CoreDebug_DHCSR_S_REGRDY_Pos)          // CoreDebug DHCSR: S_REGRDY Mask
#define CoreDebug_DHCSR_C_SNAPSTALL_Pos     5                                             // CoreDebug DHCSR: C_SNAPSTALL Position
#define CoreDebug_DHCSR_C_SNAPSTALL_Msk    (1ul << CoreDebug_DHCSR_C_SNAPSTALL_Pos)       // CoreDebug DHCSR: C_SNAPSTALL Mask
#define CoreDebug_DHCSR_C_MASKINTS_Pos      3                                             // CoreDebug DHCSR: C_MASKINTS Position
#define CoreDebug_DHCSR_C_MASKINTS_Msk     (1ul << CoreDebug_DHCSR_C_MASKINTS_Pos)        // CoreDebug DHCSR: C_MASKINTS Mask
#define CoreDebug_DHCSR_C_STEP_Pos          2                                             // CoreDebug DHCSR: C_STEP Position
#define CoreDebug_DHCSR_C_STEP_Msk         (1ul << CoreDebug_DHCSR_C_STEP_Pos)            // CoreDebug DHCSR: C_STEP Mask
#define CoreDebug_DHCSR_C_HALT_Pos          1                                             // CoreDebug DHCSR: C_HALT Position
#define CoreDebug_DHCSR_C_HALT_Msk         (1ul << CoreDebug_DHCSR_C_HALT_Pos)            // CoreDebug DHCSR: C_HALT Mask
#define CoreDebug_DHCSR_C_DEBUGEN_Pos       0                                             // CoreDebug DHCSR: C_DEBUGEN Position
#define CoreDebug_DHCSR_C_DEBUGEN_Msk      (1ul << CoreDebug_DHCSR_C_DEBUGEN_Pos)         // CoreDebug DHCSR: C_DEBUGEN Mask

// Debug Core Register Selector Register
#define CoreDebug_DCRSR_REGWnR_Pos         16                                             // CoreDebug DCRSR: REGWnR Position
#define CoreDebug_DCRSR_REGWnR_Msk         (1ul << CoreDebug_DCRSR_REGWnR_Pos)            // CoreDebug DCRSR: REGWnR Mask
#define CoreDebug_DCRSR_REGSEL_Pos          0                                             // CoreDebug DCRSR: REGSEL Position
#define CoreDebug_DCRSR_REGSEL_Msk         (0x1Ful << CoreDebug_DCRSR_REGSEL_Pos)         // CoreDebug DCRSR: REGSEL Mask

// Debug Exception and Monitor Control Register
#define CoreDebug_DEMCR_TRCENA_Pos         24                                             // CoreDebug DEMCR: TRCENA Position
#define CoreDebug_DEMCR_TRCENA_Msk         (1ul << CoreDebug_DEMCR_TRCENA_Pos)            // CoreDebug DEMCR: TRCENA Mask
#define CoreDebug_DEMCR_MON_REQ_Pos        19                                             // CoreDebug DEMCR: MON_REQ Position
#define CoreDebug_DEMCR_MON_REQ_Msk        (1ul << CoreDebug_DEMCR_MON_REQ_Pos)           // CoreDebug DEMCR: MON_REQ Mask
#define CoreDebug_DEMCR_MON_STEP_Pos       18                                             // CoreDebug DEMCR: MON_STEP Position
#define CoreDebug_DEMCR_MON_STEP_Msk       (1ul << CoreDebug_DEMCR_MON_STEP_Pos)          // CoreDebug DEMCR: MON_STEP Mask
#define CoreDebug_DEMCR_MON_PEND_Pos       17                                             // CoreDebug DEMCR: MON_PEND Position
#define CoreDebug_DEMCR_MON_PEND_Msk       (1ul << CoreDebug_DEMCR_MON_PEND_Pos)          // CoreDebug DEMCR: MON_PEND Mask
#define CoreDebug_DEMCR_MON_EN_Pos         16                                             // CoreDebug DEMCR: MON_EN Position
#define CoreDebug_DEMCR_MON_EN_Msk         (1ul << CoreDebug_DEMCR_MON_EN_Pos)            // CoreDebug DEMCR: MON_EN Mask
#define CoreDebug_DEMCR_VC_HARDERR_Pos     10                                             // CoreDebug DEMCR: VC_HARDERR Position
#define CoreDebug_DEMCR_VC_HARDERR_Msk     (1ul << CoreDebug_DEMCR_VC_HARDERR_Pos)        // CoreDebug DEMCR: VC_HARDERR Mask
#define CoreDebug_DEMCR_VC_INTERR_Pos       9                                             // CoreDebug DEMCR: VC_INTERR Position
#define CoreDebug_DEMCR_VC_INTERR_Msk      (1ul << CoreDebug_DEMCR_VC_INTERR_Pos)         // CoreDebug DEMCR: VC_INTERR Mask
#define CoreDebug_DEMCR_VC_BUSERR_Pos       8                                             // CoreDebug DEMCR: VC_BUSERR Position
#define CoreDebug_DEMCR_VC_BUSERR_Msk      (1ul << CoreDebug_DEMCR_VC_BUSERR_Pos)         // CoreDebug DEMCR: VC_BUSERR Mask
#define CoreDebug_DEMCR_VC_STATERR_Pos      7                                             // CoreDebug DEMCR: VC_STATERR Position
#define CoreDebug_DEMCR_VC_STATERR_Msk     (1ul << CoreDebug_DEMCR_VC_STATERR_Pos)        // CoreDebug DEMCR: VC_STATERR Mask
#define CoreDebug_DEMCR_VC_CHKERR_Pos       6                                             // CoreDebug DEMCR: VC_CHKERR Position
#define CoreDebug_DEMCR_VC_CHKERR_Msk      (1ul << CoreDebug_DEMCR_VC_CHKERR_Pos)         // CoreDebug DEMCR: VC_CHKERR Mask
#define CoreDebug_DEMCR_VC_NOCPERR_Pos      5                                             // CoreDebug DEMCR: VC_NOCPERR Position
#define CoreDebug_DEMCR_VC_NOCPERR_Msk     (1ul << CoreDebug_DEMCR_VC_NOCPERR_Pos)        // CoreDebug DEMCR: VC_NOCPERR Mask
#define CoreDebug_DEMCR_VC_MMERR_Pos        4                                             // CoreDebug DEMCR: VC_MMERR Position
#define CoreDebug_DEMCR_VC_MMERR_Msk       (1ul << CoreDebug_DEMCR_VC_MMERR_Pos)          // CoreDebug DEMCR: VC_MMERR Mask
#define CoreDebug_DEMCR_VC_CORERESET_Pos    0                                             // CoreDebug DEMCR: VC_CORERESET Position
#define CoreDebug_DEMCR_VC_CORERESET_Msk   (1ul << CoreDebug_DEMCR_VC_CORERESET_Pos)      // CoreDebug DEMCR: VC_CORERESET Mask


// Cortex-M3 硬件的内存映射
#define SCS_BASE            (0xE000E000)                              // System Control Space Base Address
#define ITM_BASE            (0xE0000000)                              // ITM Base Address
#define CoreDebug_BASE      (0xE000EDF0)                              // Core Debug Base Address
#define SysTick_BASE        (SCS_BASE +  0x0010)                      // SysTick Base Address
#define NVIC_BASE           (SCS_BASE +  0x0100)                      // NVIC Base Address
#define SCB_BASE            (SCS_BASE +  0x0D00)                      // System Control Block Base Address

#define InterruptType       ((InterruptType_Type *) SCS_BASE)         // Interrupt Type Register
#define SCB                 ((SCB_Type *)           SCB_BASE)         // SCB configuration struct
#define SysTick             ((SysTick_Type *)       SysTick_BASE)     // SysTick configuration struct
#define NVIC                ((NVIC_Type *)          NVIC_BASE)        // NVIC configuration struct
#define ITM                 ((ITM_Type *)           ITM_BASE)         // ITM configuration struct
#define CoreDebug           ((CoreDebug_Type *)     CoreDebug_BASE)   // Core Debug configuration struct

#if defined (__MPU_PRESENT) && (__MPU_PRESENT == 1)
  #define MPU_BASE          (SCS_BASE +  0x0D90)                      // Memory Protection Unit
  #define MPU               ((MPU_Type*)            MPU_BASE)         // Memory Protection Unit
#endif


/****************************************************************************************************
 *                                          硬件抽象层
 ***************************************************************************************************/
#if defined ( __CC_ARM   )
  #define __ASM            __asm                                      // asm keyword for ARM Compiler
  #define __INLINE         __inline                                   // inline keyword for ARM Compiler

#elif defined ( __ICCARM__ )
  #define __ASM           __asm                                       // asm keyword for IAR Compiler
  #define __INLINE        inline                                      // inline keyword for IAR Compiler. Only avaiable in High optimization mode!

#elif defined   (  __GNUC__  )
  #define __ASM            __asm                                      // asm keyword for GNU Compiler
  #define __INLINE         inline                                     // inline keyword for GNU Compiler

#elif defined   (  __TASKING__  )
  #define __ASM            __asm                                      // asm keyword for TASKING Compiler
  #define __INLINE         inline                                     // inline keyword for TASKING Compiler

#endif


/****************************************************************************************************
 *                                      编译器特定的内置函数
 ***************************************************************************************************/
#if defined ( __CC_ARM   )    // RealView Compiler

// ARM armcc specific functions
#define __enable_fault_irq                __enable_fiq
#define __disable_fault_irq               __disable_fiq

#define __NOP                             __nop
#define __WFI                             __wfi
#define __WFE                             __wfe
#define __SEV                             __sev
#define __ISB()                           __isb(0)
#define __DSB()                           __dsb(0)
#define __DMB()                           __dmb(0)
#define __REV                             __rev
#define __RBIT                            __rbit
#define __LDREXB(ptr)                     ((unsigned char ) __ldrex(ptr))
#define __LDREXH(ptr)                     ((unsigned short) __ldrex(ptr))
#define __LDREXW(ptr)                     ((unsigned int  ) __ldrex(ptr))
#define __STREXB(value, ptr)              __strex(value, ptr)
#define __STREXH(value, ptr)              __strex(value, ptr)
#define __STREXW(value, ptr)              __strex(value, ptr)

extern uint32_t __get_PSP(void);                       // 返回进程栈指针
extern void     __set_PSP(uint32_t topOfProcStack);A   // 设置进程栈指针
extern uint32_t __get_MSP(void);                       // 返回主栈指针
extern void     __set_MSP(uint32_t topOfMainStack);    // 设置主栈指针
extern uint32_t __REV16(uint16_t value);               // 反转半字中的字节
extern int32_t  __REVSH(int16_t value);                // 反转低半字中的字节，并将结果有符号展开

#if (__ARMCC_VERSION < 400000)

extern void     __CLREX(void);
extern uint32_t __get_BASEPRI(void);
extern void     __set_BASEPRI(uint32_t basePri);
extern uint32_t __get_PRIMASK(void);
extern void     __set_PRIMASK(uint32_t priMask);
extern uint32_t __get_FAULTMASK(void);
extern void     __set_FAULTMASK(uint32_t faultMask);
extern uint32_t __get_CONTROL(void);
extern void     __set_CONTROL(uint32_t control);

#else

#define __CLREX                           __clrex

static __INLINE uint32_t  __get_BASEPRI(void)
{
  register uint32_t __regBasePri         __ASM("basepri");
  return(__regBasePri);
}

static __INLINE void __set_BASEPRI(uint32_t basePri)
{
  register uint32_t __regBasePri         __ASM("basepri");
  __regBasePri = (basePri & 0xff);
}

static __INLINE uint32_t __get_PRIMASK(void)
{
  register uint32_t __regPriMask         __ASM("primask");
  return(__regPriMask);
}

static __INLINE void __set_PRIMASK(uint32_t priMask)
{
  register uint32_t __regPriMask         __ASM("primask");
  __regPriMask = (priMask);
}

static __INLINE uint32_t __get_FAULTMASK(void)
{
  register uint32_t __regFaultMask       __ASM("faultmask");
  return(__regFaultMask);
}

static __INLINE void __set_FAULTMASK(uint32_t faultMask)
{
  register uint32_t __regFaultMask       __ASM("faultmask");
  __regFaultMask = (faultMask & 1);
}

static __INLINE uint32_t __get_CONTROL(void)
{
  register uint32_t __regControl         __ASM("control");
  return(__regControl);
}

static __INLINE void __set_CONTROL(uint32_t control)
{
  register uint32_t __regControl         __ASM("control");
  __regControl = control;
}

#endif

// ICC Compiler
#elif (defined (__ICCARM__))

#define __enable_irq                              __enable_interrupt
#define __disable_irq                             __disable_interrupt

static __INLINE void __enable_fault_irq()         { __ASM ("cpsie f"); }
static __INLINE void __disable_fault_irq()        { __ASM ("cpsid f"); }

#define __NOP                                     __no_operation
static __INLINE  void __WFI()                     { __ASM ("wfi"); }
static __INLINE  void __WFE()                     { __ASM ("wfe"); }
static __INLINE  void __SEV()                     { __ASM ("sev"); }
static __INLINE  void __CLREX()                   { __ASM ("clrex"); }

extern uint32_t __get_PSP(void);
extern void     __set_PSP(uint32_t topOfProcStack);
extern uint32_t __get_MSP(void);
extern void     __set_MSP(uint32_t topOfMainStack);
extern uint32_t __REV16(uint16_t value);
extern uint32_t __RBIT(uint32_t value);
extern uint8_t  __LDREXB(uint8_t *addr);
extern uint16_t __LDREXH(uint16_t *addr);
extern uint32_t __LDREXW(uint32_t *addr);
extern uint32_t __STREXB(uint8_t value, uint8_t *addr);
extern uint32_t __STREXH(uint16_t value, uint16_t *addr);
extern uint32_t __STREXW(uint32_t value, uint32_t *addr);


// GNU Compiler
#elif (defined (__GNUC__))

static __INLINE void __enable_irq()               { __ASM volatile ("cpsie i"); }
static __INLINE void __disable_irq()              { __ASM volatile ("cpsid i"); }

static __INLINE void __enable_fault_irq()         { __ASM volatile ("cpsie f"); }
static __INLINE void __disable_fault_irq()        { __ASM volatile ("cpsid f"); }

static __INLINE void __NOP()                      { __ASM volatile ("nop"); }
static __INLINE void __WFI()                      { __ASM volatile ("wfi"); }
static __INLINE void __WFE()                      { __ASM volatile ("wfe"); }
static __INLINE void __SEV()                      { __ASM volatile ("sev"); }
static __INLINE void __ISB()                      { __ASM volatile ("isb"); }
static __INLINE void __DSB()                      { __ASM volatile ("dsb"); }
static __INLINE void __DMB()                      { __ASM volatile ("dmb"); }
static __INLINE void __CLREX()                    { __ASM volatile ("clrex"); }

extern uint32_t __get_PSP(void);
extern void     __set_PSP(uint32_t topOfProcStack);
extern uint32_t __get_MSP(void);
extern void     __set_MSP(uint32_t topOfMainStack);
extern uint32_t __get_BASEPRI(void);
extern void     __set_BASEPRI(uint32_t basePri);
extern uint32_t __get_PRIMASK(void);
extern void     __set_PRIMASK(uint32_t priMask);
extern uint32_t __get_FAULTMASK(void);
extern void     __set_FAULTMASK(uint32_t faultMask);
extern uint32_t __get_CONTROL(void);
extern void     __set_CONTROL(uint32_t control);
extern uint32_t __REV(uint32_t value);
extern uint32_t __REV16(uint16_t value);
extern int32_t  __REVSH(int16_t value);
extern uint32_t __RBIT(uint32_t value);
extern uint8_t  __LDREXB(uint8_t *addr);
extern uint16_t __LDREXH(uint16_t *addr);
extern uint32_t __LDREXW(uint32_t *addr);
extern uint32_t __STREXB(uint8_t value, uint8_t *addr);
extern uint32_t __STREXH(uint16_t value, uint16_t *addr);
extern uint32_t __STREXW(uint32_t value, uint32_t *addr);


// TASKING Compiler
#elif (defined (__TASKING__))

// CMSIS 函数已在编译器中实现为内置函数

#endif


/* ##################################    NVIC 函数  ############################################ */
// 设置优先级分组
static __INLINE void NVIC_SetPriorityGrouping(uint32_t PriorityGroup)
{
  uint32_t reg_value;
  uint32_t PriorityGroupTmp = (PriorityGroup & 0x07);             // 只取后 3 位，即 0 - 7
  
  reg_value  =  SCB->AIRCR;                                       // 读取旧的寄存器配置
  reg_value &= ~(SCB_AIRCR_VECTKEY_Msk | SCB_AIRCR_PRIGROUP_Msk); // 清除对应位
  reg_value  =  (reg_value                       |
                (0x5FA << SCB_AIRCR_VECTKEY_Pos) |                // [31:16], 写入 AIRCR 寄存器时必须要将 0x5FA 写入 VECTKEY，否则写入会被忽略
                (PriorityGroupTmp << 8));                         // [10:8], 优先级分组
  SCB->AIRCR =  reg_value;
}

// 获取优先级分组
static __INLINE uint32_t NVIC_GetPriorityGrouping(void)
{
  return ((SCB->AIRCR & SCB_AIRCR_PRIGROUP_Msk) >> SCB_AIRCR_PRIGROUP_Pos);
}

// 启用外部中断
static __INLINE void NVIC_EnableIRQ(IRQn_Type IRQn)
{
  NVIC->ISER[((uint32_t)(IRQn) >> 5)] = (1 << ((uint32_t)(IRQn) & 0x1F));  // ISER[0] 每一位对应 0 ~ 31 中断
}

// 禁用外部中断
static __INLINE void NVIC_DisableIRQ(IRQn_Type IRQn)
{
  NVIC->ICER[((uint32_t)(IRQn) >> 5)] = (1 << ((uint32_t)(IRQn) & 0x1F));
}

// 获取外部中断的挂起位
static __INLINE uint32_t NVIC_GetPendingIRQ(IRQn_Type IRQn)
{
  return((uint32_t) ((  NVIC->ISPR[(uint32_t)(IRQn) >> 5] & (1 << ((uint32_t)(IRQn) & 0x1F))  )?1:0));
}

// 设置外部中断的挂起位
static __INLINE void NVIC_SetPendingIRQ(IRQn_Type IRQn)
{
  NVIC->ISPR[((uint32_t)(IRQn) >> 5)] = (1 << ((uint32_t)(IRQn) & 0x1F));
}

// 清除外部中断的挂起位
static __INLINE void NVIC_ClearPendingIRQ(IRQn_Type IRQn)
{
  NVIC->ICPR[((uint32_t)(IRQn) >> 5)] = (1 << ((uint32_t)(IRQn) & 0x1F));
}

// 读取外部中断的活动位 (1: 中断程序运行, 0: 未运行)
static __INLINE uint32_t NVIC_GetActive(IRQn_Type IRQn)
{
  return((uint32_t)((NVIC->IABR[(uint32_t)(IRQn) >> 5] & (1 << ((uint32_t)(IRQn) & 0x1F)))?1:0));
}

// 设置中断的优先级
static __INLINE void NVIC_SetPriority(IRQn_Type IRQn, uint32_t priority)
{
  if(IRQn < 0) { 
    // 系统中断，SHP[0] ~ SHP[11] 对应 -14 ~ -1 中断号
    SCB->SHP[((uint32_t)(IRQn) & 0xF)-4] = ((priority << (8 - __NVIC_PRIO_BITS)) & 0xff); }
  else {
    // 外部中断，IP[0] (8位) 对应中断 0 
    NVIC->IP[(uint32_t)(IRQn)] = ((priority << (8 - __NVIC_PRIO_BITS)) & 0xff);    }
}

// 读取中断的优先级
static __INLINE uint32_t NVIC_GetPriority(IRQn_Type IRQn)
{

  if(IRQn < 0) {
    return((uint32_t)(SCB->SHP[((uint32_t)(IRQn) & 0xF)-4] >> (8 - __NVIC_PRIO_BITS)));  }
  else {
    return((uint32_t)(NVIC->IP[(uint32_t)(IRQn)]           >> (8 - __NVIC_PRIO_BITS)));  }
}


// 中断的优先级编码
static __INLINE uint32_t NVIC_EncodePriority (uint32_t PriorityGroup, uint32_t PreemptPriority, uint32_t SubPriority)
{
  uint32_t PriorityGroupTmp = (PriorityGroup & 0x07);  // 优先级分组，3 位
  uint32_t PreemptPriorityBits; // 主优先级
  uint32_t SubPriorityBits;  // 子优先级

  PreemptPriorityBits = ((7 - PriorityGroupTmp) > __NVIC_PRIO_BITS) ? __NVIC_PRIO_BITS : 7 - PriorityGroupTmp;
  SubPriorityBits     = ((PriorityGroupTmp + __NVIC_PRIO_BITS) < 7) ? 0 : PriorityGroupTmp - 7 + __NVIC_PRIO_BITS;
 
  return (
           ((PreemptPriority & ((1 << (PreemptPriorityBits)) - 1)) << SubPriorityBits) |
           ((SubPriority     & ((1 << (SubPriorityBits    )) - 1)))
         );
}

/*          优先级分组 = 5，
                ↓
| bit 7 | bit 6 | bit 5 | bit 4 | bit 3 | bit 2 | bit 1 | bit 0 |
                                ↑
	                   __NVIC_PRIO_BITS = 4，高 4 位有效
[7:6] -> 主优先级，共 2 位（0-3）
[5:4] -> 子优先级，共 2 位（0-3）                                   */

// 中断的优先级解码，Priority 参数是中断优先级
static __INLINE void NVIC_DecodePriority (uint32_t Priority, uint32_t PriorityGroup, uint32_t* pPreemptPriority, uint32_t* pSubPriority)
{
  uint32_t PriorityGroupTmp = (PriorityGroup & 0x07); 
  uint32_t PreemptPriorityBits;
  uint32_t SubPriorityBits;

  PreemptPriorityBits = ((7 - PriorityGroupTmp) > __NVIC_PRIO_BITS) ? __NVIC_PRIO_BITS : 7 - PriorityGroupTmp;
  SubPriorityBits     = ((PriorityGroupTmp + __NVIC_PRIO_BITS) < 7) ? 0 : PriorityGroupTmp - 7 + __NVIC_PRIO_BITS;
  
  *pPreemptPriority = (Priority >> SubPriorityBits) & ((1 << (PreemptPriorityBits)) - 1);
  *pSubPriority     = (Priority                   ) & ((1 << (SubPriorityBits    )) - 1);
}


/* ##################################    SysTick 函数  ############################################ */
#if (!defined (__Vendor_SysTickConfig)) || (__Vendor_SysTickConfig == 0)

// 初始化和启动 SysTick 计数器及其中断
static __INLINE uint32_t SysTick_Config(uint32_t ticks)
{ 
  if (ticks > SysTick_LOAD_RELOAD_Msk)  return (1);            // 重载值超出范围
                                                               
  SysTick->LOAD  = (ticks & SysTick_LOAD_RELOAD_Msk) - 1;      // 设置重载寄存器
  NVIC_SetPriority (SysTick_IRQn, (1<<__NVIC_PRIO_BITS) - 1);  // 为 Cortex-M0 系统中断设置优先级
  SysTick->VAL   = 0;                                          // 加载 SysTick 计数器值
  SysTick->CTRL  = SysTick_CTRL_CLKSOURCE_Msk | 
                   SysTick_CTRL_TICKINT_Msk   | 
                   SysTick_CTRL_ENABLE_Msk;                    // 启用 SysTick 中断和 SysTick 定时器
  return (0);
}

#endif


/* ##################################  复位函数  ############################################ */
static __INLINE void NVIC_SystemReset(void)
{
  SCB->AIRCR  = ((0x5FA << SCB_AIRCR_VECTKEY_Pos)      | 
                 (SCB->AIRCR & SCB_AIRCR_PRIGROUP_Msk) | 
                 SCB_AIRCR_SYSRESETREQ_Msk);
  __DSB();    // 确保内存访问完成
  while(1);   // 等待直到复位
}


/* ##################################### 调试输入/输出函数 ########################################### */
extern volatile int ITM_RxBuffer;                     // 用于接收字符的变量
#define             ITM_RXBUFFER_EMPTY    0x5AA55AA5  // 标识 ITM_RxBuffer 准备好接收下一个字符的值

// 通过 ITM 通道 0 输出一个字符
static __INLINE uint32_t ITM_SendChar (uint32_t ch)
{
  if ((CoreDebug->DEMCR & CoreDebug_DEMCR_TRCENA_Msk)  &&      // 跟踪已启用
      (ITM->TCR & ITM_TCR_ITMENA_Msk)                  &&      // ITM 已启用
      (ITM->TER & (1ul << 0)        )                    )     // ITM 端口 #0 已启用
  {
    while (ITM->PORT[0].u32 == 0);
    ITM->PORT[0].u8 = (uint8_t) ch;
  }  
  return (ch);
}

// 通过变量 ITM_RxBuffer 输入一个字符
static __INLINE int ITM_ReceiveChar (void) {
  int ch = -1;                               // 没有可用字符

  if (ITM_RxBuffer != ITM_RXBUFFER_EMPTY) {
    ch = ITM_RxBuffer;
    ITM_RxBuffer = ITM_RXBUFFER_EMPTY;       // 准备好接收下一个字符
  }
  
  return (ch); 
}

// 检查是否可以通过变量 ITM_RxBuffer 获取字符
static __INLINE int ITM_CheckChar (void) {

  if (ITM_RxBuffer == ITM_RXBUFFER_EMPTY) {
    return (0);                              // 没有可用字符
  } else {
    return (1);                              // 有可用字符 
  }
}


#ifdef __cplusplus     // 如果使用 C++ 编译器，结束 C 链接约定
}
#endif

// __CM3_CORE_H__
#endif
```



## core_cm3.c

```c
// 该头文件定义了一系列固定位宽的整数类型，如 int8_t 、uint8_t 、int16_t 等
#include <stdint.h>

// 定义编译器特定的符号
#if defined ( __CC_ARM   )     // __CC_ARM 是 armcc 编译器的内置预定义宏
  #define __ASM            __asm
  #define __INLINE         __inline

#elif defined ( __ICCARM__ )
  #define __ASM           __asm
  #define __INLINE        inline

#elif defined   (  __GNUC__  ) // arm gcc 编译器
  #define __ASM            __asm
  #define __INLINE         inline

#elif defined   (  __TASKING__  )
  #define __ASM            __asm
  #define __INLINE         inline

#endif


/* ###################  编译器特定的函数  ########################### */

#if defined ( __CC_ARM   )

// 获取进程堆栈指针
__ASM uint32_t __get_PSP(void)
{
  mrs r0, psp    // 从 PSP 寄存器读取值到 R0 寄存器
  bx lr          // 函数返回（bx 指令跳转到 lr 寄存器中的地址处，lr 寄存器保存的是函数调用处的下一条指令地址）
}

// 设置进程堆栈指针
__ASM void __set_PSP(uint32_t topOfProcStack)
{
  msr psp, r0    // 将 r0 的值写入 PSP 寄存器（对于有参数的函数，第一个参数（32位或更小）通过 r0 寄存器传递）
  bx lr
}

// 获取主堆栈指针
__ASM uint32_t __get_MSP(void)
{
  mrs r0, msp
  bx lr
}

// 设置主堆栈指针
__ASM void __set_MSP(uint32_t mainStackPointer)
{
  msr msp, r0
  bx lr
}

// 反转半字中的字节，0x12345678 --> 0x34127856
__ASM uint32_t __REV16(uint16_t value)
{
  rev16 r0, r0    // r0 既用作传递函数第一个参数，也用作保存返回值
  bx lr
}

// 反转低半字中的字节，并将结果有符号展开，0x33448899 --> 0xFFFF9988
__ASM int32_t __REVSH(int16_t value)
{
  revsh r0, r0
  bx lr
}


// ARM Compiler 4 之前的版本
#if (__ARMCC_VERSION < 400000)

// 清除由 ldrex 创建的独占锁
__ASM void __CLREX(void)
{
  clrex
}

// 获取寄存器 basepri 的值
__ASM uint32_t  __get_BASEPRI(void)
{
  mrs r0, basepri
  bx lr
}

/**
 * @brief  Set the Base Priority value
 *
 * @param  basePri  BasePriority
 *
 * Set the base priority register
 */
__ASM void __set_BASEPRI(uint32_t basePri)
{
  msr basepri, r0
  bx lr
}

/**
 * @brief  Return the Priority Mask value
 *
 * @return PriMask
 *
 * Return state of the priority mask bit from the priority mask register
 */
__ASM uint32_t __get_PRIMASK(void)
{
  mrs r0, primask
  bx lr
}

/**
 * @brief  Set the Priority Mask value
 *
 * @param  priMask  PriMask
 *
 * Set the priority mask bit in the priority mask register
 */
__ASM void __set_PRIMASK(uint32_t priMask)
{
  msr primask, r0
  bx lr
}

/**
 * @brief  Return the Fault Mask value
 *
 * @return FaultMask
 *
 * Return the content of the fault mask register
 */
__ASM uint32_t  __get_FAULTMASK(void)
{
  mrs r0, faultmask
  bx lr
}

/**
 * @brief  Set the Fault Mask value
 *
 * @param  faultMask  faultMask value
 *
 * Set the fault mask register
 */
__ASM void __set_FAULTMASK(uint32_t faultMask)
{
  msr faultmask, r0
  bx lr
}

/**
 * @brief  Return the Control Register value
 * 
 * @return Control value
 *
 * Return the content of the control register
 */
__ASM uint32_t __get_CONTROL(void)
{
  mrs r0, control
  bx lr
}

/**
 * @brief  Set the Control Register value
 *
 * @param  control  Control value
 *
 * Set the control register
 */
__ASM void __set_CONTROL(uint32_t control)
{
  msr control, r0
  bx lr
}

#endif /* __ARMCC_VERSION  */ 



#elif (defined (__ICCARM__)) /*------------------ ICC Compiler -------------------*/
/* IAR iccarm specific functions */
#pragma diag_suppress=Pe940

/**
 * @brief  Return the Process Stack Pointer
 *
 * @return ProcessStackPointer
 *
 * Return the actual process stack pointer
 */
uint32_t __get_PSP(void)
{
  __ASM("mrs r0, psp");
  __ASM("bx lr");
}

/**
 * @brief  Set the Process Stack Pointer
 *
 * @param  topOfProcStack  Process Stack Pointer
 *
 * Assign the value ProcessStackPointer to the MSP 
 * (process stack pointer) Cortex processor register
 */
void __set_PSP(uint32_t topOfProcStack)
{
  __ASM("msr psp, r0");
  __ASM("bx lr");
}

/**
 * @brief  Return the Main Stack Pointer
 *
 * @return Main Stack Pointer
 *
 * Return the current value of the MSP (main stack pointer)
 * Cortex processor register
 */
uint32_t __get_MSP(void)
{
  __ASM("mrs r0, msp");
  __ASM("bx lr");
}

/**
 * @brief  Set the Main Stack Pointer
 *
 * @param  topOfMainStack  Main Stack Pointer
 *
 * Assign the value mainStackPointer to the MSP 
 * (main stack pointer) Cortex processor register
 */
void __set_MSP(uint32_t topOfMainStack)
{
  __ASM("msr msp, r0");
  __ASM("bx lr");
}

/**
 * @brief  Reverse byte order in unsigned short value
 *
 * @param  value  value to reverse
 * @return        reversed value
 *
 * Reverse byte order in unsigned short value
 */
uint32_t __REV16(uint16_t value)
{
  __ASM("rev16 r0, r0");
  __ASM("bx lr");
}

/**
 * @brief  Reverse bit order of value
 *
 * @param  value  value to reverse
 * @return        reversed value
 *
 * Reverse bit order of value
 */
uint32_t __RBIT(uint32_t value)
{
  __ASM("rbit r0, r0");
  __ASM("bx lr");
}

/**
 * @brief  LDR Exclusive (8 bit)
 *
 * @param  *addr  address pointer
 * @return        value of (*address)
 *
 * Exclusive LDR command for 8 bit values)
 */
uint8_t __LDREXB(uint8_t *addr)
{
  __ASM("ldrexb r0, [r0]");
  __ASM("bx lr"); 
}

/**
 * @brief  LDR Exclusive (16 bit)
 *
 * @param  *addr  address pointer
 * @return        value of (*address)
 *
 * Exclusive LDR command for 16 bit values
 */
uint16_t __LDREXH(uint16_t *addr)
{
  __ASM("ldrexh r0, [r0]");
  __ASM("bx lr");
}

/**
 * @brief  LDR Exclusive (32 bit)
 *
 * @param  *addr  address pointer
 * @return        value of (*address)
 *
 * Exclusive LDR command for 32 bit values
 */
uint32_t __LDREXW(uint32_t *addr)
{
  __ASM("ldrex r0, [r0]");
  __ASM("bx lr");
}

/**
 * @brief  STR Exclusive (8 bit)
 *
 * @param  value  value to store
 * @param  *addr  address pointer
 * @return        successful / failed
 *
 * Exclusive STR command for 8 bit values
 */
uint32_t __STREXB(uint8_t value, uint8_t *addr)
{
  __ASM("strexb r0, r0, [r1]");
  __ASM("bx lr");
}

/**
 * @brief  STR Exclusive (16 bit)
 *
 * @param  value  value to store
 * @param  *addr  address pointer
 * @return        successful / failed
 *
 * Exclusive STR command for 16 bit values
 */
uint32_t __STREXH(uint16_t value, uint16_t *addr)
{
  __ASM("strexh r0, r0, [r1]");
  __ASM("bx lr");
}

/**
 * @brief  STR Exclusive (32 bit)
 *
 * @param  value  value to store
 * @param  *addr  address pointer
 * @return        successful / failed
 *
 * Exclusive STR command for 32 bit values
 */
uint32_t __STREXW(uint32_t value, uint32_t *addr)
{
  __ASM("strex r0, r0, [r1]");
  __ASM("bx lr");
}

#pragma diag_default=Pe940


#elif (defined (__GNUC__)) /*------------------ GNU Compiler ---------------------*/
/* GNU gcc specific functions */

/**
 * @brief  Return the Process Stack Pointer
 *
 * @return ProcessStackPointer
 *
 * Return the actual process stack pointer
 */
uint32_t __get_PSP(void) __attribute__( ( naked ) );
uint32_t __get_PSP(void)
{
  uint32_t result=0;

  __ASM volatile ("MRS %0, psp\n\t" 
                  "MOV r0, %0 \n\t"
                  "BX  lr     \n\t"  : "=r" (result) );
  return(result);
}

/**
 * @brief  Set the Process Stack Pointer
 *
 * @param  topOfProcStack  Process Stack Pointer
 *
 * Assign the value ProcessStackPointer to the MSP 
 * (process stack pointer) Cortex processor register
 */
void __set_PSP(uint32_t topOfProcStack) __attribute__( ( naked ) );
void __set_PSP(uint32_t topOfProcStack)
{
  __ASM volatile ("MSR psp, %0\n\t"
                  "BX  lr     \n\t" : : "r" (topOfProcStack) );
}

/**
 * @brief  Return the Main Stack Pointer
 *
 * @return Main Stack Pointer
 *
 * Return the current value of the MSP (main stack pointer)
 * Cortex processor register
 */
uint32_t __get_MSP(void) __attribute__( ( naked ) );
uint32_t __get_MSP(void)
{
  uint32_t result=0;

  __ASM volatile ("MRS %0, msp\n\t" 
                  "MOV r0, %0 \n\t"
                  "BX  lr     \n\t"  : "=r" (result) );
  return(result);
}

/**
 * @brief  Set the Main Stack Pointer
 *
 * @param  topOfMainStack  Main Stack Pointer
 *
 * Assign the value mainStackPointer to the MSP 
 * (main stack pointer) Cortex processor register
 */
void __set_MSP(uint32_t topOfMainStack) __attribute__( ( naked ) );
void __set_MSP(uint32_t topOfMainStack)
{
  __ASM volatile ("MSR msp, %0\n\t"
                  "BX  lr     \n\t" : : "r" (topOfMainStack) );
}

/**
 * @brief  Return the Base Priority value
 *
 * @return BasePriority
 *
 * Return the content of the base priority register
 */
uint32_t __get_BASEPRI(void)
{
  uint32_t result=0;
  
  __ASM volatile ("MRS %0, basepri_max" : "=r" (result) );
  return(result);
}

/**
 * @brief  Set the Base Priority value
 *
 * @param  basePri  BasePriority
 *
 * Set the base priority register
 */
void __set_BASEPRI(uint32_t value)
{
  __ASM volatile ("MSR basepri, %0" : : "r" (value) );
}

/**
 * @brief  Return the Priority Mask value
 *
 * @return PriMask
 *
 * Return state of the priority mask bit from the priority mask register
 */
uint32_t __get_PRIMASK(void)
{
  uint32_t result=0;

  __ASM volatile ("MRS %0, primask" : "=r" (result) );
  return(result);
}

/**
 * @brief  Set the Priority Mask value
 *
 * @param  priMask  PriMask
 *
 * Set the priority mask bit in the priority mask register
 */
void __set_PRIMASK(uint32_t priMask)
{
  __ASM volatile ("MSR primask, %0" : : "r" (priMask) );
}

/**
 * @brief  Return the Fault Mask value
 *
 * @return FaultMask
 *
 * Return the content of the fault mask register
 */
uint32_t __get_FAULTMASK(void)
{
  uint32_t result=0;
  
  __ASM volatile ("MRS %0, faultmask" : "=r" (result) );
  return(result);
}

/**
 * @brief  Set the Fault Mask value
 *
 * @param  faultMask  faultMask value
 *
 * Set the fault mask register
 */
void __set_FAULTMASK(uint32_t faultMask)
{
  __ASM volatile ("MSR faultmask, %0" : : "r" (faultMask) );
}

/**
 * @brief  Return the Control Register value
* 
*  @return Control value
 *
 * Return the content of the control register
 */
uint32_t __get_CONTROL(void)
{
  uint32_t result=0;

  __ASM volatile ("MRS %0, control" : "=r" (result) );
  return(result);
}

/**
 * @brief  Set the Control Register value
 *
 * @param  control  Control value
 *
 * Set the control register
 */
void __set_CONTROL(uint32_t control)
{
  __ASM volatile ("MSR control, %0" : : "r" (control) );
}


/**
 * @brief  Reverse byte order in integer value
 *
 * @param  value  value to reverse
 * @return        reversed value
 *
 * Reverse byte order in integer value
 */
uint32_t __REV(uint32_t value)
{
  uint32_t result=0;
  
  __ASM volatile ("rev %0, %1" : "=r" (result) : "r" (value) );
  return(result);
}

/**
 * @brief  Reverse byte order in unsigned short value
 *
 * @param  value  value to reverse
 * @return        reversed value
 *
 * Reverse byte order in unsigned short value
 */
uint32_t __REV16(uint16_t value)
{
  uint32_t result=0;
  
  __ASM volatile ("rev16 %0, %1" : "=r" (result) : "r" (value) );
  return(result);
}

/**
 * @brief  Reverse byte order in signed short value with sign extension to integer
 *
 * @param  value  value to reverse
 * @return        reversed value
 *
 * Reverse byte order in signed short value with sign extension to integer
 */
int32_t __REVSH(int16_t value)
{
  uint32_t result=0;
  
  __ASM volatile ("revsh %0, %1" : "=r" (result) : "r" (value) );
  return(result);
}

/**
 * @brief  Reverse bit order of value
 *
 * @param  value  value to reverse
 * @return        reversed value
 *
 * Reverse bit order of value
 */
uint32_t __RBIT(uint32_t value)
{
  uint32_t result=0;
  
   __ASM volatile ("rbit %0, %1" : "=r" (result) : "r" (value) );
   return(result);
}

/**
 * @brief  LDR Exclusive (8 bit)
 *
 * @param  *addr  address pointer
 * @return        value of (*address)
 *
 * Exclusive LDR command for 8 bit value
 */
uint8_t __LDREXB(uint8_t *addr)
{
    uint8_t result=0;
  
   __ASM volatile ("ldrexb %0, [%1]" : "=r" (result) : "r" (addr) );
   return(result);
}

/**
 * @brief  LDR Exclusive (16 bit)
 *
 * @param  *addr  address pointer
 * @return        value of (*address)
 *
 * Exclusive LDR command for 16 bit values
 */
uint16_t __LDREXH(uint16_t *addr)
{
    uint16_t result=0;
  
   __ASM volatile ("ldrexh %0, [%1]" : "=r" (result) : "r" (addr) );
   return(result);
}

/**
 * @brief  LDR Exclusive (32 bit)
 *
 * @param  *addr  address pointer
 * @return        value of (*address)
 *
 * Exclusive LDR command for 32 bit values
 */
uint32_t __LDREXW(uint32_t *addr)
{
    uint32_t result=0;
  
   __ASM volatile ("ldrex %0, [%1]" : "=r" (result) : "r" (addr) );
   return(result);
}

/**
 * @brief  STR Exclusive (8 bit)
 *
 * @param  value  value to store
 * @param  *addr  address pointer
 * @return        successful / failed
 *
 * Exclusive STR command for 8 bit values
 */
uint32_t __STREXB(uint8_t value, uint8_t *addr)
{
   uint32_t result=0;
  
   __ASM volatile ("strexb %0, %2, [%1]" : "=r" (result) : "r" (addr), "r" (value) );
   return(result);
}

/**
 * @brief  STR Exclusive (16 bit)
 *
 * @param  value  value to store
 * @param  *addr  address pointer
 * @return        successful / failed
 *
 * Exclusive STR command for 16 bit values
 */
uint32_t __STREXH(uint16_t value, uint16_t *addr)
{
   uint32_t result=0;
  
   __ASM volatile ("strexh %0, %2, [%1]" : "=r" (result) : "r" (addr), "r" (value) );
   return(result);
}

/**
 * @brief  STR Exclusive (32 bit)
 *
 * @param  value  value to store
 * @param  *addr  address pointer
 * @return        successful / failed
 *
 * Exclusive STR command for 32 bit values
 */
uint32_t __STREXW(uint32_t value, uint32_t *addr)
{
   uint32_t result=0;
  
   __ASM volatile ("strex %0, %2, [%1]" : "=r" (result) : "r" (addr), "r" (value) );
   return(result);
}


#elif (defined (__TASKING__)) /*------------------ TASKING Compiler ---------------------*/
/* TASKING carm specific functions */

/*
 * The CMSIS functions have been implemented as intrinsics in the compiler.
 * Please use "carm -?i" to get an up to date list of all instrinsics,
 * Including the CMSIS ones.
 */

#endif
```
