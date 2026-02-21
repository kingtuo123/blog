---
title: "STM32F1 标准库源码阅读"
date: "2026-01-29"
toc: true
---


## CM3 内核文件

### core_cm3.h

{{< bar title="Libraries/CMSIS/CM3/CoreSupport/core_cm3.h" >}}

```c { class="fixed-height" lineNos=inline }
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


/****************************************************************************************************
 *                                  Cortex-M3 硬件的内存映射
 ***************************************************************************************************/
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
    // 系统中断，SHP[0] ~ SHP[2] 对应系统异常枚举值 -12 ~ -10，SHP[7](-5)，SHP[8](-4)，SHP[10](-2)，SHP[11](-1)，其余未实现
	// -12 二进制是 1111 0100
    SCB->SHP[((uint32_t)(IRQn) & 0xF)-4] = ((priority << (8 - __NVIC_PRIO_BITS)) & 0xff); }
  else {
    // 外部中断，IP[0] (8位) 对应外部中断枚举值 0 ，以此类推
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

内核头文件主要定义了以下内容：

- NVIC，SCB，SysTick，ITM，MPU，CoreDebug 等寄存器内存映射。
- 优先级分组，中断优先级设置函数，SysTick 配置函数等。
- 内核访问函数。




### core_cm3.c


{{< bar title="Libraries/CMSIS/CM3/CoreSupport/core_cm3.c" >}}

```c { class="fixed-height" lineNos=inline }
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

// 获取 basepri 寄存器的值
__ASM uint32_t  __get_BASEPRI(void)
{
  mrs r0, basepri
  bx lr
}

// 设置 basepri 寄存器的值 (屏蔽优先级低于 basepri 的中断)
__ASM void __set_BASEPRI(uint32_t basePri)
{
  msr basepri, r0
  bx lr
}

// 获取 primask 寄存器的值
__ASM uint32_t __get_PRIMASK(void)
{
  mrs r0, primask
  bx lr
}

// 设置 primask 寄存器的值 (屏蔽除 NMI 和 HardFault 外的所有中断)
__ASM void __set_PRIMASK(uint32_t priMask)
{
  msr primask, r0
  bx lr
}

// 获取 faultmask 寄存器的值
__ASM uint32_t  __get_FAULTMASK(void)
{
  mrs r0, faultmask
  bx lr
}

// 设置 faultmask 寄存器的值 (屏蔽除 NMI 外的所有中断)
__ASM void __set_FAULTMASK(uint32_t faultMask)
{
  msr faultmask, r0
  bx lr
}

// 获取 control 寄存器的值
__ASM uint32_t __get_CONTROL(void)
{
  mrs r0, control
  bx lr
}

// 设置 control 寄存器的值 ( control 寄存器用于特权模式的切换、主栈/进程栈的切换)
__ASM void __set_CONTROL(uint32_t control)
{
  msr control, r0
  bx lr
}

#endif



#elif (defined (__ICCARM__)) /*------------------ ICC Compiler -------------------*/
#pragma diag_suppress=Pe940

uint32_t __get_PSP(void)
{
  __ASM("mrs r0, psp");
  __ASM("bx lr");
}

void __set_PSP(uint32_t topOfProcStack)
{
  __ASM("msr psp, r0");
  __ASM("bx lr");
}

uint32_t __get_MSP(void)
{
  __ASM("mrs r0, msp");
  __ASM("bx lr");
}

void __set_MSP(uint32_t topOfMainStack)
{
  __ASM("msr msp, r0");
  __ASM("bx lr");
}

uint32_t __REV16(uint16_t value)
{
  __ASM("rev16 r0, r0");
  __ASM("bx lr");
}

uint32_t __RBIT(uint32_t value)
{
  __ASM("rbit r0, r0");
  __ASM("bx lr");
}

uint8_t __LDREXB(uint8_t *addr)
{
  __ASM("ldrexb r0, [r0]");
  __ASM("bx lr"); 
}

uint16_t __LDREXH(uint16_t *addr)
{
  __ASM("ldrexh r0, [r0]");
  __ASM("bx lr");
}

uint32_t __LDREXW(uint32_t *addr)
{
  __ASM("ldrex r0, [r0]");
  __ASM("bx lr");
}

uint32_t __STREXB(uint8_t value, uint8_t *addr)
{
  __ASM("strexb r0, r0, [r1]");
  __ASM("bx lr");
}

uint32_t __STREXH(uint16_t value, uint16_t *addr)
{
  __ASM("strexh r0, r0, [r1]");
  __ASM("bx lr");
}

uint32_t __STREXW(uint32_t value, uint32_t *addr)
{
  __ASM("strex r0, r0, [r1]");
  __ASM("bx lr");
}

#pragma diag_default=Pe940


#elif (defined (__GNUC__)) /*------------------ GNU Compiler ---------------------*/

// naked 属性告诉编译器不生成任何序言/尾声代码，即程序员必须自己处理 寄存器保存/恢复, 栈指针调整 , 函数返回
uint32_t __get_PSP(void) __attribute__( ( naked ) );
uint32_t __get_PSP(void)
{
  uint32_t result=0;

  __ASM volatile ("MRS %0, psp\n\t" 
                  "MOV r0, %0 \n\t"
                  "BX  lr     \n\t"  : "=r" (result) );
  return(result);
}

void __set_PSP(uint32_t topOfProcStack) __attribute__( ( naked ) );
void __set_PSP(uint32_t topOfProcStack)
{
  __ASM volatile ("MSR psp, %0\n\t"
                  "BX  lr     \n\t" : : "r" (topOfProcStack) );
}

uint32_t __get_MSP(void) __attribute__( ( naked ) );
uint32_t __get_MSP(void)
{
  uint32_t result=0;

  __ASM volatile ("MRS %0, msp\n\t" 
                  "MOV r0, %0 \n\t"
                  "BX  lr     \n\t"  : "=r" (result) );
  return(result);
}

void __set_MSP(uint32_t topOfMainStack) __attribute__( ( naked ) );
void __set_MSP(uint32_t topOfMainStack)
{
  __ASM volatile ("MSR msp, %0\n\t"
                  "BX  lr     \n\t" : : "r" (topOfMainStack) );
}

uint32_t __get_BASEPRI(void)
{
  uint32_t result=0;
  
  __ASM volatile ("MRS %0, basepri_max" : "=r" (result) );
  return(result);
}

void __set_BASEPRI(uint32_t value)
{
  __ASM volatile ("MSR basepri, %0" : : "r" (value) );
}

uint32_t __get_PRIMASK(void)
{
  uint32_t result=0;

  __ASM volatile ("MRS %0, primask" : "=r" (result) );
  return(result);
}

void __set_PRIMASK(uint32_t priMask)
{
  __ASM volatile ("MSR primask, %0" : : "r" (priMask) );
}

uint32_t __get_FAULTMASK(void)
{
  uint32_t result=0;
  
  __ASM volatile ("MRS %0, faultmask" : "=r" (result) );
  return(result);
}

void __set_FAULTMASK(uint32_t faultMask)
{
  __ASM volatile ("MSR faultmask, %0" : : "r" (faultMask) );
}

uint32_t __get_CONTROL(void)
{
  uint32_t result=0;

  __ASM volatile ("MRS %0, control" : "=r" (result) );
  return(result);
}

void __set_CONTROL(uint32_t control)
{
  __ASM volatile ("MSR control, %0" : : "r" (control) );
}

uint32_t __REV(uint32_t value)
{
  uint32_t result=0;
  
  __ASM volatile ("rev %0, %1" : "=r" (result) : "r" (value) );
  return(result);
}

uint32_t __REV16(uint16_t value)
{
  uint32_t result=0;
  
  __ASM volatile ("rev16 %0, %1" : "=r" (result) : "r" (value) );
  return(result);
}

int32_t __REVSH(int16_t value)
{
  uint32_t result=0;
  
  __ASM volatile ("revsh %0, %1" : "=r" (result) : "r" (value) );
  return(result);
}

uint32_t __RBIT(uint32_t value)
{
  uint32_t result=0;
  
   __ASM volatile ("rbit %0, %1" : "=r" (result) : "r" (value) );
   return(result);
}

uint8_t __LDREXB(uint8_t *addr)
{
    uint8_t result=0;
  
   __ASM volatile ("ldrexb %0, [%1]" : "=r" (result) : "r" (addr) );
   return(result);
}

uint16_t __LDREXH(uint16_t *addr)
{
    uint16_t result=0;
  
   __ASM volatile ("ldrexh %0, [%1]" : "=r" (result) : "r" (addr) );
   return(result);
}

uint32_t __LDREXW(uint32_t *addr)
{
    uint32_t result=0;
  
   __ASM volatile ("ldrex %0, [%1]" : "=r" (result) : "r" (addr) );
   return(result);
}

uint32_t __STREXB(uint8_t value, uint8_t *addr)
{
   uint32_t result=0;
  
   __ASM volatile ("strexb %0, %2, [%1]" : "=r" (result) : "r" (addr), "r" (value) );
   return(result);
}

uint32_t __STREXH(uint16_t value, uint16_t *addr)
{
   uint32_t result=0;
  
   __ASM volatile ("strexh %0, %2, [%1]" : "=r" (result) : "r" (addr), "r" (value) );
   return(result);
}

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




## STM32F10x 设备文件




### GCC 启动文件


{{< bar title="Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/gcc_ride7/startup_stm32f10x_hd.s" >}}

