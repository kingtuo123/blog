---
title: "STM32F1 标准库源码阅读"
date: "2026-01-29"
toc: true
---


## CM3 内核文件

### core_cm3.h

{{< insert src="files/core_cm3.h" >}}

内核头文件主要定义了以下内容：

- NVIC，SCB，SysTick，ITM，MPU，CoreDebug 等寄存器内存映射。
- 优先级分组，中断优先级设置函数，SysTick 配置函数等。
- 内核访问函数。




### core_cm3.c


{{< insert src="files/core_cm3.c" >}}




## STM32F10x 设备文件




### GCC 启动文件


{{< insert src="files/startup_stm32f10x_hd.s" >}}


#### STM32 芯片命名规则

{{< img src="stm32-name-rules.svg" scroll-x=true >}}

#### 启动文件后缀

{{< img src="stm32-startup.svg" scroll-x=true >}}






### stm32f10x.h

`stm32f10x.h` 文件很长，以下截取部分关键代码：

{{< insert src="files/stm32f10x.h" >}}

#### 预定义宏


```makefile{class="none-bg"}
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

```makefile{class="none-bg"}
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

```c{class="none-bg"}
20005000 200001E1 20000004 20000004
```

第一个字：初始栈顶地址 `0x20005000` （20K）。

第二个字：入口程序地址 `0x200001E1` ，最后一位表示 thumb ，实际是 `0x200001E0`，相对 `0x20000000` 偏移 `0x1E0` 。
对于不同容量的产品，其偏移值也有所不同，参考 GCC 的启动文件：

```asm{class="none-bg"}
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

根据 [GCC 启动文件](#gcc-启动文件) 与 [GCC 链接脚本](#gcc-链接脚本) ，地址 `0x200001E0` 位置是向量表中 `BootRAM` 所在，且 `BootRAM = 0xF1E0F85F` ，
`0xF1E0F85F` 这个值实际是汇编指令 `LDR.W PC, [PC, #-0x1E0]` 的机器码，作用是 `PC = *(PC - 0x1E0)` ，指令执行后的 PC 指向真正的入口程序地址，
详情参考 [这篇帖子](https://stackoverflow.com/questions/50977529/arm-cortex-m3-boot-from-ram-initial-state/51005367#51005367) 。


{{< img src="boot-sram.svg" align="center" >}}

正常从 SRAM 启动，应该需要以下设置（**未验证**）：

1. 配置 BOOT0 、BOOT1 引脚均为高电平。
2. 设置链接脚本中的 RAM 区起始地址，与 RAM 区大小。
3. 设置链接脚本中的 FLASH 区的起始地址为 `0x20000000`，与 FLASH 区大小。
4. 从上图的流程中可以看出，向量表中的 `_estack` 栈初始地址没有起到作用，初始栈顶被强制设置为 `0x20005000` ，
所以用户需要在 main 函数调用前设置 SP ，可以使用 [core_cm3.c](#core_cm3c) 中的 `__set_MSP` 函数。
5. 设置向量表偏移寄存器 `SCB->VTOR` 的值，可使用 [system_stm32f10x.c](#system_stm32f10xc) 中的 `VECT_TAB_SRAM` 宏，如下：

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
