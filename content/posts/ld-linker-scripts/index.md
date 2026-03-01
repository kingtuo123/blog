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

强制将符号作为未定义符号输出到文件中。等同命令行 `-u` 选项。

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

类似弱定义，当输入文件中没有定义 `symbol` 的值时，链接器才会使用 `PROVIDE` 命令中的 `symbol = expression` 的值。

### PROVIDE_HIDDEN

`PROVIDE` 与 `HIDDEN` 组合后的效果。

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
        [输入段命令]
        [输入段命令]
        ...
    } [>VMA区域] [AT>LMA区域] [:phdr :phdr ...] [=fillexp] [,]
}
```

`[ ]` 中的参数都是可选的。


### [ 段名 ]

**`特殊段名：/DISCARD/`**

作用是丢弃匹配的输入段，不将这些段包含在最终输出的可执行文件或库中：

```c
/DISCARD/ : {
    *(.debug*)    /* 丢弃所有调试信息段 */
}
```

### [ VMA地址 ]

该选项是输出段的 VMA 表达式（若未指定 VMA ，VMA = `.` ）：

```asm
.text   : { *(.text) }            /* 段名后面没有指定地址，链接器会自动使用当前 '.' 的值作为 VMA                                           */
.text . : { *(.text) }            /* 显式指定 VMA = 当前的 '.' 值                                                                          */
.text 0x08000000  : { *(.text) }  /* 指定 VMA = 0x08000000                                                                                 */
.text ALIGN(0x10) : { *(.text) }  /* 将 VMA 对齐到 0x10 字节边界，使得地址的最低四位为零，ALIGN 返回当前定位计数器向上对齐到指定值后的结果 */
```


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
$ readelf -S target.elf
Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .isr_vector       PROGBITS        08000000 001000 0001e4 00   A  0   0  1
  [ 2] .text             PROGBITS        080001e4 0011e4 00059c 00  AX  0   0  4
```