```asm { class="fixed-height" lineNos=inline }
.syntax unified            // 使用统一汇编语言（Unified Assembly Language, UAL）
.cpu cortex-m3             // 指定架构 Cortex-M3
.fpu softvfp               // 使用软件浮点运算，CM3 没有硬件浮点单元
.thumb                     // 使用 thumb 指令集

.global  g_pfnVectors      // 声明一个全局符号 g_pfnVectors（向量表）
.global  Default_Handler   // 声明一个全局符号 Default_Handler（复位函数）

/* .word 语法
 * .word 0x20001000        ;  分配一个字的空间，值为 0x20001000
 * .word Reset_Handler     ;  为 Reset_Handler 分配一个字的空间，Reset_Handler 为符号地址，可存储一个字 */

.word  _sidata             // .data 段在 FLASH 中的起始地址，该值在链接脚本中定义（.data 包含已初始化的全局/静态变量）
.word  _sdata              // .data 段在  SRAM 中的起始地址，该值在链接脚本中定义
.word  _edata              // .data 段在  SRAM 中的结束地址，该值在链接脚本中定义
.word  _sbss               //  .bss 段在  SRAM 中的起始地址，该值在链接脚本中定义（ .bss 包含未初始化的全局/静态变量）
.word  _ebss               //  .bss 段在  SRAM 中的结束地址，该值在链接脚本中定义


.equ  BootRAM, 0xF1E0F85F          // 定义 BootRAM = 0xF1E0F85F，用于 SRAM 启动


.section  .text.Reset_Handler      // 告诉汇编器将本行之后的代码或数据放入 .text.Reset_Handler 段中，直到遇到下一个 .section
.weak  Reset_Handler               // 声明 Reset_Handler 为弱符号，允许用户重写
.type  Reset_Handler, %function    // 指定 Reset_Handler 为函数类型

Reset_Handler:  
    movs  r1, #0                   // r1 = 0
    b  LoopCopyDataInit            // 跳转到 LoopCopyDataInit 处

CopyDataInit:
    ldr  r3, =_sidata              // r3 = _sidata（.data 段在 FLASH 中的起始地址）
    ldr  r3, [r3, r1]              // r3 = *(r3 + r1) = *(_sidata + r1)
    str  r3, [r0, r1]              // 存储 r3 -> *(r0 +r1)，即 *(_sidata + r1) -> *(_sdata + r1)
    adds  r1, r1, #4               // r1 = r1 + 4，此处执行完继续向下执行 LoopCopyDataInit
    
LoopCopyDataInit:
    ldr  r0, =_sdata               // r0 = _sdata（.data 段在 SRAM 中的起始地址）
    ldr  r3, =_edata               // r3 = _edata（.data 段在 SRAM 中的结束地址）
    adds  r2, r0, r1               // r2 = r0 + r1 = _sdata + r1
    cmp  r2, r3                    // 比较 r2 和 r3 的值 --> 比较 _sdata+r1 和 _edata 的值
    bcc  CopyDataInit              // 如果 _sdata + r1 < _edata 则跳转到 CopyDataInit
    ldr  r2, =_sbss                // r2 = _sbss（.bss 段在 SRAM 中的起始地址）
    b  LoopFillZerobss             // 跳转到 LoopFillZerobss

FillZerobss:
    movs  r3, #0                   // r3 = 0
    str  r3, [r2], #4              // 存储 r3 -> *r2 然后 r2 = r2 + 4 , 即存储 0 -> *_sbss 然后 _sbss = _sbss + 4
    
LoopFillZerobss:
    ldr  r3, = _ebss               // r3 = _ebss（.bss 段在 SRAM 中的结束地址）
    cmp  r2, r3                    // 比较 r2 和 r3 --> 比较 _sbss 和 _ebss
    bcc  FillZerobss               // 如果 _sbss < _ebss 则跳转到 FillZerobss
    bl  SystemInit                 // 跳转到 SystemInit 函数，并将返回地址（下一条指令的地址）保存在 LR 寄存器中
    bl  main                       // 跳转到       main 函数，并将返回地址（下一条指令的地址）保存在 LR 寄存器中
    bx  lr                         // 从 main 返回后，跳回 LR 存器地址（通常不会执行到这里）

.size  Reset_Handler, .-Reset_Handler  // 设置 Reset_Handler 的大小为当前位置（.）减去 Reset_Handler 的起始地址
                                       // 显式指定符号的大小信息（边界），以便链接器可以检查符号引用是否超出范围


.section  .text.Default_Handler,"ax",%progbits  // 将 Default_Handler 代码放在 .text.Default_Handler 段中，"ax" 表示可分配+可执行
Default_Handler:
Infinite_Loop:                                  // 当处理器收到未预期的中断时执行的代码，进入死循环
    b  Infinite_Loop                            // 跳转到 Infinite_Loop
.size  Default_Handler, .-Default_Handler       // 设置 Default_Handler 的大小为当前位置（.）减去 Default_Handler 的起始地址



.section  .isr_vector,"a",%progbits     // 告诉汇编器将本行之后的代码或数据（向量表）放入 .isr_vector 段，"a" 表示可分配，直到遇到下一个 .section
.type  g_pfnVectors, %object            // 指定 g_pfnVectors 为数据对象类型
.size  g_pfnVectors, .-g_pfnVectors     // 设置 g_pfnVectors 的大小，为什么 .size 指令不放向量表后面？？？？存疑。

    
g_pfnVectors:
    .word  _estack                        // 初始栈指针地址
    .word  Reset_Handler                  // 复位处理程序
    .word  NMI_Handler
    .word  HardFault_Handler
    .word  MemManage_Handler
    .word  BusFault_Handler
    .word  UsageFault_Handler
    .word  0
    .word  0
    .word  0
    .word  0
    .word  SVC_Handler
    .word  DebugMon_Handler
    .word  0
    .word  PendSV_Handler
    .word  SysTick_Handler
    .word  WWDG_IRQHandler
    .word  PVD_IRQHandler
    .word  TAMPER_IRQHandler
    .word  RTC_IRQHandler
    .word  FLASH_IRQHandler
    .word  RCC_IRQHandler
    .word  EXTI0_IRQHandler
    .word  EXTI1_IRQHandler
    .word  EXTI2_IRQHandler
    .word  EXTI3_IRQHandler
    .word  EXTI4_IRQHandler
    .word  DMA1_Channel1_IRQHandler
    .word  DMA1_Channel2_IRQHandler
    .word  DMA1_Channel3_IRQHandler
    .word  DMA1_Channel4_IRQHandler
    .word  DMA1_Channel5_IRQHandler
    .word  DMA1_Channel6_IRQHandler
    .word  DMA1_Channel7_IRQHandler
    .word  ADC1_2_IRQHandler
    .word  USB_HP_CAN1_TX_IRQHandler
    .word  USB_LP_CAN1_RX0_IRQHandler
    .word  CAN1_RX1_IRQHandler
    .word  CAN1_SCE_IRQHandler
    .word  EXTI9_5_IRQHandler
    .word  TIM1_BRK_IRQHandler
    .word  TIM1_UP_IRQHandler
    .word  TIM1_TRG_COM_IRQHandler
    .word  TIM1_CC_IRQHandler
    .word  TIM2_IRQHandler
    .word  TIM3_IRQHandler
    .word  TIM4_IRQHandler
    .word  I2C1_EV_IRQHandler
    .word  I2C1_ER_IRQHandler
    .word  I2C2_EV_IRQHandler
    .word  I2C2_ER_IRQHandler
    .word  SPI1_IRQHandler
    .word  SPI2_IRQHandler
    .word  USART1_IRQHandler
    .word  USART2_IRQHandler
    .word  USART3_IRQHandler
    .word  EXTI15_10_IRQHandler
    .word  RTCAlarm_IRQHandler
    .word  USBWakeUp_IRQHandler
    .word  TIM8_BRK_IRQHandler
    .word  TIM8_UP_IRQHandler
    .word  TIM8_TRG_COM_IRQHandler
    .word  TIM8_CC_IRQHandler
    .word  ADC3_IRQHandler
    .word  FSMC_IRQHandler
    .word  SDIO_IRQHandler
    .word  TIM5_IRQHandler
    .word  SPI3_IRQHandler
    .word  UART4_IRQHandler
    .word  UART5_IRQHandler
    .word  TIM6_IRQHandler
    .word  TIM7_IRQHandler
    .word  DMA2_Channel1_IRQHandler
    .word  DMA2_Channel2_IRQHandler
    .word  DMA2_Channel3_IRQHandler
    .word  DMA2_Channel4_5_IRQHandler
    .word  0    // 以下为保留中断向量位置，填充为0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  BootRAM    // 偏移：0x1E0；
                      // BootRAM = 0xF1E0F85F = 0xF85F 0xF1E0 = LDR.W PC, [PC, #-0x1E0] -> 即 PC = *(PC - 0x1E0)


// .weak 表示弱定义符号，用户函数可覆盖 
// .thumb_set 将一个符号定义为另一个符号的别名 （alias），并且明确指定该别名是 Thumb 指令集的符号
.weak  NMI_Handler
.thumb_set NMI_Handler,Default_Handler   // 设置 NMI_Handler 为 Default_Handler 的弱别名

.weak  HardFault_Handler
.thumb_set HardFault_Handler,Default_Handler

.weak  MemManage_Handler
.thumb_set MemManage_Handler,Default_Handler

.weak  BusFault_Handler
.thumb_set BusFault_Handler,Default_Handler

.weak  UsageFault_Handler
.thumb_set UsageFault_Handler,Default_Handler

.weak  SVC_Handler
.thumb_set SVC_Handler,Default_Handler

.weak  DebugMon_Handler
.thumb_set DebugMon_Handler,Default_Handler

.weak  PendSV_Handler
.thumb_set PendSV_Handler,Default_Handler

.weak  SysTick_Handler
.thumb_set SysTick_Handler,Default_Handler

.weak  WWDG_IRQHandler
.thumb_set WWDG_IRQHandler,Default_Handler

.weak  PVD_IRQHandler
.thumb_set PVD_IRQHandler,Default_Handler

.weak  TAMPER_IRQHandler
.thumb_set TAMPER_IRQHandler,Default_Handler

.weak  RTC_IRQHandler
.thumb_set RTC_IRQHandler,Default_Handler

.weak  FLASH_IRQHandler
.thumb_set FLASH_IRQHandler,Default_Handler

.weak  RCC_IRQHandler
.thumb_set RCC_IRQHandler,Default_Handler

.weak  EXTI0_IRQHandler
.thumb_set EXTI0_IRQHandler,Default_Handler

.weak  EXTI1_IRQHandler
.thumb_set EXTI1_IRQHandler,Default_Handler

.weak  EXTI2_IRQHandler
.thumb_set EXTI2_IRQHandler,Default_Handler

.weak  EXTI3_IRQHandler
.thumb_set EXTI3_IRQHandler,Default_Handler

.weak  EXTI4_IRQHandler
.thumb_set EXTI4_IRQHandler,Default_Handler

.weak  DMA1_Channel1_IRQHandler
.thumb_set DMA1_Channel1_IRQHandler,Default_Handler

.weak  DMA1_Channel2_IRQHandler
.thumb_set DMA1_Channel2_IRQHandler,Default_Handler

.weak  DMA1_Channel3_IRQHandler
.thumb_set DMA1_Channel3_IRQHandler,Default_Handler

.weak  DMA1_Channel4_IRQHandler
.thumb_set DMA1_Channel4_IRQHandler,Default_Handler

.weak  DMA1_Channel5_IRQHandler
.thumb_set DMA1_Channel5_IRQHandler,Default_Handler

.weak  DMA1_Channel6_IRQHandler
.thumb_set DMA1_Channel6_IRQHandler,Default_Handler

.weak  DMA1_Channel7_IRQHandler
.thumb_set DMA1_Channel7_IRQHandler,Default_Handler

.weak  ADC1_2_IRQHandler
.thumb_set ADC1_2_IRQHandler,Default_Handler

.weak  USB_HP_CAN1_TX_IRQHandler
.thumb_set USB_HP_CAN1_TX_IRQHandler,Default_Handler

.weak  USB_LP_CAN1_RX0_IRQHandler
.thumb_set USB_LP_CAN1_RX0_IRQHandler,Default_Handler

.weak  CAN1_RX1_IRQHandler
.thumb_set CAN1_RX1_IRQHandler,Default_Handler

.weak  CAN1_SCE_IRQHandler
.thumb_set CAN1_SCE_IRQHandler,Default_Handler

.weak  EXTI9_5_IRQHandler
.thumb_set EXTI9_5_IRQHandler,Default_Handler

.weak  TIM1_BRK_IRQHandler
.thumb_set TIM1_BRK_IRQHandler,Default_Handler

.weak  TIM1_UP_IRQHandler
.thumb_set TIM1_UP_IRQHandler,Default_Handler

.weak  TIM1_TRG_COM_IRQHandler
.thumb_set TIM1_TRG_COM_IRQHandler,Default_Handler

.weak  TIM1_CC_IRQHandler
.thumb_set TIM1_CC_IRQHandler,Default_Handler

.weak  TIM2_IRQHandler
.thumb_set TIM2_IRQHandler,Default_Handler

.weak  TIM3_IRQHandler
.thumb_set TIM3_IRQHandler,Default_Handler

.weak  TIM4_IRQHandler
.thumb_set TIM4_IRQHandler,Default_Handler

.weak  I2C1_EV_IRQHandler
.thumb_set I2C1_EV_IRQHandler,Default_Handler

.weak  I2C1_ER_IRQHandler
.thumb_set I2C1_ER_IRQHandler,Default_Handler

.weak  I2C2_EV_IRQHandler
.thumb_set I2C2_EV_IRQHandler,Default_Handler

.weak  I2C2_ER_IRQHandler
.thumb_set I2C2_ER_IRQHandler,Default_Handler

.weak  SPI1_IRQHandler
.thumb_set SPI1_IRQHandler,Default_Handler

.weak  SPI2_IRQHandler
.thumb_set SPI2_IRQHandler,Default_Handler

.weak  USART1_IRQHandler
.thumb_set USART1_IRQHandler,Default_Handler

.weak  USART2_IRQHandler
.thumb_set USART2_IRQHandler,Default_Handler

.weak  USART3_IRQHandler
.thumb_set USART3_IRQHandler,Default_Handler

.weak  EXTI15_10_IRQHandler
.thumb_set EXTI15_10_IRQHandler,Default_Handler

.weak  RTCAlarm_IRQHandler
.thumb_set RTCAlarm_IRQHandler,Default_Handler

.weak  USBWakeUp_IRQHandler
.thumb_set USBWakeUp_IRQHandler,Default_Handler

.weak  TIM8_BRK_IRQHandler
.thumb_set TIM8_BRK_IRQHandler,Default_Handler

.weak  TIM8_UP_IRQHandler
.thumb_set TIM8_UP_IRQHandler,Default_Handler

.weak  TIM8_TRG_COM_IRQHandler
.thumb_set TIM8_TRG_COM_IRQHandler,Default_Handler

.weak  TIM8_CC_IRQHandler
.thumb_set TIM8_CC_IRQHandler,Default_Handler

.weak  ADC3_IRQHandler
.thumb_set ADC3_IRQHandler,Default_Handler

.weak  FSMC_IRQHandler
.thumb_set FSMC_IRQHandler,Default_Handler

.weak  SDIO_IRQHandler
.thumb_set SDIO_IRQHandler,Default_Handler

.weak  TIM5_IRQHandler
.thumb_set TIM5_IRQHandler,Default_Handler

.weak  SPI3_IRQHandler
.thumb_set SPI3_IRQHandler,Default_Handler

.weak  UART4_IRQHandler
.thumb_set UART4_IRQHandler,Default_Handler

.weak  UART5_IRQHandler
.thumb_set UART5_IRQHandler,Default_Handler

.weak  TIM6_IRQHandler
.thumb_set TIM6_IRQHandler,Default_Handler

.weak  TIM7_IRQHandler
.thumb_set TIM7_IRQHandler,Default_Handler

.weak  DMA2_Channel1_IRQHandler
.thumb_set DMA2_Channel1_IRQHandler,Default_Handler

.weak  DMA2_Channel2_IRQHandler
.thumb_set DMA2_Channel2_IRQHandler,Default_Handler

.weak  DMA2_Channel3_IRQHandler
.thumb_set DMA2_Channel3_IRQHandler,Default_Handler

.weak  DMA2_Channel4_5_IRQHandler
.thumb_set DMA2_Channel4_5_IRQHandler,Default_Handler
```


