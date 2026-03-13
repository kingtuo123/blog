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

