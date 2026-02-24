---
title: "LD 链接器脚本语法"
date: "2026-02-19"
toc: true
draft: true
---


## 基本概念

- VMA（虚拟内存地址）：程序运行时的地址，即堆栈上的地址。
- LMA（加载内存地址）：程序数据存储的地址，比如已初始化的全局变量的值在 FLASH 中存储的地址就是 LMA ，当这个值被加载到 SRAM 中栈上的地址就是 VMA 。
- Symbol Name（符号名）：用于符号解析。它代表函数或变量的标识符，由编译器从源代码中的函数名直接生成。使用 `objdump -t <目标文件>` 命令查看符号。
- Section Name（段名）：用于内存布局。以 `.` 开头，可能包含函数名作为段名的一部分（特别是在使用 `-ffunction-sections` 参数时）。使用 `objdump -h <目标文件>` 命令查看段。



## 简单示例

以下脚本仅包含一个 `SECTIONS` 命令：

```c
SECTIONS
{
    . = 0x10000;
    .text : { *(.text) }
    . = 0x8000000;
    .data : { *(.data) }
    .bss  :
    {
        *(.bss)
        _end_of_bss = .;
    }
}
```

`SECTIONS` 命令用于描述输出文件的内存布局，该脚本输出的内存布局如下图：

{{< img src="simple-map.svg" >}}


`*` 表示匹配任意文件名的通配符。`*(.text)` 表示所有输入文件中的 `.text` 段。

`.` 表示当前位置计数器。它从 `0x0` 开始，可以直接修改，也可以通过添加段、常量等间接修改。因此，如果你在 `.bss` 段之后读取位置计数器的值，它的值将是 `0x8000000` 加上你添加的段的大小。



## 命令

### 设置入口点

**`ENTRY(符号)`**

有多种方式可以设置入口点。链接器将按顺序尝试以下每种方法，并在其中一种成功时停止：

- 命令行 `-e` 选项。
- 链接器脚本中的 `ENTRY(符号)` 命令。
- 符号 `start` 的值，如果已定义。
- `.text` 段的第一个字节的地址，如果存在。
- 地址 `0` 。

### 文件处理命令

**`INCLUDE 文件名`**

用于在当前的链接器脚本中包含另一个文件的内容，会搜索当前目录以及 `-L` 选项指定的目录。

**`INPUT(文件1, 文件2, ...)`**

指定输入文件。如 `INPUT(utils.o)` 等同于命令行中的 `ld utils.o` 。如 `INPUT (-lfile)` ，ld 会将名称转换为 `libfile.a` ，类似于命令行参数 `-l` 。

**`GROUP(文件1, 文件2, ...)`**

类似于 `INPUT` 命令，不同之处（没太搞懂，`INPUT` 是单次搜索，`GROUP` 会多次搜索直到没有未解析的引用？）。

**`AS_NEEDED(文件1, 文件2, ...)`**

仅在 `INPUT` 或 `GROUP` 命令内部使用（不太清楚，例如 `GROUP (AS_NEEDED(libfoo.so))` 仅在共享库 `libfoo.so` 中的函数需要时才会被添加，不适用于静态库？）。


**`OUTPUT(文件名)`**

用于指定输出文件的名称。如 `OUTPUT(target.elf)` 等同于命令行中的 `-o target.elf` 。

**`SEARCH_DIR(路径)`**

指定输入文件的搜索路径。如 `SEARCH_DIR(path)` 等同于命令行中的 `-L path` 。

**`STARTUP(文件名)`**

用于指定第一个输入文件。`STARTUP` 命令指定的文件会被链接器最先处理（该文件中的代码会被放在输出文件的最前面、符号会最先被解析）。



### 目标文件格式处理命令

**`OUTPUT_FORMAT(格式)`**

通过 `objdump -i` 命令查看你的工具链支持哪些格式（通常默认格式是第一个），比如 `elf32-littlearm` 。等同于命令行中 `--oformat` 选项。

**`OUTPUT_FORMAT(默认格式, 大端格式, 小端格式)`**

输出格式的另一种写法，例如 `OUTPUT_FORMAT(elf32-bigmips, elf32-bigmips, elf32-littlemips)` 表示输出文件的默认格式为 `elf32-bigmips` ，但如果用户使用 `-EB` 命令行选项，输出文件格式为 `elf32-bigmips` 。
若使用 `-EL` 命令行选项，输出文件格式为 `elf32-littlemips` 。


**`TARGET(格式)`**

指定输入文件的格式。`TARGET` 命令强制链接器使用指定的格式来解析输入文件，而不是自动检测。它会影响后续的 `INPUT` 和 `GROUP` 命令。


### 内存区域别名

**`REGION_ALIAS(别名, 区域名)`**

定义内存区域的别名，内存区域在 `MEMORY` 命令中定义：