#### STM32 芯片命名规则

{{< img src="stm32-name-rules.svg" scroll-x="true" >}}

#### 启动文件后缀

{{< img src="stm32-startup.svg" scroll-x="true" >}}






### stm32f10x.h

`stm32f10x.h` 文件很长，以下截取部分关键代码：

{{< bar title="Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/stm32f10x.h" >}}

```c { class="fixed-height" lineNos=inline }
#ifndef __STM32F10x_H
#define __STM32F10x_H

#ifdef __cplusplus
    extern "C" {
#endif
  
// 选择目标设备，这里的宏需要用户自己在代码中定义，或者通过编译器参数传递如 -D STM32F10X_HD
#if !defined (STM32F10X_LD) && !defined (STM32F10X_LD_VL) && !defined (STM32F10X_MD) && !defined (STM32F10X_MD_VL) && !defined (STM32F10X_HD) && !defined (STM32F10X_HD_VL) && !defined (STM32F10X_XL) && !defined (STM32F10X_CL) 
    // #define STM32F10X_LD
    // #define STM32F10X_LD_VL
    // #define STM32F10X_MD
    // #define STM32F10X_MD_VL
    // #define STM32F10X_HD
    // #define STM32F10X_HD_VL
    // #define STM32F10X_XL
    // #define STM32F10X_CL
#endif


// 如果没有定义目标设备，这里会报错
#if !defined (STM32F10X_LD) && !defined (STM32F10X_LD_VL) && !defined (STM32F10X_MD) && !defined (STM32F10X_MD_VL) && !defined (STM32F10X_HD) && !defined (STM32F10X_HD_VL) && !defined (STM32F10X_XL) && !defined (STM32F10X_CL)
    #error "Please select first the target STM32F10x device used in your application (in stm32f10x.h file)"
#endif


// 是否使用标准库外设驱动
#if !defined  (USE_STDPERIPH_DRIVER)
    #define USE_STDPERIPH_DRIVER
#endif


// 外部晶振频率，在 system_stm32f10x.c 中，系统初始化函数 SystemInit 会设置时钟，需要 HSE_VALUE
#if !defined  HSE_VALUE
    #ifdef STM32F10X_CL   
        #define HSE_VALUE    ((uint32_t)25000000)  // 25 MHz
    #else
        #define HSE_VALUE    ((uint32_t)8000000)   // 8 MHz
    #endif
#endif


// 外部晶振启动的等待时间，当 STM32 尝试启动外部晶振时，需要等待晶振稳定
#if !defined  (HSE_STARTUP_TIMEOUT) 
    #define HSE_STARTUP_TIMEOUT    ((uint16_t)0x0500)  // 这只是大致的一个计数值，约 0.5 秒
#endif


// 内部晶振频率
#if !defined  (HSI_VALUE)   
    #define HSI_VALUE    ((uint32_t)8000000)    // 8 MHz
#endif


// 定义标准库版本 V3.6.4
#define __STM32F10X_STDPERIPH_VERSION_MAIN   (0x03) // [31:24] main version
#define __STM32F10X_STDPERIPH_VERSION_SUB1   (0x06) // [23:16] sub1 version
#define __STM32F10X_STDPERIPH_VERSION_SUB2   (0x04) // [15:8]  sub2 version
#define __STM32F10X_STDPERIPH_VERSION_RC     (0x00) // [7:0]   release candidate
#define __STM32F10X_STDPERIPH_VERSION        ((__STM32F10X_STDPERIPH_VERSION_MAIN << 24)\
                                             |(__STM32F10X_STDPERIPH_VERSION_SUB1 << 16)\
                                             |(__STM32F10X_STDPERIPH_VERSION_SUB2 << 8)\
                                             |(__STM32F10X_STDPERIPH_VERSION_RC))


// CM3 处理器与内核系统组件配置
#ifdef STM32F10X_XL
    #define __MPU_PRESENT             1      // STM32 超大容量设备包含 MPU
#else
    #define __MPU_PRESENT             0      // 其它设备不含 MPU
#endif

#define __CM3_REV                 0x0200     // 内核修订版本 r2p0
#define __NVIC_PRIO_BITS          4          // 4 Bits 优先级位宽
#define __Vendor_SysTickConfig    0          // 针对特定厂商的 SysTick 配置？不太清楚



// CM3 的中断源编号从 1 开始，1 - 15 是系统异常，16 - 255 是外部中断
// 枚举值使用负数，是为了区分系统异常与外部中断，提升部分函数效率，如 core_cm3.h 中的 NVIC_SetPriority 函数
typedef enum IRQn
{
/************************  系统异常枚举值   *******************************************************/
  NonMaskableInt_IRQn         = -14,    /*!< 2 Non Maskable Interrupt                             */
  MemoryManagement_IRQn       = -12,    /*!< 4 Cortex-M3 Memory Management Interrupt              */
  BusFault_IRQn               = -11,    /*!< 5 Cortex-M3 Bus Fault Interrupt                      */
  UsageFault_IRQn             = -10,    /*!< 6 Cortex-M3 Usage Fault Interrupt                    */
  SVCall_IRQn                 = -5,     /*!< 11 Cortex-M3 SV Call Interrupt                       */
  DebugMonitor_IRQn           = -4,     /*!< 12 Cortex-M3 Debug Monitor Interrupt                 */
  PendSV_IRQn                 = -2,     /*!< 14 Cortex-M3 Pend SV Interrupt                       */
  SysTick_IRQn                = -1,     /*!< 15 Cortex-M3 System Tick Interrupt                   */

/************************  外部中断枚举值   *******************************************************/
  WWDG_IRQn                   = 0,      /*!< Window WatchDog Interrupt                            */
  PVD_IRQn                    = 1,      /*!< PVD through EXTI Line detection Interrupt            */
  TAMPER_IRQn                 = 2,      /*!< Tamper Interrupt                                     */
  RTC_IRQn                    = 3,      /*!< RTC global Interrupt                                 */
  FLASH_IRQn                  = 4,      /*!< FLASH global Interrupt                               */
  RCC_IRQn                    = 5,      /*!< RCC global Interrupt                                 */
  EXTI0_IRQn                  = 6,      /*!< EXTI Line0 Interrupt                                 */
  EXTI1_IRQn                  = 7,      /*!< EXTI Line1 Interrupt                                 */
  EXTI2_IRQn                  = 8,      /*!< EXTI Line2 Interrupt                                 */
  EXTI3_IRQn                  = 9,      /*!< EXTI Line3 Interrupt                                 */
  EXTI4_IRQn                  = 10,     /*!< EXTI Line4 Interrupt                                 */
  DMA1_Channel1_IRQn          = 11,     /*!< DMA1 Channel 1 global Interrupt                      */
  DMA1_Channel2_IRQn          = 12,     /*!< DMA1 Channel 2 global Interrupt                      */
  DMA1_Channel3_IRQn          = 13,     /*!< DMA1 Channel 3 global Interrupt                      */
  DMA1_Channel4_IRQn          = 14,     /*!< DMA1 Channel 4 global Interrupt                      */
  DMA1_Channel5_IRQn          = 15,     /*!< DMA1 Channel 5 global Interrupt                      */
  DMA1_Channel6_IRQn          = 16,     /*!< DMA1 Channel 6 global Interrupt                      */
  DMA1_Channel7_IRQn          = 17,     /*!< DMA1 Channel 7 global Interrupt                      */

#ifdef STM32F10X_LD
  ADC1_2_IRQn                 = 18,     /*!< ADC1 and ADC2 global Interrupt                       */
  USB_HP_CAN1_TX_IRQn         = 19,     /*!< USB Device High Priority or CAN1 TX Interrupts       */
  USB_LP_CAN1_RX0_IRQn        = 20,     /*!< USB Device Low Priority or CAN1 RX0 Interrupts       */
  CAN1_RX1_IRQn               = 21,     /*!< CAN1 RX1 Interrupt                                   */
  CAN1_SCE_IRQn               = 22,     /*!< CAN1 SCE Interrupt                                   */
  EXTI9_5_IRQn                = 23,     /*!< External Line[9:5] Interrupts                        */
  TIM1_BRK_IRQn               = 24,     /*!< TIM1 Break Interrupt                                 */
  TIM1_UP_IRQn                = 25,     /*!< TIM1 Update Interrupt                                */
  TIM1_TRG_COM_IRQn           = 26,     /*!< TIM1 Trigger and Commutation Interrupt               */
  TIM1_CC_IRQn                = 27,     /*!< TIM1 Capture Compare Interrupt                       */
  TIM2_IRQn                   = 28,     /*!< TIM2 global Interrupt                                */
  TIM3_IRQn                   = 29,     /*!< TIM3 global Interrupt                                */
  I2C1_EV_IRQn                = 31,     /*!< I2C1 Event Interrupt                                 */
  I2C1_ER_IRQn                = 32,     /*!< I2C1 Error Interrupt                                 */
  SPI1_IRQn                   = 35,     /*!< SPI1 global Interrupt                                */
  USART1_IRQn                 = 37,     /*!< USART1 global Interrupt                              */
  USART2_IRQn                 = 38,     /*!< USART2 global Interrupt                              */
  EXTI15_10_IRQn              = 40,     /*!< External Line[15:10] Interrupts                      */
  RTCAlarm_IRQn               = 41,     /*!< RTC Alarm through EXTI Line Interrupt                */
  USBWakeUp_IRQn              = 42      /*!< USB Device WakeUp from suspend through EXTI Line Interrupt */
#endif /* STM32F10X_LD */  

#ifdef STM32F10X_LD_VL
  ADC1_IRQn                   = 18,     /*!< ADC1 global Interrupt                                */
  EXTI9_5_IRQn                = 23,     /*!< External Line[9:5] Interrupts                        */
  TIM1_BRK_TIM15_IRQn         = 24,     /*!< TIM1 Break and TIM15 Interrupts                      */
  TIM1_UP_TIM16_IRQn          = 25,     /*!< TIM1 Update and TIM16 Interrupts                     */
  TIM1_TRG_COM_TIM17_IRQn     = 26,     /*!< TIM1 Trigger and Commutation and TIM17 Interrupt     */
  TIM1_CC_IRQn                = 27,     /*!< TIM1 Capture Compare Interrupt                       */
  TIM2_IRQn                   = 28,     /*!< TIM2 global Interrupt                                */
  TIM3_IRQn                   = 29,     /*!< TIM3 global Interrupt                                */
  I2C1_EV_IRQn                = 31,     /*!< I2C1 Event Interrupt                                 */
  I2C1_ER_IRQn                = 32,     /*!< I2C1 Error Interrupt                                 */
  SPI1_IRQn                   = 35,     /*!< SPI1 global Interrupt                                */
  USART1_IRQn                 = 37,     /*!< USART1 global Interrupt                              */
  USART2_IRQn                 = 38,     /*!< USART2 global Interrupt                              */
  EXTI15_10_IRQn              = 40,     /*!< External Line[15:10] Interrupts                      */
  RTCAlarm_IRQn               = 41,     /*!< RTC Alarm through EXTI Line Interrupt                */
  CEC_IRQn                    = 42,     /*!< HDMI-CEC Interrupt                                   */
  TIM6_DAC_IRQn               = 54,     /*!< TIM6 and DAC underrun Interrupt                      */
  TIM7_IRQn                   = 55      /*!< TIM7 Interrupt                                       */
#endif /* STM32F10X_LD_VL */

#ifdef STM32F10X_MD
  ADC1_2_IRQn                 = 18,     /*!< ADC1 and ADC2 global Interrupt                       */
  USB_HP_CAN1_TX_IRQn         = 19,     /*!< USB Device High Priority or CAN1 TX Interrupts       */
  USB_LP_CAN1_RX0_IRQn        = 20,     /*!< USB Device Low Priority or CAN1 RX0 Interrupts       */
  CAN1_RX1_IRQn               = 21,     /*!< CAN1 RX1 Interrupt                                   */
  CAN1_SCE_IRQn               = 22,     /*!< CAN1 SCE Interrupt                                   */
  EXTI9_5_IRQn                = 23,     /*!< External Line[9:5] Interrupts                        */
  TIM1_BRK_IRQn               = 24,     /*!< TIM1 Break Interrupt                                 */
  TIM1_UP_IRQn                = 25,     /*!< TIM1 Update Interrupt                                */
  TIM1_TRG_COM_IRQn           = 26,     /*!< TIM1 Trigger and Commutation Interrupt               */
  TIM1_CC_IRQn                = 27,     /*!< TIM1 Capture Compare Interrupt                       */
  TIM2_IRQn                   = 28,     /*!< TIM2 global Interrupt                                */
  TIM3_IRQn                   = 29,     /*!< TIM3 global Interrupt                                */
  TIM4_IRQn                   = 30,     /*!< TIM4 global Interrupt                                */
  I2C1_EV_IRQn                = 31,     /*!< I2C1 Event Interrupt                                 */
  I2C1_ER_IRQn                = 32,     /*!< I2C1 Error Interrupt                                 */
  I2C2_EV_IRQn                = 33,     /*!< I2C2 Event Interrupt                                 */
  I2C2_ER_IRQn                = 34,     /*!< I2C2 Error Interrupt                                 */
  SPI1_IRQn                   = 35,     /*!< SPI1 global Interrupt                                */
  SPI2_IRQn                   = 36,     /*!< SPI2 global Interrupt                                */
  USART1_IRQn                 = 37,     /*!< USART1 global Interrupt                              */
  USART2_IRQn                 = 38,     /*!< USART2 global Interrupt                              */
  USART3_IRQn                 = 39,     /*!< USART3 global Interrupt                              */
  EXTI15_10_IRQn              = 40,     /*!< External Line[15:10] Interrupts                      */
  RTCAlarm_IRQn               = 41,     /*!< RTC Alarm through EXTI Line Interrupt                */
  USBWakeUp_IRQn              = 42      /*!< USB Device WakeUp from suspend through EXTI Line Interrupt */
#endif /* STM32F10X_MD */  

#ifdef STM32F10X_MD_VL
  ADC1_IRQn                   = 18,     /*!< ADC1 global Interrupt                                */
  EXTI9_5_IRQn                = 23,     /*!< External Line[9:5] Interrupts                        */
  TIM1_BRK_TIM15_IRQn         = 24,     /*!< TIM1 Break and TIM15 Interrupts                      */
  TIM1_UP_TIM16_IRQn          = 25,     /*!< TIM1 Update and TIM16 Interrupts                     */
  TIM1_TRG_COM_TIM17_IRQn     = 26,     /*!< TIM1 Trigger and Commutation and TIM17 Interrupt     */
  TIM1_CC_IRQn                = 27,     /*!< TIM1 Capture Compare Interrupt                       */
  TIM2_IRQn                   = 28,     /*!< TIM2 global Interrupt                                */
  TIM3_IRQn                   = 29,     /*!< TIM3 global Interrupt                                */
  TIM4_IRQn                   = 30,     /*!< TIM4 global Interrupt                                */
  I2C1_EV_IRQn                = 31,     /*!< I2C1 Event Interrupt                                 */
  I2C1_ER_IRQn                = 32,     /*!< I2C1 Error Interrupt                                 */
  I2C2_EV_IRQn                = 33,     /*!< I2C2 Event Interrupt                                 */
  I2C2_ER_IRQn                = 34,     /*!< I2C2 Error Interrupt                                 */
  SPI1_IRQn                   = 35,     /*!< SPI1 global Interrupt                                */
  SPI2_IRQn                   = 36,     /*!< SPI2 global Interrupt                                */
  USART1_IRQn                 = 37,     /*!< USART1 global Interrupt                              */
  USART2_IRQn                 = 38,     /*!< USART2 global Interrupt                              */
  USART3_IRQn                 = 39,     /*!< USART3 global Interrupt                              */
  EXTI15_10_IRQn              = 40,     /*!< External Line[15:10] Interrupts                      */
  RTCAlarm_IRQn               = 41,     /*!< RTC Alarm through EXTI Line Interrupt                */
  CEC_IRQn                    = 42,     /*!< HDMI-CEC Interrupt                                   */
  TIM6_DAC_IRQn               = 54,     /*!< TIM6 and DAC underrun Interrupt                      */
  TIM7_IRQn                   = 55      /*!< TIM7 Interrupt                                       */
#endif /* STM32F10X_MD_VL */

#ifdef STM32F10X_HD
  ADC1_2_IRQn                 = 18,     /*!< ADC1 and ADC2 global Interrupt                       */
  USB_HP_CAN1_TX_IRQn         = 19,     /*!< USB Device High Priority or CAN1 TX Interrupts       */
  USB_LP_CAN1_RX0_IRQn        = 20,     /*!< USB Device Low Priority or CAN1 RX0 Interrupts       */
  CAN1_RX1_IRQn               = 21,     /*!< CAN1 RX1 Interrupt                                   */
  CAN1_SCE_IRQn               = 22,     /*!< CAN1 SCE Interrupt                                   */
  EXTI9_5_IRQn                = 23,     /*!< External Line[9:5] Interrupts                        */
  TIM1_BRK_IRQn               = 24,     /*!< TIM1 Break Interrupt                                 */
  TIM1_UP_IRQn                = 25,     /*!< TIM1 Update Interrupt                                */
  TIM1_TRG_COM_IRQn           = 26,     /*!< TIM1 Trigger and Commutation Interrupt               */
  TIM1_CC_IRQn                = 27,     /*!< TIM1 Capture Compare Interrupt                       */
  TIM2_IRQn                   = 28,     /*!< TIM2 global Interrupt                                */
  TIM3_IRQn                   = 29,     /*!< TIM3 global Interrupt                                */
  TIM4_IRQn                   = 30,     /*!< TIM4 global Interrupt                                */
  I2C1_EV_IRQn                = 31,     /*!< I2C1 Event Interrupt                                 */
  I2C1_ER_IRQn                = 32,     /*!< I2C1 Error Interrupt                                 */
  I2C2_EV_IRQn                = 33,     /*!< I2C2 Event Interrupt                                 */
  I2C2_ER_IRQn                = 34,     /*!< I2C2 Error Interrupt                                 */
  SPI1_IRQn                   = 35,     /*!< SPI1 global Interrupt                                */
  SPI2_IRQn                   = 36,     /*!< SPI2 global Interrupt                                */
  USART1_IRQn                 = 37,     /*!< USART1 global Interrupt                              */
  USART2_IRQn                 = 38,     /*!< USART2 global Interrupt                              */
  USART3_IRQn                 = 39,     /*!< USART3 global Interrupt                              */
  EXTI15_10_IRQn              = 40,     /*!< External Line[15:10] Interrupts                      */
  RTCAlarm_IRQn               = 41,     /*!< RTC Alarm through EXTI Line Interrupt                */
  USBWakeUp_IRQn              = 42,     /*!< USB Device WakeUp from suspend through EXTI Line Interrupt */
  TIM8_BRK_IRQn               = 43,     /*!< TIM8 Break Interrupt                                 */
  TIM8_UP_IRQn                = 44,     /*!< TIM8 Update Interrupt                                */
  TIM8_TRG_COM_IRQn           = 45,     /*!< TIM8 Trigger and Commutation Interrupt               */
  TIM8_CC_IRQn                = 46,     /*!< TIM8 Capture Compare Interrupt                       */
  ADC3_IRQn                   = 47,     /*!< ADC3 global Interrupt                                */
  FSMC_IRQn                   = 48,     /*!< FSMC global Interrupt                                */
  SDIO_IRQn                   = 49,     /*!< SDIO global Interrupt                                */
  TIM5_IRQn                   = 50,     /*!< TIM5 global Interrupt                                */
  SPI3_IRQn                   = 51,     /*!< SPI3 global Interrupt                                */
  UART4_IRQn                  = 52,     /*!< UART4 global Interrupt                               */
  UART5_IRQn                  = 53,     /*!< UART5 global Interrupt                               */
  TIM6_IRQn                   = 54,     /*!< TIM6 global Interrupt                                */
  TIM7_IRQn                   = 55,     /*!< TIM7 global Interrupt                                */
  DMA2_Channel1_IRQn          = 56,     /*!< DMA2 Channel 1 global Interrupt                      */
  DMA2_Channel2_IRQn          = 57,     /*!< DMA2 Channel 2 global Interrupt                      */
  DMA2_Channel3_IRQn          = 58,     /*!< DMA2 Channel 3 global Interrupt                      */
  DMA2_Channel4_5_IRQn        = 59      /*!< DMA2 Channel 4 and Channel 5 global Interrupt        */
#endif /* STM32F10X_HD */  

#ifdef STM32F10X_HD_VL
  ADC1_IRQn                   = 18,     /*!< ADC1 global Interrupt                                */
  EXTI9_5_IRQn                = 23,     /*!< External Line[9:5] Interrupts                        */
  TIM1_BRK_TIM15_IRQn         = 24,     /*!< TIM1 Break and TIM15 Interrupts                      */
  TIM1_UP_TIM16_IRQn          = 25,     /*!< TIM1 Update and TIM16 Interrupts                     */
  TIM1_TRG_COM_TIM17_IRQn     = 26,     /*!< TIM1 Trigger and Commutation and TIM17 Interrupt     */
  TIM1_CC_IRQn                = 27,     /*!< TIM1 Capture Compare Interrupt                       */
  TIM2_IRQn                   = 28,     /*!< TIM2 global Interrupt                                */
  TIM3_IRQn                   = 29,     /*!< TIM3 global Interrupt                                */
  TIM4_IRQn                   = 30,     /*!< TIM4 global Interrupt                                */
  I2C1_EV_IRQn                = 31,     /*!< I2C1 Event Interrupt                                 */
  I2C1_ER_IRQn                = 32,     /*!< I2C1 Error Interrupt                                 */
  I2C2_EV_IRQn                = 33,     /*!< I2C2 Event Interrupt                                 */
  I2C2_ER_IRQn                = 34,     /*!< I2C2 Error Interrupt                                 */
  SPI1_IRQn                   = 35,     /*!< SPI1 global Interrupt                                */
  SPI2_IRQn                   = 36,     /*!< SPI2 global Interrupt                                */
  USART1_IRQn                 = 37,     /*!< USART1 global Interrupt                              */
  USART2_IRQn                 = 38,     /*!< USART2 global Interrupt                              */
  USART3_IRQn                 = 39,     /*!< USART3 global Interrupt                              */
  EXTI15_10_IRQn              = 40,     /*!< External Line[15:10] Interrupts                      */
  RTCAlarm_IRQn               = 41,     /*!< RTC Alarm through EXTI Line Interrupt                */
  CEC_IRQn                    = 42,     /*!< HDMI-CEC Interrupt                                   */
  TIM12_IRQn                  = 43,     /*!< TIM12 global Interrupt                               */
  TIM13_IRQn                  = 44,     /*!< TIM13 global Interrupt                               */
  TIM14_IRQn                  = 45,     /*!< TIM14 global Interrupt                               */
  TIM5_IRQn                   = 50,     /*!< TIM5 global Interrupt                                */
  SPI3_IRQn                   = 51,     /*!< SPI3 global Interrupt                                */
  UART4_IRQn                  = 52,     /*!< UART4 global Interrupt                               */
  UART5_IRQn                  = 53,     /*!< UART5 global Interrupt                               */
  TIM6_DAC_IRQn               = 54,     /*!< TIM6 and DAC underrun Interrupt                      */
  TIM7_IRQn                   = 55,     /*!< TIM7 Interrupt                                       */
  DMA2_Channel1_IRQn          = 56,     /*!< DMA2 Channel 1 global Interrupt                      */
  DMA2_Channel2_IRQn          = 57,     /*!< DMA2 Channel 2 global Interrupt                      */
  DMA2_Channel3_IRQn          = 58,     /*!< DMA2 Channel 3 global Interrupt                      */
  DMA2_Channel4_5_IRQn        = 59,     /*!< DMA2 Channel 4 and Channel 5 global Interrupt        */
  DMA2_Channel5_IRQn          = 60      /*!< DMA2 Channel 5 global Interrupt (DMA2 Channel 5 is 
                                             mapped at position 60 only if the MISC_REMAP bit in 
                                             the AFIO_MAPR2 register is set)                      */
#endif /* STM32F10X_HD_VL */

#ifdef STM32F10X_XL
  ADC1_2_IRQn                 = 18,     /*!< ADC1 and ADC2 global Interrupt                       */
  USB_HP_CAN1_TX_IRQn         = 19,     /*!< USB Device High Priority or CAN1 TX Interrupts       */
  USB_LP_CAN1_RX0_IRQn        = 20,     /*!< USB Device Low Priority or CAN1 RX0 Interrupts       */
  CAN1_RX1_IRQn               = 21,     /*!< CAN1 RX1 Interrupt                                   */
  CAN1_SCE_IRQn               = 22,     /*!< CAN1 SCE Interrupt                                   */
  EXTI9_5_IRQn                = 23,     /*!< External Line[9:5] Interrupts                        */
  TIM1_BRK_TIM9_IRQn          = 24,     /*!< TIM1 Break Interrupt and TIM9 global Interrupt       */
  TIM1_UP_TIM10_IRQn          = 25,     /*!< TIM1 Update Interrupt and TIM10 global Interrupt     */
  TIM1_TRG_COM_TIM11_IRQn     = 26,     /*!< TIM1 Trigger and Commutation Interrupt and TIM11 global interrupt */
  TIM1_CC_IRQn                = 27,     /*!< TIM1 Capture Compare Interrupt                       */
  TIM2_IRQn                   = 28,     /*!< TIM2 global Interrupt                                */
  TIM3_IRQn                   = 29,     /*!< TIM3 global Interrupt                                */
  TIM4_IRQn                   = 30,     /*!< TIM4 global Interrupt                                */
  I2C1_EV_IRQn                = 31,     /*!< I2C1 Event Interrupt                                 */
  I2C1_ER_IRQn                = 32,     /*!< I2C1 Error Interrupt                                 */
  I2C2_EV_IRQn                = 33,     /*!< I2C2 Event Interrupt                                 */
  I2C2_ER_IRQn                = 34,     /*!< I2C2 Error Interrupt                                 */
  SPI1_IRQn                   = 35,     /*!< SPI1 global Interrupt                                */
  SPI2_IRQn                   = 36,     /*!< SPI2 global Interrupt                                */
  USART1_IRQn                 = 37,     /*!< USART1 global Interrupt                              */
  USART2_IRQn                 = 38,     /*!< USART2 global Interrupt                              */
  USART3_IRQn                 = 39,     /*!< USART3 global Interrupt                              */
  EXTI15_10_IRQn              = 40,     /*!< External Line[15:10] Interrupts                      */
  RTCAlarm_IRQn               = 41,     /*!< RTC Alarm through EXTI Line Interrupt                */
  USBWakeUp_IRQn              = 42,     /*!< USB Device WakeUp from suspend through EXTI Line Interrupt */
  TIM8_BRK_TIM12_IRQn         = 43,     /*!< TIM8 Break Interrupt and TIM12 global Interrupt      */
  TIM8_UP_TIM13_IRQn          = 44,     /*!< TIM8 Update Interrupt and TIM13 global Interrupt     */
  TIM8_TRG_COM_TIM14_IRQn     = 45,     /*!< TIM8 Trigger and Commutation Interrupt and TIM14 global interrupt */
  TIM8_CC_IRQn                = 46,     /*!< TIM8 Capture Compare Interrupt                       */
  ADC3_IRQn                   = 47,     /*!< ADC3 global Interrupt                                */
  FSMC_IRQn                   = 48,     /*!< FSMC global Interrupt                                */
  SDIO_IRQn                   = 49,     /*!< SDIO global Interrupt                                */
  TIM5_IRQn                   = 50,     /*!< TIM5 global Interrupt                                */
  SPI3_IRQn                   = 51,     /*!< SPI3 global Interrupt                                */
  UART4_IRQn                  = 52,     /*!< UART4 global Interrupt                               */
  UART5_IRQn                  = 53,     /*!< UART5 global Interrupt                               */
  TIM6_IRQn                   = 54,     /*!< TIM6 global Interrupt                                */
  TIM7_IRQn                   = 55,     /*!< TIM7 global Interrupt                                */
  DMA2_Channel1_IRQn          = 56,     /*!< DMA2 Channel 1 global Interrupt                      */
  DMA2_Channel2_IRQn          = 57,     /*!< DMA2 Channel 2 global Interrupt                      */
  DMA2_Channel3_IRQn          = 58,     /*!< DMA2 Channel 3 global Interrupt                      */
  DMA2_Channel4_5_IRQn        = 59      /*!< DMA2 Channel 4 and Channel 5 global Interrupt        */
#endif /* STM32F10X_XL */  

#ifdef STM32F10X_CL
  ADC1_2_IRQn                 = 18,     /*!< ADC1 and ADC2 global Interrupt                       */
  CAN1_TX_IRQn                = 19,     /*!< USB Device High Priority or CAN1 TX Interrupts       */
  CAN1_RX0_IRQn               = 20,     /*!< USB Device Low Priority or CAN1 RX0 Interrupts       */
  CAN1_RX1_IRQn               = 21,     /*!< CAN1 RX1 Interrupt                                   */
  CAN1_SCE_IRQn               = 22,     /*!< CAN1 SCE Interrupt                                   */
  EXTI9_5_IRQn                = 23,     /*!< External Line[9:5] Interrupts                        */
  TIM1_BRK_IRQn               = 24,     /*!< TIM1 Break Interrupt                                 */
  TIM1_UP_IRQn                = 25,     /*!< TIM1 Update Interrupt                                */
  TIM1_TRG_COM_IRQn           = 26,     /*!< TIM1 Trigger and Commutation Interrupt               */
  TIM1_CC_IRQn                = 27,     /*!< TIM1 Capture Compare Interrupt                       */
  TIM2_IRQn                   = 28,     /*!< TIM2 global Interrupt                                */
  TIM3_IRQn                   = 29,     /*!< TIM3 global Interrupt                                */
  TIM4_IRQn                   = 30,     /*!< TIM4 global Interrupt                                */
  I2C1_EV_IRQn                = 31,     /*!< I2C1 Event Interrupt                                 */
  I2C1_ER_IRQn                = 32,     /*!< I2C1 Error Interrupt                                 */
  I2C2_EV_IRQn                = 33,     /*!< I2C2 Event Interrupt                                 */
  I2C2_ER_IRQn                = 34,     /*!< I2C2 Error Interrupt                                 */
  SPI1_IRQn                   = 35,     /*!< SPI1 global Interrupt                                */
  SPI2_IRQn                   = 36,     /*!< SPI2 global Interrupt                                */
  USART1_IRQn                 = 37,     /*!< USART1 global Interrupt                              */
  USART2_IRQn                 = 38,     /*!< USART2 global Interrupt                              */
  USART3_IRQn                 = 39,     /*!< USART3 global Interrupt                              */
  EXTI15_10_IRQn              = 40,     /*!< External Line[15:10] Interrupts                      */
  RTCAlarm_IRQn               = 41,     /*!< RTC Alarm through EXTI Line Interrupt                */
  OTG_FS_WKUP_IRQn            = 42,     /*!< USB OTG FS WakeUp from suspend through EXTI Line Interrupt */
  TIM5_IRQn                   = 50,     /*!< TIM5 global Interrupt                                */
  SPI3_IRQn                   = 51,     /*!< SPI3 global Interrupt                                */
  UART4_IRQn                  = 52,     /*!< UART4 global Interrupt                               */
  UART5_IRQn                  = 53,     /*!< UART5 global Interrupt                               */
  TIM6_IRQn                   = 54,     /*!< TIM6 global Interrupt                                */
  TIM7_IRQn                   = 55,     /*!< TIM7 global Interrupt                                */
  DMA2_Channel1_IRQn          = 56,     /*!< DMA2 Channel 1 global Interrupt                      */
  DMA2_Channel2_IRQn          = 57,     /*!< DMA2 Channel 2 global Interrupt                      */
  DMA2_Channel3_IRQn          = 58,     /*!< DMA2 Channel 3 global Interrupt                      */
  DMA2_Channel4_IRQn          = 59,     /*!< DMA2 Channel 4 global Interrupt                      */
  DMA2_Channel5_IRQn          = 60,     /*!< DMA2 Channel 5 global Interrupt                      */
  ETH_IRQn                    = 61,     /*!< Ethernet global Interrupt                            */
  ETH_WKUP_IRQn               = 62,     /*!< Ethernet Wakeup through EXTI line Interrupt          */
  CAN2_TX_IRQn                = 63,     /*!< CAN2 TX Interrupt                                    */
  CAN2_RX0_IRQn               = 64,     /*!< CAN2 RX0 Interrupt                                   */
  CAN2_RX1_IRQn               = 65,     /*!< CAN2 RX1 Interrupt                                   */
  CAN2_SCE_IRQn               = 66,     /*!< CAN2 SCE Interrupt                                   */
  OTG_FS_IRQn                 = 67      /*!< USB OTG FS global Interrupt                          */
#endif /* STM32F10X_CL */
} IRQn_Type;


#include "core_cm3.h"
#include "system_stm32f10x.h"
#include <stdint.h>


// 后面都是外设的寄存器结构体 / 外设地址的定义，很长，就省略了...

省略...

typedef struct
{
  __IO uint32_t CRL;
  __IO uint32_t CRH;
  __IO uint32_t IDR;
  __IO uint32_t ODR;
  __IO uint32_t BSRR;
  __IO uint32_t BRR;
  __IO uint32_t LCKR;
} GPIO_TypeDef;

省略...
#define FLASH_BASE            ((uint32_t)0x08000000)
#define SRAM_BASE             ((uint32_t)0x20000000)

#define APB1PERIPH_BASE       PERIPH_BASE
#define APB2PERIPH_BASE       (PERIPH_BASE + 0x10000)
#define AHBPERIPH_BASE        (PERIPH_BASE + 0x20000)

省略...

#define GPIOA_BASE            (APB2PERIPH_BASE + 0x0800)
#define GPIOB_BASE            (APB2PERIPH_BASE + 0x0C00)
#define GPIOC_BASE            (APB2PERIPH_BASE + 0x1000)
#define GPIOD_BASE            (APB2PERIPH_BASE + 0x1400)
#define GPIOE_BASE            (APB2PERIPH_BASE + 0x1800)
#define GPIOF_BASE            (APB2PERIPH_BASE + 0x1C00)
#define GPIOG_BASE            (APB2PERIPH_BASE + 0x2000)

省略...

#define GPIOA               ((GPIO_TypeDef *) GPIOA_BASE)
#define GPIOB               ((GPIO_TypeDef *) GPIOB_BASE)
#define GPIOC               ((GPIO_TypeDef *) GPIOC_BASE)
#define GPIOD               ((GPIO_TypeDef *) GPIOD_BASE)
#define GPIOE               ((GPIO_TypeDef *) GPIOE_BASE)
#define GPIOF               ((GPIO_TypeDef *) GPIOF_BASE)
#define GPIOG               ((GPIO_TypeDef *) GPIOG_BASE)

省略...

#ifdef USE_STDPERIPH_DRIVER
    #include "stm32f10x_conf.h"
#endif

省略...
```