更多段类型（sh_type）参考 [ELF 格式](https://refspecs.linuxfoundation.org/elf/elf.pdf) 中的相关内容。

**`READONLY ( TYPE = type )`**

这种语法形式将 `READONLY` 与 `TYPE` 相结合。

**`DSECT 、COPY 、INFO 、OVERLAY`**

这些类型名称是为了向后兼容而支持的，并且很少使用。
它们都具有相同的效果：该输出段被标记为不可分配，以便在程序运行时不为该段分配内存。


### [ AT(LMA地址) ]

指定 LMA 的地址（若未指定 LMA ，则 LMA = VMA ）：

```c
.data . : AT(0x20000000) { *(.data) }
```


### [ ALIGN(段对齐) | ALIGN_WITH_INPUT ]

输出段起始地址对齐：

```c
.data . : ALIGN(4) { *(.data) }    /* .bss 段起始地址 4 字节对齐 */
```

`ALIGN_WITH_INPUT`：不太清楚（确保输出段的对齐要求与输入段相同，防止因重新对齐导致的内存布局变化？）。


### [ SUBALIGN(子段对齐) ]

强制输入段在输出段内对齐：

```c
.text : SUBALIGN(4) {
    *(.text.func1)    /* 强制 4 字节对齐 */
    *(.text.func2)    /* 强制 4 字节对齐 */
    *(.text.func3)    /* 强制 4 字节对齐 */
}
```

```c
.text : SUBALIGN(4) {
    *(.text.*)        /* 匹配的 .text.func1 ， .text.func2 ， ... 都强制 4 字节对齐 */
}
```

### [ 约束 ]

仅两个关键字。`ONLY_IF_RO` 仅当所有输入段均为只读才创建输出段。`ONLY_IF_RW` 仅当所有输入段均为读写时才创建输出段。


### [ 输入段命令 ]

**`通配符`**

{{< table thead="false" min-width="100" >}}
|        |                         |
|:-------|:------------------------|
|`*`     |匹配任意数量的字符       |
|`?`     |匹配任意单个字符         |
|`[a-z]` |匹配集合中的任意一个字符 |
{{< /table >}}

如果一个文件名匹配多个通配符模式，链接器将使用链接脚本中的第一个匹配项：

```c
.data : {
    *(.data)
}
.data1 : {
    data.o(.data)    /* 如果 data.o 存在，该规则不会被使用 */
}
```

{{< notice class="yellow" >}}
文件名通配符模式仅匹配在命令行或 INPUT 命令中明确指定的文件。链接器不会通过搜索目录来扩展通配符。
{{< /notice >}}

**`EXCLUDE_FILE`**

使用 `EXCLUDE_FILE` 排除指定的文件：

```c
.text : {
    EXCLUDE_FILE (*debug.o *info.o) *(.text)    /* 匹配除 debug.o 和 info.o 之外的所有文件 */
    *(EXCLUDE_FILE (*debug.o *info.o) .text)    /* 另一种写法                              */
}
```

同时包含多个输入段：

```c
.text : {
    *(.text .rodata)       /* .text 与 .rodata 会在输出段中交错显示    */
    *(.text) *(.rodata)    /* .text 在输出段中先出现，然后才是 .rodata */
}
```

`EXCLUDE_FILE` 在包含多个输入段中的用法：

```c
.text : {
    EXCLUDE_FILE (*somefile.o) *(.text .rodata)
    *(EXCLUDE_FILE (*somefile.o) .text EXCLUDE_FILE (*somefile.o) .rodata)
}
```

`EXCLUDE_FILE` 仅对跟随其后的第一个段生效：

```c
.text : {
    *(EXCLUDE_FILE (*somefile.o) .text .rodata)    /* 对 .rodata 不生效，仍旧会匹配 *somefile.o 中的 .rodata */
}
```

**`INPUT_SECTION_FLAGS`**

使用 `INPUT_SECTION_FLAGS` 段标志来筛选输入段：

```c
.text : {
    INPUT_SECTION_FLAGS (SHF_MERGE & SHF_STRINGS) *(.text)    /* 标志位 SHF_MERGE 和 SHF_STRINGS 被设置的段 */
}
.text2 : {
    INPUT_SECTION_FLAGS (!SHF_WRITE) *(.text)                 /* 标志位 SHF_WRITE 未设置的段                */
}
```

`SHF_MERGE` 表示可合并。`SHF_STRINGS` 表示包含字符串。`SHF_WRITE` 表示段可写。
更多标志参考 [ELF 格式](https://refspecs.linuxfoundation.org/elf/elf.pdf) 中 sh_flags 的相关内容。

使用 `readelf -S` 命令查看段标志，其中 `Flg` 一列为段标志：

```bash-session
$ readelf -S target.elf
Section Headers:                                                    ↓
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .isr_vector       PROGBITS        08000000 001000 0001e4 00   A  0   0  1
  [ 2] .text             PROGBITS        080001e4 0011e4 00059c 00  AX  0   0  4
```


其中：`A` (ALLOC)：段在内存中分配。`X` (EXEC)：段可执行。

**`ARCHIVE:FILE`**

{{< notice class="red" >}}
可能有误，仅供参考。
{{< /notice >}}

官方文档中关于 `archive:file` 的描述，没太看懂，应该是静态库，可能如下。详见 [3.6.4.1 Input Section Basics](https://sourceware.org/binutils/docs/ld/Input-Section-Basics.html) 。

```c
.text : {
    libc.a:         (.text)    /* 匹配 libc.a 文件中的所有 .text 段               */
    libc.a:printf.o (.text)    /* 匹配 libc.a 文件中的 printf.o 中的所有 .text 段 */
          :printf.o (.text)    /* 匹配非静态库文件中的 printf.o 中的所有 .text 段 */
           printf.o            /* 匹配 printf.o 中所有段                          */
}
```

`archive:file` 是一个整体，不要在冒号 `:` 左右加空格，错误的写法 `archive : file` 。

**`SORT_BY_NAME`**

使用 `SORT_BY_NAME` 可以按名称升序（a → z）对输入段进行排序：

```c
.text : {
    *(SORT_BY_NAME(.text*))
}
```

**`SORT`**

`SORT` 是 `SORT_BY_NAME` 的别名。

**`SORT_BY_ALIGNMENT`**

`SORT_BY_ALIGNMENT` 按输入段的对齐大小降序：

```c
.text : {
    *(SORT_BY_ALIGNMENT(.text*))
}
```

排序前：

```c
.text.a    (align=4)
.text.b    (align=16)
.text.c    (align=8)
```

排序后：

```c
.text.b    (align=16)
.text.c    (align=8)
.text.a    (align=4)
```

**`SORT_BY_INIT_PRIORITY`**

`SORT_BY_INIT_PRIORITY` 表示按优先级升序，数字越小优先级越高：

```c
.text : {
    *(SORT_BY_INIT_PRIORITY(.init_array*))
}
```

排序前：

```c
.init_array.200
.init_array.65535
.init_array.101
```

排序后：

```c
.init_array.101
.init_array.200
.init_array.65535
```

> `init_priority` 是 GCC 的一个编译器扩展属性，用于控制 C++ 全局对象的初始化顺序，范围 `101 ~ 65535` 。


**`REVERSE`**

`REVERSE` 表示排序应反向进行。如果单独使用，则 `REVERSE` 效果同 `SORT_BY_NAME` 。

```c
.text : {
    *(REVERSE(.text*))                  /* 按名称升序排序，效果等同 SORT_BY_NAME */
    *(REVERSE(SORT_BY_NAME(.text*)))    /* 按名称降序排序                        */
}
```


`REVERSE` 仅接受单个通配符模式。因此，以下示例将无法正常工作：

```c
.text : {
    *(REVERSE(.text* .init*))    /* 无法正常工作 */
}
```

**`嵌套排序`**

```c
.text : {
    *(SORT_BY_NAME (SORT_BY_ALIGNMENT (.text*)))         /* 先按名称升序，如果有两个段名称排序相同，这两个段再按对齐降序 */
    *(SORT_BY_ALIGNMENT (SORT_BY_NAME (.text*)))         /* 先按对齐降序，如果有两个段对齐排序相同，这两个段再按名称升序 */
    *(SORT_BY_NAME (SORT_BY_NAME (.text*)))              /* 按名称升序，同 SORT_BY_NAME                                  */
    *(SORT_BY_ALIGNMENT (SORT_BY_ALIGNMENT (.text*)))    /* 按对齐降序，同 SORT_BY_ALIGNMENT                             */
    *(SORT_BY_NAME (REVERSE (.text*)))                   /* 按名称降序                                                   */
    *(REVERSE (SORT_BY_NAME (.text*)))                   /* 按名称降序                                                   */
    *(SORT_BY_INIT_PRIORITY (REVERSE (.init_array*)))    /* 按优先级降序                                                 */
}
```

{{< notice class="yellow" >}}
上述之外的嵌套排序命令均无效，且最多只能有一层嵌套。
{{< /notice >}}

当同时使用命令行段排序选项和链接器脚本段排序命令时，**段排序命令**始终**优先**于**命令行选项**。

如果链接器脚本中的段排序命令未嵌套，命令行选项将使段排序命令被视为嵌套排序命令。

例如 `SORT_BY_NAME` + `--sort-sections alignment` 等价于 `*(SORT_BY_NAME (SORT_BY_ALIGNMENT (.text*)))` 。

如果链接器脚本中的段排序命令已嵌套，命令行选项将被忽略。


**`输入段的垃圾回收`**


链接器 `--gc-sections` 参数（garbage collection）会丢弃未被引用的段。要保留这些段，在输入段周围加上 `KEEP()` ：

```c
.text : {
    KEEP(*(.init))
}
```

**`BYTE 、SHORT 、 LONG 、 QUAD`**

分别存储一、二、四和八个字节（遵循目标文件端序）。存储字节后，位置计数器将增加已存储的字节数。

```c
.text : {
    BYTE(1)              /* 存储 1 ，大小一字节            */
    LONG(addr)           /* 存储符号 addr 的四字节值       */
    LONG(0x12345678);    /* 存储 0x12345678 这个四字节数据 */
}
```

当使用 64 位主机或目标平台时， `QUAD` 和 `SQUAD` 是相同的，它们都存储一个 8 字节（即 64 位）的值。
当主机和目标平台均为 32 位时，表达式会按 32 位进行计算。
在这种情况下， `QUAD` 存储一个零扩展至 64 位的 32 位值，而 `SQUAD` 存储一个符号扩展至 64 位的 32 位值。


**`ASCIZ`**

`ASCIZ` 用于存储字符串（遵循目标文件端序），且自动在字符串末尾添加 `\0` 终止符：

```c
.rodata : {
    ASCIZ "This is 16 bytes"    /* 这个包含 16 个字符的字符串将创建一个 17 字节的区域 */
}
```


**`FILL`**

`FILL` 用于填充段中任何未明确指定的内存区域（例如对齐产生的间隙），填充值**固定大端序**，仅影响 `FILL` 命令之后的部分。

对于简单数字表达式，其值会被零扩展到 4 字节，如果表达式的结果值超过 4 个有效字节，则仅使用该值的最低 4 个字节：

```c
.text : {
    FILL(144)              /* 144 = 0x90 ， 扩展为 00 00 00 90                   */
    FILL(22 * 256 + 23)    /* 22 * 256 + 23 = 5665 = 0x1617 ，扩展为 00 00 16 17 */
}
```

```text
低地址   ----------->   高地址
00  00  00  90  00  00  00  90
00  00  16  17  00  00  16  17
```

对于十六进制数据（必须 `0x` 开头），不执行零扩展，所有字节均为有效字节：

```c
.text : {
    FILL(0x90)            /* 用 90 循环填充             */
    FILL(0x0090)          /* 用 00 90 循环填充          */
    FILL(0x123456789a)    /* 用 12 34 56 78 9a 循环填充 */
}
```

```text
低地址   ------------------->   高地址
90  90  90  90  90  90  90  90  90  90
00  90  00  90  00  90  00  90  00  90
12  34  56  78  9a  12  34  56  78  9a
```

**`LINKER_VERSION`**

该命令会在当前位置插入一个包含链接器版本号的字符串。
注意：默认情况下此指令处于禁用状态且不会产生任何效果。仅当使用 `--enable-linker-version` 命令行选项时才会激活该功能。


### [ >VMA区域 ]

在 `MEMORY` 命令中定义的区域。

```c
MEMORY {
    rom : ORIGIN = 0x1000, LENGTH = 0x1000
}
SECTIONS {
    ROM : {
        *(.text)
    } >rom
}
```


### [ AT>LMA区域 ]

在 `MEMORY` 命令中定义的区域。


## PHDRS 命令

`PHDRS` 用于手动定义 ELF 文件中的程序头（Program Headers）。使用 `objdump -p` 命令打印程序头。

```text
PHDRS
{
    名称  类型  [FILEHDR]  [PHDRS]  [AT ( 地址 )]  [FLAGS ( 标志 )] ;
}
```

### 名称

用户自定义的名称。这不是最终输出文件中的字段，仅用于在 `SECTIONS` 命令中引用这个程序头。

### 类型

程序头的类型。该类型可能是以下之一。数字表示关键字的值。

```makefile
PT_NULL (0)    : 表示未使用的程序头。
PT_LOAD (1)    : 表示此程序头描述了一个需要从文件中加载的段。
PT_DYNAMIC (2) : 表示一个可以找到动态链接信息的段。
PT_INTERP (3)  : 指示可能包含程序解释器名称的段。
PT_NOTE (4)    : 指示包含注释信息的段。
PT_SHLIB (5)   : 一个保留的程序头类型，由 ELF ABI 定义但未具体说明。
PT_PHDR (6)    : 指示可以找到程序头的段。
PT_TLS (7)     : 表示一个包含线程本地存储的段。
表达式         : 一个给出程序头数字类型的表达式。这可用于上述未定义的类型。
```

### [ FILEHDR ]

表示这个段包含了 ELF 文件头。


### [ PHDRS ]

表示这个段包含了 ELF 程序头表本身。

### [ AT ( 地址 ) ]

指定 LMA 地址。

### [ FLAGS ( 标志 ) ]

用于设置程序头的 `p_flags` 字段。

### 示例

```c
PHDRS
{
    headers PT_PHDR PHDRS ;
    interp PT_INTERP ;
    text PT_LOAD FILEHDR PHDRS ;
    data PT_LOAD ;
    dynamic PT_DYNAMIC ;
}

SECTIONS
{
    . = SIZEOF_HEADERS;
    .interp  : { *(.interp) } :text :interp
    .text    : { *(.text)   } :text
    .rodata  : { *(.rodata) }
    ...
    . = . + 0x1000;
    .data    : { *(.data)    } :data
    .dynamic : { *(.dynamic) } :data :dynamic
    ...
}
```


## 官方文档

- [Binutils](https://sourceware.org/binutils/docs/)
- [LD](https://sourceware.org/binutils/docs/ld/index.html#SEC_Contents)