```c
MEMORY
{
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 1M
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
}

/* 定义通用别名 */
REGION_ALIAS("REGION_TEXT"   , FLASH);
REGION_ALIAS("REGION_RODATA" , FLASH);
REGION_ALIAS("REGION_DATA"   , SRAM);
REGION_ALIAS("REGION_BSS"    , SRAM);

SECTIONS
{
    .text   : { *(.text)   } > REGION_TEXT
    .rodata : { *(.rodata) } > REGION_RODATA
    .data   : { *(.data)   } > REGION_DATA
    .bss    : { *(.bss)    } > REGION_BSS
}
```

如果需要在 SRAM 中运行程序，就只用修改别名定义中的 FLASH 为 SRAM ，不需要动 SECTIONS 中的内容。


### 其它命令

**`ASSERT(表达式, 消息)`**

如果表达式为 `0`（假），则退出并打印消息。例如：`ASSERT((SIZEOF(.text) < 0x10000), "代码段超出64KB限制")` 。表达式支持的运算符与 C 语言基本相似。

**`EXTERN(符号1  符号2  ...)`**

用于强制将指定的符号标记为未定义的外部符号。即使没有目标文件或库引用这些符号，链接器也会在链接过程中寻找它们的定义。等同命令行 `-u` 选项。
例如：`EXTERN(serial_init)` 即使程序中没有调用 `serial_init`，它也会被链接进来。

**`FORCE_COMMON_ALLOCATION`**

强制为公共符号分配空间（不太清楚，`.common` 通常存放未初始化的全局变量，可能是为了防止变量被优化丢弃掉？即使没用也要分配？）。
等同命令行 `-d` 选项。

**`INHIBIT_COMMON_ALLOCATION`**

等同 `--no-define-common` 选项。

**` FORCE_GROUP_ALLOCATION`**

等同 `--force-group-allocation` 选项。

**`INSERT [ AFTER | BEFORE ] 输出段`**

与 `SECTIONS` 命令搭配使用，插入额外的内容，不覆盖默认的链接脚本。`AFTER` 表示在指定段之后插入，`BEFORE` 表示在指定段之前插入。

{{< bar title="insert_special.ld" >}}

```c
SECTIONS
{
    .text_special : {
        *(.text.special_init)
    }
} INSERT BEFORE .text;    /* 在 .text 之前插入 */
```

在默认的链接脚本中插入：

```bash-session
$ ld main.o special.o -T insert_special.ld -o program
```

两个 `-T` 选项，`my_script.ld` 会覆盖默认链接脚本，然后 `insert_special.ld` 再插入：

```bash-session
$ ld main.o special.o -T my_script.ld -T insert_special.ld -o program
```

**`NOCROSSREFS(段1, 段2, ...)`**

防止互相跨段引用。例如，如果一个段中的代码调用了另一个段中定义的函数，就会产生错误。

**`NOCROSSREFS_TO(段1, 段2, ...)`**

防止单向跨段引用。第一个段不能被第二、第三、等其它段引用。

**`OUTPUT_ARCH(架构)`**

指定链接生成的输出文件所针对的目标架构（如 arm、i386、riscv）。不要与 `OUTPUT_FORMAT` 搞混，`OUTPUT_FORMAT` 指定的是文件输出格式。使用 `objdump -i` 命令查看支持的格式与架构。

**`LD_FEATURE(字符串)`**

用于启用或禁用链接器的某些特定功能特性，通过传递字符串参数来控制链接器的行为。



## 符号赋值

### 简单赋值

支持 C 语言的赋值运算符：

```c
symbol   =  expression ;
symbol  +=  expression ;
symbol  -=  expression ;
symbol  *=  expression ;
symbol  /=  expression ;
symbol <<=  expression ;
symbol >>=  expression ;
symbol  &=  expression ;
symbol  |=  expression ;
```

- 表达式后的分号 `;` 是必需的。
- 特殊符号 `.` 表示位置计数器。只能在 `SECTIONS` 命令中使用此符号。


### HIDDEN ( symbol = expression )

让符号对外部模块不可见。

```c
SECTIONS
{
    .text :
    {
        *(.text)
        HIDDEN(_etext = .);
    }
}
```

例如当前链接脚本输出的 `libmath.so` 文件称为内部模块，则其它需要与 `libmath.so` 链接的外部模块将无法引用 `_etext` 。

### PROVIDE ( symbol = expression )

当输入文件（程序）中没有定义 `symbol` 的值时，链接器才会使用 `PROVIDE` 命令中的 `symbol = expression` 的值。

### PROVIDE_HIDDEN

`PROVIDE` 与 `HIDDEN` 功能相结合。

### 源代码引用

链接器脚本中定义的符号会在符号表中创建一个条目，但不会为它分配任何内存（大小为 0 ）。
因此，它是一个没有值的地址（地址常量？）。

```c
SECTIONS
{
    .text : { *(.text) }
    . = 0x20000000;
    .data :
    {
        _sdata = .;
        *(.data)
        _edata = .;
    }
}
```

以上脚本在链接后（该脚本仅示意不能运行），其符号表输出的部分内容可能如下：

```bash-session
$ objdump -t target.elf
[地址]    [标志]    [段]     [大小]    [符号名]
20000000  g         .data    00000000  _sdata
20000000  g      O  .data    00000004  count
20000004  g         .data    00000000  _edata
```