#### 预定义宏


```makefile
STM32F10X_LD         : 按启动文件后缀，选择一个
STM32F10X_MD         : 
STM32F10X_HD         : 
STM32F10X_XL         : 
STM32F10X_CL         : 
STM32F10X_LD_VL      : 
STM32F10X_MD_VL      : 
STM32F10X_HD_VL      :
USE_STDPERIPH_DRIVER : 使用标准库外设驱动
HSE_VALUE            : 外部晶振频率
HSE_STARTUP_TIMEOUT  : 外部晶振启动的等待时间
HSI_VALUE            : 内部晶振频率
```
一般不直接在 `stm32f10x.h` 中设置上述宏，而是通过编译器参数传递：

```bash-session
$ arm-none-eabi-gcc -D STM32F10X_HD  -D USE_STDPERIPH_DRIVER  -D HSE_VALUE=8000000
```

#### 头文件包含

```c
#include "core_cm3.h"
#include "system_stm32f10x.h"

#ifdef USE_STDPERIPH_DRIVER
    #include "stm32f10x_conf.h"
#endif
```

`stm32f10x.h` 并不调用 `core_cm3.h` 、`system_stm32f10x.h` 或 `stm32f10x_conf.h` 中的任何函数与宏定义。用户程序只需要包含 `stm32f10x.h`，就可以调用内核/外设函数及宏定义。



### system_stm32f10x.h

{{< bar title="Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/system_stm32f10x.h" >}}

```c { lineNos=inline }

#ifndef __SYSTEM_STM32F10X_H
#define __SYSTEM_STM32F10X_H

#ifdef __cplusplus
 extern "C" {
#endif 

extern uint32_t SystemCoreClock;             // 内核时钟 HCLK 频率，该变量在 system_stm32f10x.c 中定义，用户应用程序可用它来设置 SysTick 定时器或配置其他参数
extern void SystemInit(void);                // 设置系统时钟，该函数在启动文件中会被调用
extern void SystemCoreClockUpdate(void);     // 更新 SystemCoreClock 变量，必须在程序执行期间内核时钟发生变化时调用

#ifdef __cplusplus
}
#endif

#endif
```


### system_stm32f10x.c

{{< bar title="Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/system_stm32f10x.c" >}}

```c { class="fixed-height" lineNos=inline }
#include "stm32f10x.h"


#if defined (STM32F10X_LD_VL) || (defined STM32F10X_MD_VL) || (defined STM32F10X_HD_VL)
    // #define SYSCLK_FREQ_HSE    HSE_VALUE  // 使用 HSE 作为系统时钟源，不进行倍频，最终频率 = HSE_VALUE
    #define SYSCLK_FREQ_24MHz  24000000      // 定义 24MHz 系统时钟频率
#else
    // #define SYSCLK_FREQ_HSE    HSE_VALUE  // 使用 HSE 作为系统时钟源，不进行倍频，最终频率 = HSE_VALUE
    // #define SYSCLK_FREQ_24MHz  24000000   // 定义 24MHz 系统时钟频率
    // #define SYSCLK_FREQ_36MHz  36000000   // 定义 36MHz 系统时钟频率
    // #define SYSCLK_FREQ_48MHz  48000000   // 定义 48MHz 系统时钟频率
    // #define SYSCLK_FREQ_56MHz  56000000   // 定义 56MHz 系统时钟频率
    #define SYSCLK_FREQ_72MHz  72000000      // 定义 72MHz 系统时钟频率
#endif


// 如果需要使用安装在STM3210E-EVAL板（STM32高密度和XL密度设备）
// 或STM32100E-EVAL板（STM32高密度Value line设备）上的外部SRAM作为数据存储器，请取消注释以下行
#if defined (STM32F10X_HD) || (defined STM32F10X_XL) || (defined STM32F10X_HD_VL)
    // #define DATA_IN_ExtSRAM               // 定义使用外部 SRAM
#endif


// 如果需要将向量表重定位到内部SRAM中，请取消注释以下行
// #define VECT_TAB_SRAM                     // 定义向量表在SRAM中
#define VECT_TAB_OFFSET  0x0                 // 向量表基址偏移量字段，此值必须是0x200的倍数


// 时钟定义
#ifdef SYSCLK_FREQ_HSE
  uint32_t SystemCoreClock         = SYSCLK_FREQ_HSE;
#elif defined SYSCLK_FREQ_24MHz
  uint32_t SystemCoreClock         = SYSCLK_FREQ_24MHz;
#elif defined SYSCLK_FREQ_36MHz
  uint32_t SystemCoreClock         = SYSCLK_FREQ_36MHz;
#elif defined SYSCLK_FREQ_48MHz
  uint32_t SystemCoreClock         = SYSCLK_FREQ_48MHz;
#elif defined SYSCLK_FREQ_56MHz
  uint32_t SystemCoreClock         = SYSCLK_FREQ_56MHz;
#elif defined SYSCLK_FREQ_72MHz
  uint32_t SystemCoreClock         = SYSCLK_FREQ_72MHz;
#else
  uint32_t SystemCoreClock         = HSI_VALUE;    // 使用内部晶振频率作为系统时钟频率，HSI_VALUE 在 stm32f10x.h 被定义
#endif


__I uint8_t AHBPrescTable[16] = {0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 6, 7, 8, 9};   // AHB 预分频器表


static void SetSysClock(void);                // 设置系统时钟函数


#ifdef SYSCLK_FREQ_HSE
    static void SetSysClockToHSE(void);       // 设置系统时钟为 HSE
#elif defined SYSCLK_FREQ_24MHz
    static void SetSysClockTo24(void);        // 设置系统时钟为 24MHz
#elif defined SYSCLK_FREQ_36MHz
    static void SetSysClockTo36(void);        // 设置系统时钟为 36MHz
#elif defined SYSCLK_FREQ_48MHz
    static void SetSysClockTo48(void);        // 设置系统时钟为 48MHz
#elif defined SYSCLK_FREQ_56MHz
    static void SetSysClockTo56(void);        // 设置系统时钟为 56MHz
#elif defined SYSCLK_FREQ_72MHz
    static void SetSysClockTo72(void);        // 设置系统时钟为 72MHz
#endif


// DATA_IN_ExtSRAM 由用户定义，用于指示是否将数据段（全局变量、静态变量等）分配到外部 SRAM 中执行
#ifdef DATA_IN_ExtSRAM
    static void SystemInit_ExtMemCtl(void);   // 外部存储器控制器初始化
#endif


void SystemInit (void)
{
    // 将 RCC 时钟配置重置为默认复位状态（用于调试目的）
    // 设置 HSION 位，即使能 HSI （内部时钟源）
    RCC->CR |= (uint32_t)0x00000001;

    // 复位 SW、HPRE、PPRE1、PPRE2、ADCPRE 和 MCO位
#ifndef STM32F10X_CL
	RCC->CFGR &= (uint32_t)0xF8FF0000;
#else
	RCC->CFGR &= (uint32_t)0xF0FF0000;
#endif
  
    // 复位 HSEON、CSSON 和 PLLON 位
    RCC->CR &= (uint32_t)0xFEF6FFFF;
    // 复位HSEBYP位
    RCC->CR &= (uint32_t)0xFFFBFFFF;
    // 复位PLLSRC、PLLXTPRE、PLLMUL 和 USBPRE / OTGFSPRE 位
    RCC->CFGR &= (uint32_t)0xFF80FFFF;

#ifdef STM32F10X_CL
	// 复位 PLL2ON 和 PLL3ON 位
	RCC->CR &= (uint32_t)0xEBFFFFFF;
	// 禁用所有中断并清除挂起位
	RCC->CIR = 0x00FF0000;
	// 复位CFGR2寄存器
	RCC->CFGR2 = 0x00000000;
#elif defined (STM32F10X_LD_VL) || defined (STM32F10X_MD_VL) || (defined STM32F10X_HD_VL)
	// 禁用所有中断并清除挂起位
	RCC->CIR = 0x009F0000;
	// 复位CFGR2寄存器
	RCC->CFGR2 = 0x00000000;      
#else
	// 禁用所有中断并清除挂起位
	RCC->CIR = 0x009F0000;
#endif
    
#if defined (STM32F10X_HD) || (defined STM32F10X_XL) || (defined STM32F10X_HD_VL)
    #ifdef DATA_IN_ExtSRAM
         SystemInit_ExtMemCtl();      // 初始化外部存储器控制器
    #endif
#endif 

    // 配置系统时钟频率、HCLK、PCLK2 和 PCLK1 预分频器
    // 配置 Flash 等待周期并启用预取缓冲区
    SetSysClock();

#ifdef VECT_TAB_SRAM
    SCB->VTOR = SRAM_BASE | VECT_TAB_OFFSET;  // 向量表重定位到内部 SRAM 中
#else
    SCB->VTOR = FLASH_BASE | VECT_TAB_OFFSET; // 向量表重定位到内部 FLASH 中
#endif 
}


// 根据时钟寄存器值更新 SystemCoreClock 变量
void SystemCoreClockUpdate (void) {
	省略...
}


// 设置系统时钟函数，被 SystemInit 函数调用
static void SetSysClock(void)
{
#ifdef SYSCLK_FREQ_HSE
    SetSysClockToHSE();              // 设置系统时钟为HSE
#elif defined SYSCLK_FREQ_24MHz
    SetSysClockTo24();               // 设置系统时钟为24MHz
#elif defined SYSCLK_FREQ_36MHz
    SetSysClockTo36();               // 设置系统时钟为36MHz
#elif defined SYSCLK_FREQ_48MHz
    SetSysClockTo48();               // 设置系统时钟为48MHz
#elif defined SYSCLK_FREQ_56MHz
    SetSysClockTo56();               // 设置系统时钟为56MHz
#elif defined SYSCLK_FREQ_72MHz
    SetSysClockTo72();               // 设置系统时钟为72MHz
#endif                               // 如果上述定义均未启用，则HSI被用作系统时钟源（复位后的默认值）
}


#ifdef DATA_IN_ExtSRAM
// 初始化外部存储器控制器
void SystemInit_ExtMemCtl(void) {
	省略...
}
#endif


#ifdef SYSCLK_FREQ_HSE
static void SetSysClockToHSE(void){ 省略.... }

#elif defined SYSCLK_FREQ_24MHz
static void SetSysClockTo24(void){ 省略.... }

#elif defined SYSCLK_FREQ_36MHz
static void SetSysClockTo36(void){ 省略.... }

#elif defined SYSCLK_FREQ_48MHz
static void SetSysClockTo48(void){ 省略.... }

#elif defined SYSCLK_FREQ_56MHz
static void SetSysClockTo56(void){ 省略.... }

#elif defined SYSCLK_FREQ_72MHz
static void SetSysClockTo72(void){ 省略.... }

#endif

```