其中 `count` 是已初始化的全局变量，大小为 4 字节。`_sdata` 是 `.data` 段的起始地址，大小为 0 （不分配内存）。
`_edata` 是 `.data` 段的结束地址，大小为 0 。


所以不能在 C 程序中获取 `_sdata` 的值（值是不存在的），但能获取 `_sdata` 的地址（使用 `&` ）：

```c
extern int _sdata;
int *p = &_sdata;
```

或者声明为一个数组，数组首地址即为 `_sdata` 符号的地址：

```c
extern int _sdata[];
int *p = _sdata;
```

在汇编中，符号本质上就是一个地址（指针），所以直接使用 `_sdata` 即可：

```asm
ldr  r0, =_sdata    /* r0 = 0x20000000 */
```


## SECTIONS 命令

`SECTIONS` 命令告知链接器如何将输入段映射到输出段，以及如何在内存中放置输出段。

```text
SECTIONS
{
    [段名]  [VMA地址]  [(段类型)]  :  [AT(LMA地址)]  [ALIGN(段对齐)|ALIGN_WITH_INPUT]  [SUBALIGN(子段对齐)]  [约束]
    {
        output-section-command
        output-section-command
        ...
    } [>region] [AT>lma_region] [:phdr :phdr ...] [=fillexp] [,]
}
```

`[ ]` 中的参数都是可选的。


### [ 段名 ]

以 `.` 开头，如 `.text` 、`.init` 、`.debug_info` 等。

**`特殊段名：/DISCARD/`**

作用是丢弃匹配的输入段，不将这些段包含在最终输出的可执行文件或库中：

```c
/DISCARD/ : { *(.debug*) }    // 丢弃所有调试信息段
```

### [ VMA地址 ]

该地址是输出段的 VMA（虚拟内存地址）表达式。

```asm
.text   : { *(.text) }            // 段名后面没有指定地址，链接器会自动使用当前 '.' 的值作为 VMA
.text . : { *(.text) }            // 显式指定 VMA = 当前的 '.' 值
.text 0x08000000  : { *(.text) }  // 指定 VMA = 0x08000000
.text ALIGN(0x10) : { *(.text) }  // 将 VMA 对齐到 0x10 字节边界，使得地址的最低四位为零，ALIGN 返回当前定位计数器向上对齐到指定值后的结果
```

LMA 默认等于 VMA ，除非使用 `AT` 明确指定 LMA 。


### [ (段类型) ]

**`NOLOAD`**

表示这个段不应该被加载到内存中，或者不需要在程序运行时分配实际内存。

```c
.debug_info (NOLOAD) : {
    *(.debug_info)
    *(.debug_line)
}
```

**`READONLY`**

表示该输出段的内容在运行时不可被修改，并在生成的 ELF 文件中将该段标记为只读。

**`TYPE = type`**

用于显式指定输出段的段类型（sh_type），覆盖链接器默认生成的段类型。例如 `SHT_PROGBITS` 表示程序段：

```c
.text . (TYPE = SHT_PROGBITS) : { *(.text) }
```

使用 `readelf -S` 命令输出段的头信息：

```bash-session
$ readelf -S led-blink.elf
Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .isr_vector       PROGBITS        08000000 001000 0001e4 00   A  0   0  1
  [ 2] .text             PROGBITS        080001e4 0011e4 00059c 00  AX  0   0  4
```

更多段类型（sh_type）参考 [ELF 格式](https://refspecs.linuxfoundation.org/elf/elf.pdf) 中的相关内容。

**`READONLY ( TYPE = type )`**

这种语法形式将 `READONLY` 与 `TYPE` 相结合。


### [ AT(LMA地址) ]

指定 LMA 的地址。

```
.bss : AT(0x20000000) { *(.bss) }
```

### [ ALIGN(段对齐) | ALIGN_WITH_INPUT ]

输出段起始地址对齐：

```c
.bss : ALIGN(4) { *(.bss) }    // .bss 段起始地址 4 字节对齐
```

`ALIGN_WITH_INPUT`：不太清楚（确保输出段的对齐要求与输入段相同，防止因重新对齐导致的内存布局变化？）。


### [ SUBALIGN(子段对齐) ]

强制输入段在输出段内对齐：

```c
.text : SUBALIGN(4)
{
    *(.text.func1)    // 强制 4 字节对齐
    *(.text.func2)    // 强制 4 字节对齐
    *(.text.func3)    // 强制 4 字节对齐
}
```

```c
.text : SUBALIGN(4)
{
    *(.text.*)        // 匹配的 .text.func1 ， .text.func2 ， ... 都强制 4 字节对齐
}
```

### [ 约束 ]

仅两个关键字。`ONLY_IF_RO`：仅当所有输入节均为只读才创建输出节。`ONLY_IF_RW`：仅当所有输入节均为读写时才创建输出节。



## 参考链接

- [gnu](https://sourceware.org/binutils/docs/)
- [Linker Scripts](https://sourceware.org/binutils/docs/ld/Scripts.html)