#### 预定义宏

```makefile
SYSCLK_FREQ_HSE    HSE_VALUE   : 使用 HSE 作为系统时钟源，不进行倍频
SYSCLK_FREQ_24MHz  24000000    : 定义 24MHz 系统时钟频率
SYSCLK_FREQ_36MHz  36000000    : 定义 36MHz 系统时钟频率
SYSCLK_FREQ_48MHz  48000000    : 定义 48MHz 系统时钟频率
SYSCLK_FREQ_56MHz  56000000    : 定义 56MHz 系统时钟频率
SYSCLK_FREQ_72MHz  72000000    : 定义 72MHz 系统时钟频率
VECT_TAB_SRAM                  : 定义向量表在 SRAM 中
VECT_TAB_OFFSET  0x0           : 向量表基址偏移量字段，此值必须是 0x200 的倍数
DATA_IN_ExtSRAM                : 定义使用外部 SRAM
```

通过编译器参数配置时钟频率：

```bash-session
$ arm-none-eabi-gcc -D HSE_VALUE=8000000 -D SYSCLK_FREQ_48MHz=48000000
```



## 用户文件


以下文件在标准库的工程模板中可以找到。


### 标准库配置头文件

`stm32f10x.h` 中包含这个头文件。

{{< bar title="Project/STM32F10x_StdPeriph_Template/stm32f10x_conf.h" >}}

```c { class="fixed-height" lineNos=inline }
#ifndef __STM32F10x_CONF_H
#define __STM32F10x_CONF_H

#include "stm32f10x_adc.h"
#include "stm32f10x_bkp.h"
#include "stm32f10x_can.h"
#include "stm32f10x_cec.h"
#include "stm32f10x_crc.h"
#include "stm32f10x_dac.h"
#include "stm32f10x_dbgmcu.h"
#include "stm32f10x_dma.h"
#include "stm32f10x_exti.h"
#include "stm32f10x_flash.h"
#include "stm32f10x_fsmc.h"
#include "stm32f10x_gpio.h"
#include "stm32f10x_i2c.h"
#include "stm32f10x_iwdg.h"
#include "stm32f10x_pwr.h"
#include "stm32f10x_rcc.h"
#include "stm32f10x_rtc.h"
#include "stm32f10x_sdio.h"
#include "stm32f10x_spi.h"
#include "stm32f10x_tim.h"
#include "stm32f10x_usart.h"
#include "stm32f10x_wwdg.h"
#include "misc.h" /* High level functions for NVIC and SysTick (add-on to CMSIS functions) */

// 当启用 USE_FULL_ASSERT 后，标准库函数会对输入参数进行严格的检查
// #define USE_FULL_ASSERT    1

#ifdef  USE_FULL_ASSERT
    #define assert_param(expr) ((expr) ? (void)0 : assert_failed((uint8_t *)__FILE__, __LINE__))
    void assert_failed(uint8_t* file, uint32_t line);
#else
    #define assert_param(expr) ((void)0)
#endif

#endif
```

### 中断函数头文件

这会覆盖启动文件中的中断函数。

{{< bar title="Project/STM32F10x_StdPeriph_Template/stm32f10x_it.h" >}}

```c { class="fixed-height" lineNos=inline }
#ifndef __STM32F10x_IT_H
#define __STM32F10x_IT_H

#ifdef __cplusplus
 extern "C" {
#endif 

#include "stm32f10x.h"

void NMI_Handler(void);
void HardFault_Handler(void);
void MemManage_Handler(void);
void BusFault_Handler(void);
void UsageFault_Handler(void);
void SVC_Handler(void);
void DebugMon_Handler(void);
void PendSV_Handler(void);
void SysTick_Handler(void);

#ifdef __cplusplus
}
#endif

#endif
```

### 中断函数源文件


{{< bar title="Project/STM32F10x_StdPeriph_Template/stm32f10x_it.c" >}}

```c { class="fixed-height" lineNos=inline }
#include "stm32f10x_it.h"

void NMI_Handler(void)
{
}

void HardFault_Handler(void)
{
  while (1)
  {
  }
}

void MemManage_Handler(void)
{
  while (1)
  {
  }
}

void BusFault_Handler(void)
{
  while (1)
  {
  }
}

void UsageFault_Handler(void)
{
  while (1)
  {
  }
}

void SVC_Handler(void)
{
}

void DebugMon_Handler(void)
{
}

void PendSV_Handler(void)
{
}

void SysTick_Handler(void)
{
}
```









## 文件关系图

{{< img src="files.svg" align="center" >}}








## GCC 链接脚本



```c { class="fixed-height" lineNos=inline }
/* 入口点 - 程序启动后执行的第一条指令地址 */
ENTRY(Reset_Handler)

/* 初始化栈顶地址 = RAM 区起始地址 + RAM 区大小 */
_estack = ORIGIN(RAM) + LENGTH(RAM);

/* 所需的最小堆大小 */
_Min_Heap_Size = 0x1000;

/* 所需的最小栈大小 */
_Min_Stack_Size = 0x400;

/* 指定存储器区域 */
MEMORY
{
    RAM (xrw)      : ORIGIN = 0x20000000, LENGTH = 64K    /* RAM: 可执行(x)、可读(r)、可写(w)，起始地址0x20000000，长度64KB */
    FLASH (rx)     : ORIGIN = 0x8000000,  LENGTH = 512K   /* FLASH: 只读(r)、可执行(x)，起始地址0x08000000，长度512KB */
}

/* 定义输出段 */
SECTIONS
{
    /* 创建一个 .isr_vector 段，用于存放向量表 */
    .isr_vector :
    {
        . = ALIGN(4);           /* 4 字节对齐，地址是 4 的倍数 */
        KEEP(*(.isr_vector))    /* *(.isr_vector) 表示匹配所有 .isr_vector 段；KEEP 表示保留匹配的段（防止被优化掉），.isr_vector 符号在启动文件被中定义（即向量表） */
        . = ALIGN(4);
    } >FLASH                    /* 输出到 FLASH */

  /* 创建一个 .text 段 */
  .text :
  {
    . = ALIGN(4);
    *(.text)                    /* 匹配所有 .text 段 */
    *(.text*)                   /* 匹配所有以 .text 开头的段 */
    *(.glue_7)
    *(.glue_7t)
    *(.eh_frame)

    KEEP (*(.init)) 
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;                 /* 定义 .text 段结束位置的全局符号 */
  } >FLASH                      /* 输出到 FLASH */

  /* 创建一个 .rodata 段 */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
  } >FLASH                      /* 输出到 FLASH */

  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH
  .ARM : {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } >FLASH

  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASH
  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASH
  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >FLASH

  _sidata = LOADADDR(.data);    /* .data 段在 FLASH 中的起始地址 */

  /* 创建一个 .data 段 */
  .data : 
  {
    . = ALIGN(4);
    _sdata = .;                 /* .data 段在 RAM 中的起始地址 */
    *(.data)
    *(.data*)

    . = ALIGN(4);
    _edata = .;                 /* .data 段在 RAM 中的结束地址 */
  } >RAM AT> FLASH              /* VMA 在 RAM 区，LMA 在 FLASH 区 */

  
  . = ALIGN(4);

  /* 创建一个 .bss 段 */
  .bss :
  {
    _sbss = .;                  /* .bss 在 RAM 中的起始地址 */
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;                  /* .bss 在 RAM 中的结束地址 */
    __bss_end__ = _ebss;
  } >RAM                        /* 输出到 RAM */


  /* 用户堆栈段，用于检查剩余 RAM 是否足够 */
  ._user_heap_stack :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >RAM

  /* 丢弃标准库中的某些信息（避免链接不需要的库内容） */
  /DISCARD/ :
  {
    libc.a ( * )                /* 丢弃 libc 库所有内容 */
    libm.a ( * )                /* 丢弃 libm 库所有内容 */
    libgcc.a ( * )              /* 丢弃 libgcc 库所有内容 */
  }

  /* ARM 属性段（通常为空，但保留结构） */
  .ARM.attributes 0 : { *(.ARM.attributes) }
}
```

{{< img src="link-map.svg" align="center" >}}


> CM3 为满减栈，压栈时：先移动指针再压入数据。


## STM32F1 启动流程


上电后，CPU **固定**从 `0x00000000` 读取初始栈顶地址到 SP ，从 `0x00000004` 读取入口程序地址到 PC 。
STM32 可通过配置 `BOOT0` 和 `BOOT1` 引脚，将从 `0x00000000` 地址开始的一块区域映射到不同存储器的地址空间，以实现从不同存储器启动。

|BOOT0 |BOOT1 |启动模式                     |
|:-----|:-----|:----------------------------|
|0     |X     |从 FLASH 启动                |
|1     |0     |从系统存储器启动（ISP 编程） |
|1     |1     |从 SRAM 启动                 |




### 从 FLASH 启动

从 FLASH 启动时，地址 `0x00000000` 被映射到 `0x08000000` ，CPU 就能从 `0x00000000` 访问 FLASH 中的向量表从而运行程序。

假设初始栈顶地址为 `0x20010000`（64K） ，入口函数地址为 `0x08000400` ，启动流程如下：

{{< img src="boot-flash.svg" align="center" >}}

> 入口函数地址 `0x08000401` 最后一位是 1 表示 thumb 状态，实际地址为 `0x08000400` 。



### 从系统存储器启动

从 System Memory 启动时，地址 `0x00000000` 被映射到 `0x1FFF0000` ，此区域存储的是厂商内置的 BootLoader 程序（闭源），
主要功能是从串口下载用户程序到 Flash （ISP 编程）。


### 从 SRAM 启动

从 SRAM 启动时，理论上应该将地址 `0x00000000` 映射到 `0x20000000` ，但对于 STM32F1 系列实际情况并非如此。

对于 STM32F103ZET6 ，从 SRAM 启动时，`0x00000000` 会被映射到一块内存极小的区域，大约在 `0x1FFFF000` 附近或略低，仅 16 字节，内容如下：

```text
20005000 200001E1 20000004 20000004
```

第一个字：初始栈顶地址 `0x20005000` （20K）。

第二个字：入口程序地址 `0x200001E1` ，最后一位表示 thumb ，实际是 `0x200001E0`，相对 `0x20000000` 偏移 `0x1E0` 。
对于不同容量的产品，其偏移值也有所不同，参考 GCC 的启动文件：

```asm
startup_stm32f10x_ld.s:     .word  BootRAM    /*  0x108   */
startup_stm32f10x_md.s:     .word  BootRAM    /*  0x108   */
startup_stm32f10x_hd.s:     .word  BootRAM    /*  0x1E0   */
startup_stm32f10x_xl.s:     .word  BootRAM    /*  0x1E0   */
startup_stm32f10x_cl.s:     .word  BootRAM    /*  0x1E0   */
startup_stm32f10x_ld_vl.s:  .word  BootRAM    /*  0x01CC  */
startup_stm32f10x_md_vl.s:  .word  BootRAM    /*  0x01CC  */
startup_stm32f10x_hd_vl.s:  .word  BootRAM    /*  0x1E0   */
```

第三和第四个字分别是 NMI 和 HardFault 向量。它们的最低位为 0 （CM3 不支持 ARM 状态），因此当 VTOR 仍为零时，若发生这些异常中的任何一个，处理器将触发双重异常。

根据 <a href="#gcc-启动文件">GCC 启动文件</a> 与 <a href="#gcc-链接脚本">GCC 链接脚本</a> ，地址 `0x200001E0` 位置是向量表中 `BootRAM` 所在，且 `BootRAM = 0xF1E0F85F` ，
`0xF1E0F85F` 这个值实际是汇编指令 `LDR.W PC, [PC, #-0x1E0]` 的机器码，作用是 `PC = *(PC - 0x1E0)` ，指令执行后的 PC 指向真正的入口程序地址，
详情参考 [这篇帖子](https://stackoverflow.com/questions/50977529/arm-cortex-m3-boot-from-ram-initial-state/51005367#51005367) 。


{{< img src="boot-sram.svg" align="center" >}}

正常从 SRAM 启动，应该需要以下设置（**未验证**）：

1. 配置 BOOT0 、BOOT1 引脚均为高电平。
2. 设置链接脚本中的 RAM 区起始地址，与 RAM 区大小。
3. 设置链接脚本中的 FLASH 区的起始地址为 `0x20000000`，与 FLASH 区大小。
4. 从上图的流程中可以看出，向量表中的 `_estack` 栈初始地址没有起到作用，初始栈顶被强制设置为 `0x20005000` ，
所以用户需要在 main 函数调用前设置 SP ，可以使用 <a href="#core_cm3c">core_cm3.c</a> 中的 `__set_MSP` 函数。
5. 设置向量表偏移寄存器 `SCB->VTOR` 的值，可使用 <a href="#system_stm32f10xc">system_stm32f10x.c</a> 中的 `VECT_TAB_SRAM` 宏，如下：

{{< bar title="Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/system_stm32f10x.c" >}}
```c
// 如果需要将向量表重定位到内部SRAM中，请取消注释以下行
// #define VECT_TAB_SRAM                     // 定义向量表在SRAM中
#define VECT_TAB_OFFSET  0x0                 // 向量表基址偏移量字段，此值必须是0x200的倍数

void SystemInit (void) {

省略...

#ifdef VECT_TAB_SRAM
    // SRAM_BASE 在 stm32f10x.h 中定义 0x20000000
    SCB->VTOR = SRAM_BASE | VECT_TAB_OFFSET;  // 向量表重定位到内部 SRAM 中
#else
    SCB->VTOR = FLASH_BASE | VECT_TAB_OFFSET; // 向量表重定位到内部 FLASH 中
#endif 
}
```

> 对于这种奇怪的启动方式，似乎主要局限于 F103/5/7 系列，较新的芯片应该是正常的，还是参考 [这篇帖子](https://stackoverflow.com/questions/50977529/arm-cortex-m3-boot-from-ram-initial-state/51005367#51005367) 。


另外，我在野火 STM32 文档中也找到了印证，参考 [在SRAM中调试代码](https://doc.embedfire.com/mcu/stm32/f103badao/std/zh/latest/book/SRAM.html) 一文。
在此文中，单片机复位后 PC 和 SP 指针初始值异常（如下图），恰好印证了上述的启动流程。

{{< img src="bad.jpg" zoom="1" align="center" >}}

{{< img src="info.png" zoom="0.5" align="center" >}}

除此之外，野火 STM32 文档中使用的 IDE 是 Keil ，默认是 ARMCC 编译器，该编译器的启动文件中并没有定义 `BootRAM` ，
这也是他们 SRAM 调试失败的原因之一。
