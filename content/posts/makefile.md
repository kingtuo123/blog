---
title: "Makefile 入门"
date: "2022-05-01"
toc: true
---




## 语法

makefile 由多个规则组成：

```makefile
targets: prerequisites
	command
	command
	command
```

<div class="table-container no-thead"> 

|                |                                                              |
|:---------------|:-------------------------------------------------------------|
|`targets`       |目标文件，以空格分隔，通常一个规则只有一个目标                |
|`command`       |通常是用于生成 targets 的一系列步骤，以 Tab 开头              |
|`prerequisites` |依赖文件（先决条件），以空格分隔，需要在执行 command 之前存在 |

</div>





## 示例一

```makefile
blah: blah.o
	cc blah.o -o blah # 第三个运行

blah.o: blah.c
	cc -c blah.c -o blah.o # 第二个运行

blah.c:
	echo "int main() { return 0; }" > blah.c # 第一个运行
```

终端执行 `make blah` 会按以下步骤运行并生成 `blan` 文件：

1. make 以 `blah` 作为目标，所以它首先搜索这个目标
2. `blah` 依赖 `blah.o` ，make 会搜索 `blah.o`
3. `blah.o` 依赖 `blah.c` ，make 会搜索 `blah.c`
4. `blah.c` 无需依赖，会执行 `echo` 命令，生成 `blah.c`
5. `blah.o` 的依赖满足，会执行  `cc -c` 命令，生成 `blah.o`
6. `blah` 的依赖满足，会执行  `cc` 命令，生成 `blah`

make 的默认目标是规则中的第一个目标，所以直接执行 make 即可：

```bash-session
$ make
echo "int main() { return 0; }" > blah.c 
cc -c blah.c -o blah.o 
cc blah.o -o blah 
```

重复执行 make 会提示 up to date：

```bash-session
$ make
make: 'blah' is up to date.
```

当依赖文件的时间戳新于目标文件，目标文件才会按规则重新生成：

```bash-session
$ touch blah.o && make
cc blah.o -o blah 

$ touch blah.c && make
cc -c blah.c -o blah.o 
cc blah.o -o blah 

$ rm -f blah.c && make
echo "int main() { return 0; }" > blah.c 
cc -c blah.c -o blah.o 
cc blah.o -o blah 
```





## 示例二

```makefile
some_file: other_file
	echo "This will always run, and runs second"
	touch some_file

# 这里 other_file 不会生成
other_file:
	echo "This will always run, and runs first"
```

上面这个 makefile 始终会执行 `touch some_file`，因为 `some_file` 的依赖始终无法满足。

> 疑问：这里可以看出 make 成功执行规则后，不会检查此规则的目标文件是否存在





## Make clean

clean 常用来清理文件，但它在 make 中并不是关键词。（一般都是约定俗成的，大家都习惯用 clean 清理文件）

```makefile
some_file: 
	touch some_file

clean:
	rm -f some_file
```
- clean 不是规则中的第一个目标，所以需要显式调用 `make clean`

- 如果碰巧有一个名为 clean 的文件，这个目标将不会被执行，后文 `.PHONY` 一节会有说明






## 变量

变量本质上都是 **字符串**

### 展开变量

使用 `$( )` 或 `${ }` 。

```makefile
obj = a.o b.o c.o

test: $(obj)
	gcc -o test $(obj)
```

### 赋值

<div class="table-container no-thead w-50">

|符号 |作用                        |
|:----|:---------------------------|
|`=`  | 变量赋值，在执行时查找替换 |
|`:=` | 变量赋值，在定义时查找替换 |
|`+=` | 变量追加赋值               |
|`?=` | 变量为空则给它赋值         |

</div>

### = 与 := 的区别

```makefile
# 这条会在下面打印出 later
one = one ${later_variable}
# 这条不会打印出 later，later_variable 在此时未被定义
two := two ${later_variable}

later_variable = later

all: 
	@echo $(one)
	@echo $(two)
```

```bash-session
$ make
one later
two
```

> `=` 可以用于需要动态变化的值

### 单个空格变量

字符串中行尾的空格不会被去掉，但行首的空格会被去掉

要使用单个空格作为变量，使用 `$(nullstring)`

```makefile
with_spaces =     hello     # with_spaces在 "hello" 之后有很多空格
after = $(with_spaces)there

nullstring =
space = $(nullstring) # 这里末尾有一个空格，即单个空格变量。

all: 
	@echo "$(after)"
	@echo start"$(space)"end
```

```bash-session
$ make
hello     there
start end
```





## 目标

makefile 以第一个规则的目标为默认目标，通常只有一个

### all 目标

以下 makefile 通过 all 可以生成多个目标

```makefile
all: one two three

one:
	touch one
two:
	touch two
three:
	touch three

clean:
	rm -f one two three
```

### 多目标

当一个规则有多个目标时，将为每个目标执行一次命令

```makefile
all: f1.o f2.o

f1.o f2.o:
	echo $@
```

相当于：

```makefile
all: f1.o f2.o

f1.o:
	echo f1.o
f2.o:
	echo f2.o
```





## 通配符

<div class="table-container no-thead">

|符号|作用                |                                                                       |
|:---|:-------------------|:----------------------------------------------------------------------|
|`*` | 匹配零或多个字符   |一般搭配 `wildcard` 函数使用，用于搜索文件系统匹配文件名               |
|`%` | 匹配一个或多个字符 |一般在规则中作为词干，用于匹配规则中的字符串，不能用于搜索文件系统 |
|`?` | 匹配单个字符       |                                                                       |

</div>

> 注意：在变量定义中直接使用的通配符会被视为字符串

### * 通配符

在变量定义中使用 `*`，匹配 `.o` 文件：

```makefile
thing_wrong := *.o             # 错误做法，* 不会被展开，会被视作 *.o 字符串
thing_right := $(wildcard *.o) # 正确做法
```

在规则中使用 `*`，打印 `.c` 文件：

```makefile
# 方式一：不推荐的用法
print_wrong: *.c
	ls -la  $?

# 方式二：推荐使用 wildcard
print_right: $(wildcard *.c)
	ls -la  $?
```

> 注意：方式一中当 `*` 没有匹配到文件时，它会保持原样 `*.c`（作为一个字符串）除非使用 `wildcard` 函数

### % 通配符

下面的 makefile 中 `%.c` 会匹配所有 `.c` 文件的依赖（不是搜索文件系统），就不用给每个 `.c` 文件单独写一条规则

```makefile
all: f1.c f2.c f3.c
	@echo "done"

%.c:
	@echo $@
```

```bash-session
$ make
f1.c
f2.c
f3.c
done
```





## 自动化变量

> 更多自动化变量参考：[Automatic Variables](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)

<div class="table-container no-thead w-50">

|符号|描述              |
|:---|:-----------------|
|`$@`|当前目标名        |
|`$^`|所有依赖名，去重  |
|`$<`|第一个依赖名      |
|`$+`|所有依赖名，不去重|
|`$?`|比目标新的依赖名  |
|`$*`|目标中%匹配的部分 |

</div>

```makefile
hey: one two
	@echo $@		# 输出 "hey"
	@echo $?		# 输出比目标新的依赖名
	@echo $^		# 输出所有依赖名
	@touch hey

one:
	@touch one

two:
	@touch two

clean:
	@rm -f hey one two
```

```bash-session
$ make
hey
one two
one two
$ make
make: 'hey' is up to date.
$ touch one && make
hey
one
one two
```





## 规则

### 隐式规则

> 隐式规则会让事情变得混乱，不推荐使用，但是要了解

- 编译 C 程序： `n.o` 由 `n.c` 自动生成，命令形式为 `$(CC) -c $(CPPFLAGS) $(CFLAGS)`
- 编译 C++ 程序：`n.o` 由 `n.cpp` 自动生成，命令形式为 `$(CXX) -c $(CPPFLAGS) $(CXXFLAGS)`
- 链接单个目标文件： `n` 是通过运行命令 `$(CC) $(LDFLAGS) n.o $(LOADLIBES) $(LDLIBS)` 从 `n.o` 自动生成的


<div class="table-container w-120"> 

|隐式规则变量 |                                           |
|:------------|:------------------------------------------|
|`CC`         |C 程序编译器，默认 `cc`                    |
|`CXX`        |C++ 程序编译器，默认 `g++`                 |
|`CFLAGS`     |提供给 C 编译器的参数                      |
|`CXXFLAGS`   |提供给 C++ 编译器的参数                    |
|`CPPFLAGS`   |提供给 C 预处理器的参数                    |
|`LDFLAGS`    |当编译器调用链接器时提供给编译器的额外参数 |

</div>


下面这个例子无需明确告诉 Make 如何进行编译，就可以构建一个 C 程序：

```makefile
CC = gcc    # 隐式规则的默认编译器
CFLAGS = -g # 编译器参数，-g 启用调试信息

# 隐式规则 #1：blah   是通过 C 链接器隐式规则构建的
# 隐式规则 #2：blah.o 是通过 C 编译隐式规则构建的，因为 blah.c 存在
blah: blah.o

blah.c:
	echo "int main() { return 0; }" > blah.c

clean:
	rm -f blah*
```

### 静态模式规则

```makefile
targets...: target-pattern: prereq-patterns ...
	commands
```

`target-pattern` 会匹配 `targets` 中的文件名，如 `%.o` 匹配 `foo.o` ，匹配到的词干为 `foo` ，然后将 `foo` 替换进 `prereq-patterns` 的 `%` 中

下面的例子是手动编写规则生成目标文件：

```makefile
objects = foo.o bar.o all.o
all: $(objects)

# 这些目标文件通过隐式规则编译
foo.o: foo.c
bar.o: bar.c
all.o: all.c

all.c:
	echo "int main() { return 0; }" > all.c
# %.c 会匹配 foo.c 和 bar.c ，没有则创建
%.c:
	touch $@

clean:
	rm -f *.c *.o all
```

下面的例子是通过静态模式规则生成目标文件：

```makefile
objects = foo.o bar.o all.o
all: $(objects)

# 这个例子中，%.o 会匹配 targets 中的 foo.o bar.o all.o
# 取出匹配到的词干 foo bar all
# 将词干替换进 %.c 中的 % ，即 foo.c bar.c all.c
$(objects): %.o: %.c

all.c:
	echo "int main() { return 0; }" > all.c

%.c:
	touch $@

clean:
	rm -f *.c *.o all
```

### 静态模式规则和 filter 过滤器

```makefile
obj_files = foo.result bar.o lose.o
src_files = foo.raw bar.c lose.c

.PHONY: all
all: $(obj_files)
# filter 函数会匹配 obj_files 中的 bar.o lose.o
# bar.o lose.o 由静态模式规则替换成 bar.c lose.c
$(filter %.o,$(obj_files)): %.o: %.c
	echo "target: $@ prereq: $<"

# filter 函数会匹配 obj_files 中的 foo.result
# foo.result 由静态模式规则替换成 foo.raw
$(filter %.result,$(obj_files)): %.result: %.raw
	echo "target: $@ prereq: $<" 

%.c %.raw:
	touch $@

clean:
	rm -f $(src_files)
```



### 模式规则

先看一个例子：

```makefile
# 这个模式规则将每个 .c 文件编译为 .o 文件
%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
```

规则目标中的 `%` 匹配任何非空字符，匹配的字符称为 `词干`，上述例子中 `%.o` 与 `%.c` 拥有相同的词干

再看另一个例子：

```makefile
# 定义一个没有先决条件的模式规则
# 当需要时会创建一个空的 .c 文件
%.c:
	touch $@
```

<div class="table-container"> 

|模式规则                  |静态模式规则                      |
|:-------------------------|:---------------------------------|
|`%.o : %.c`               |`$(OBJS) : %.o : %.c`             |
|全局：对所有匹配的文件生效|局部：只对显式列出的目标列表生效  |

</div>


### 双冒号规则

双冒号允许为同一个目标定义多个规则，如果是单冒号则会打印一条警告，并且只会运行第二组规则

```makefile
all: blah

blah::
	echo "hello"

blah::
	echo "hello again"
```




## 命令

### 命令回显/静默

命令前加 `@` ，在运行时这条命令不会被打印出来，`make -s` 有同样的效果

```makefile
all: 
	@echo "This make line will not be printed"
	echo "But this will"
```

### 命令执行

每个命令都在一个新的 shell 中运行

```makefile
all: 
	cd ..
	# cd 命令不会影响下面这条命令，应为两条命令是在两个shell中运行的
	echo `pwd`
	
	# 如果你想要 cd 命令影响下一条命令，可以在同一行以 ; 间隔
	cd ..;echo `pwd`
	
	# 同上，这里使用 \ 换行
	cd ..; \
	echo `pwd`
```

### 默认 shell

默认的 shell 是 `/bin/sh` ，你可以通过 `SHELL` 变量修改

```makefile
SHELL=/bin/bash

cool:
	echo "Hello from bash"
```

### 错误处理

- 在运行 make 时添加 `-k` 参数 `--keep-going` 以在遇到错误时继续运行（错误信息会被打印）
- 在运行 make 时添加 `-i` 参数 `--ignore-errors` 执行过程中忽略规则命令执行的错误（错误信息不会被打印）

亦可在命令前添加 `-` 以忽略错误 ，如下：

```makefile
one:
	# 这条错误信息不会被打印，make会继续执行下去
	-false
	touch one
```

### 中断 make

使用 `ctrl+c` ，它会中断 make 并删除新生成的目标文件

### 递归 make

在子目录执行 make，要使用 `$(MAKE)` 而不是 `make`

```makefile
subsystem:
	cd subdir && $(MAKE)
```

> 参考：[How the MAKE Variable Works](https://www.gnu.org/savannah-checkouts/gnu/make/manual/html_node/MAKE-Variable.html)

### 全局变量

使用 `export` 将变量声明为全局变量，这样子目录的 `make` 也可以引用该变量：

```makefile
cooly = "The subdirectory can see me!"
export cooly

all:
	cd subdir && $(MAKE)
```

使用 `.EXPORT_ALL_VARIABLES` 将所有的变量都声明为全局的：

```makefile
.EXPORT_ALL_VARIABLES:
one = "hello"
two = "world"
```

### SHELL 变量

使用 `$$` 可以引用 shell 中变量：

```makefile
all: 
	@echo $$one
```

```bash-session
$ one="hello" make
hello
```


### 命令行参数

```makefile
a ?= 456           # 定义默认值
override b = 456   # 覆盖来自命令行的变量

all: 
	@echo a=$(a) , b=$(b)
```

```bash-session
$ make a=123
a=123 , b=456
$ make b=123
a=456 , b=456
```


### define 命令列表

```makefile
define say
echo "hello"
echo "word"
endef

all:
	@$(say)
```

```bash-session
$ make
hello
word
```

### 指定目标变量

```makefile
# 给目标 all 指定 one 变量
all: one = cool

all: 
	@echo one is defined: $(one) # 打印 cool

other:
	@echo one is nothing: $(one) # 不会打印 cool
```

### 指定模式变量

```makefile
# 给匹配 %.c 这个模式的规则指定 one 变量
%.c: one = cool

blah.c: 
	@echo one is defined: $(one) # 打印 cool

other:
	@echo one is nothing: $(one) # 不会打印 cool
```

### 替换引用（后缀替换）

```makefile
SRCS = main.c utils.c helper.c
OBJS = $(SRCS:.c=.o)
all:
	@echo $(OBJS)    # 输出 main.o utils.o helper.o
```








## 条件语句

<div class="table-container no-thead w-100"> 

|关键字  |说明        |
|:-------|:-----------|
|`ifeq`  |是否相等    |
|`ifneq` |是否不相等  |
|`ifdef` |是否定义    |
|`ifndef`|是否未定义  |

</div>

都以 `endif` 结尾

### ifeq 判断变量相等

```makefile
foo = ok

all:
ifeq ($(foo), ok)
	@echo "foo equals ok"	# 打印
else
	@echo "nope"
endif
```

### ifeq 判断变量为空

```makefile
nullstring =
foo = $(nullstring) # 末尾有一个空格，单空格变量

all:
ifeq ($(strip $(foo)),)
	@echo "foo is empty after being stripped"		# 打印
endif
ifeq ($(nullstring),)
	@echo "nullstring doesn't even have spaces"		# 打印
endif
```

### ifdef 检查变量是否定义

ifdef 不展开变量引用，它只查看是否定义了某些内容

```makefile
bar =
foo = $(bar)

all:
ifdef foo
	@echo "foo is defined"		# 打印
endif
ifdef bar
	@echo "but bar is not"
endif
```

### $(MAKEFLAGS) 命令行参数

```makefile
all:
# 搜索 -i 标志。MAKEFLAGS 只是一个单一字符的列表，每个参数一个字符。
ifneq ($(findstring i, $(MAKEFLAGS)),)
	@echo $(MAKEFLAGS)
	@echo "i was passed to MAKEFLAGS"
endif
```

```bash-session
$ make -s -i
is
i was passed to MAKEFLAGS
```





## 字符串函数

> 更多函数参考 [Functions for Transforming Text](https://www.gnu.org/software/make/manual/html_node/Functions.html)

### subst 字符串替换

- 语法：`$(subst str,replacement,text)`
- 使用 `str` 匹配 `text` 中的字符，再用 `replacement` 进行替换。

```makefile
# 字符串替换，这里 totally 替换 not
bar := ${subst not, totally, "I am not superman"}
all: 
	@echo $(bar)
```

如果要替换空格或逗号，使用变量：

```makefile
comma := ,
empty :=
space := $(empty) $(empty)
foo := a b c
bar := $(subst $(space),$(comma),$(foo))

all: 
	# 输出是 "a,b,c"
	@echo $(bar)
```

不要在第 2、3 个参数前后包含空格，这将被视为字符串的一部分：

```makefile
comma := ,
empty :=
space := $(empty) $(empty)
foo := a b c
bar := $(subst $(space), $(comma) , $(foo)) # $(comma) 和 $(foo) 前后有一个空格

all: 
	# 输出是 ", a , b , c"
	@echo $(bar)
```

### patsubst 字符串替换

- 语法：`$(patsubst pattern,replacement,text)`
- 使用 `pattern` 匹配 `text` 中的字符，再用 `replacement` 进行替换。

```makefile
foo := a.o b.o l.a c.o
one := $(patsubst %.o,%.c,$(foo))
# 这是上面的简写
two := $(foo:%.o=%.c)
# 这是仅有后缀的简写，也等价于上述
three := $(foo:.o=.c)

# 输出都是 a.c b.c l.a c.c
all:
	@echo $(one)
	@echo $(two)
	@echo $(three)
```

### strip 去除字符串头尾的空白字符

- 语法：`$(strip string)`
- `strip` 不会移除字符串中间的空白字符，只会将其压缩为单个空格


### findstring 查找字符串

- 语法：`$(findstring find,in)`

```makefile
$(findstring a,a b c)   # 返回 a
$(findstring a,b c)     # 返回为空
```

### filter 过滤

- 语法：`$(filter pattern,text)`
- 返回 `text` 中所有与 `pattern` 匹配的以空格分隔的词，移除所有不匹配的词

```makefile
sources := foo.c bar.c baz.s ugh.h
foo:
	@echo $(filter %.c %.s,$(sources))  # 输出 foo.c bar.c baz.s
```

### filter-out 反向过滤

- 语法：`$(filter-out pattern,text)`
- 移除 `text` 中所有与 `pattern` 匹配的以空格分隔的词，返回不匹配的词

```makefile
sources := foo.c bar.c baz.s ugh.h
foo:
	@echo $(filter-out %.c %.s,$(sources))  # 输出 ugh.h
```

### sort 排序与去重

- 语法：`$(sort list)`
- 按字典顺序排列列表中的单词，并移除重复项

```makefile
$(sort foo bar bar lose)   # 返回 bar foo lose
```

### word 提取单词

- 语法：`$(word n,text)`
- 从单词列表中提取第 `n` 个单词

```makefile
$(word 2, foo bar baz)  # 返回 bar
```

### wordlist 提取单词列表

- 语法：`$(wordlist s,e,text)`
- 从 `s` 开始到 `e` 位置结束提取 `text` 中的单词

```makefile
$(wordlist 2, 3, foo bar baz)   # 返回 bar baz
```

### words 返回单词数量

- 语法：`$(words text)`
- 返回文本中的单词数量。因此，文本的最后一个单词是 `$(word $(words text),text)` 

### firstword 返回第一个单词

- 语法：`$(firstword text)`

### lastword 返回最后一个单词

- 语法：`$(lastword text)`





## 文件名函数

### dir 提取目录

- 语法：`$(dir names)`

```makefile
$(dir src/foo.c  hacks)  # 返回 src/  ./
```

### notdir 提取不含目录的部分

- 语法：`$(notdir names)`

```makefile
$(notdir src/foo.c hacks)  # 返回 foo.c  hacks
```

### suffix 提取后缀

- 语法：`$(suffix names)`

```makefile
$(suffix src/foo.c src-1.0/bar.c hacks)  # 返回 .c  .c
```

### basename 提取不含后缀的部分

- 语法：`$(basename names)`

```makefile
$(basename src/foo.c src-1.0/bar hacks)  # 返回 src/foo  src-1.0/bar  hacks
```

### addsuffix 添加后缀

- 语法：`$(addsuffix suffix,names)`

```makefile
$(addsuffix .c,foo bar)  # 返回 foo.c  bar.c
```

### addprefix 添加前缀

- 语法：`$(addprefix prefix,names)`

```makefile
$(addprefix src/,foo bar)  # 返回 src/foo  src/bar
```

### join 连接单词

- 语法：`$(join list1,list2)`
- 将 `list1` 中的第一个词与 `list2` 中的第一个词连接成一个词，以此类推

```makefile
$(join a b,.c .o)     # 返回 a.c  b.o
$(join a b c,.c .o)   # 返回 a.c  b.o  c
$(join a b,.c .o .s)  # 返回 a.c  b.o  .s
```

### wildcard 文件名匹配

- 语法：`$(wildcard pattern)`

```makefile
files := $(wildcard *.c)  # 返回当前目录下所有的 *.c 文件，没有则返回空
```

### realpath 返回真实绝对路径

- 语法：`$(realpath names)`

```makefile
$(realpath foo.c)  # foo.c 文件真实存在，返回 /home/king/Desktop/test/foo.c
$(realpath bar.c)  # bar.c 文件不存在，返回空
```

### abspath 返回绝对路径

- 语法：`$(abspath names)`

```makefile
$(abspath foo.c)  # foo.c 文件真实存在，返回 /home/king/Desktop/test/foo.c
$(abspath bar.c)  # bar.c 文件不存在，返回 /home/king/Desktop/test/bar.c
```

> `realpath` 会访问文件系统 / 检查路径 / 解析符号链接是否存在，`abspath` 只是简单替换当前的绝对路径





## 条件判断函数

> 不要和条件语句混淆


### if 函数

- 语法：`$(if condition,then-part[,else-part])`
- 若 `condition` 去除头尾空白字符后非空则为真，执行 `then-part`，否则执行 `else-part`

```makefile
flag1 = yes
flag2 =

foo:
	@echo $(if $(flag1),yes,no)  # 输出 yes
	@echo $(if $(flag2),yes,no)  # 输出 no
```

### or 函数

- 语法：`$(or condition1[,condition2[,condition3 ...]])`
- 按顺序展开参数，返回第一个非空的 `condition` 参数，然后停止展开

```makefile
flag1=
flag2=yes
flag3=no

foo:
	@echo $(or $(flag1),$(flag2),$(flag3))  # 输出 yes
```

### and 函数

- 语法：`$(and condition1[,condition2[,condition3 ...]])`
- 按顺序展开参数，遇到为空的 `condition` 参数立即停止展开且返回为空，若所有参数都不为空则返回最后一个参数

```makefile
flag1 = no
flag2 = 
flag3 = yes

foo:
	@echo $(and $(flag1),$(flag2),$(flag3))  # 输出为空
```

```makefile
flag1 = no
flag2 = 123
flag3 = yes

foo:
	@echo $(and $(flag1),$(flag2),$(flag3))  # 输出 yes
```

### intcmp 函数

- 语法：`$(intcmp lhs,rhs[,lt-part[,eq-part[,gt-part]]])`
- 将 `lhs` 和 `rhs` 展开并解析为 **十进制整数**，若 `lns < rhs` 执行 `lt-part`，以此类推

```makefile
flag1 = 1

flag2 = 2
flag3 = 1
flag4 = 0

foo:
	@echo $(intcmp $(flag1),$(flag2),less than,equal,greater than)  # 输出 less than
	@echo $(intcmp $(flag1),$(flag3),less than,equal,greater than)  # 输出 equal
	@echo $(intcmp $(flag1),$(flag4),less than,equal,greater than)  # 输出 greater than
```





## 其它函数

### let 局部变量函数

- 语法：`$(let var [var ...],[list],text)`
- 将 `list` 中的第一个值赋值给 `var` 中的第一个变量，依此类推，然后在 `text` 中可调用 `var` 中的局部变量

```makefile
result1 = $(let x y z,1 2 3  ,x=$(x) y=$(y) z=$(z))
result2 = $(let x y z,1 2    ,x=$(x) y=$(y) z=$(z))
result3 = $(let x y z,1 2 3 4,x=$(x) y=$(y) z=$(z))

all:
	@echo $(result1)  # 输出 x=1 y=2 z=3
	@echo $(result2)  # 输出 x=1 y=2 z=
	@echo $(result3)  # 输出 x=1 y=2 z=3 4
```

### foreach 循环遍历函数

- 语法：`$(foreach var,list,text)` 
- 从 `list` 依次提取一个值赋值给 `var`，然后在 `text` 中可以调用 `$(var)`

```makefile
foo = 1 2 3
bar = $(foreach v,$(foo),v=$(v))

all:
	@echo $(bar)  # 输出 v=1 v=2 v=3
```

### file 函数

- 语法：`$(file op filename[,text])`
- `op` 为操作符，可以是 `>` 覆盖、`>>` 追加，`text` 是写入文件的内容

```makefile
all:
	@$(file > hello.txt,hello world)                # 将 hello world 写入 hello.txt
	@$(foreach v,1 2 3, $(file >> hello.txt,$(v)))  # 将 1 2 3 共三行追加 hello.txt
```

```bash-session
$ cat hello.txt 
hello world
1
2
3
```

### call 函数

- 语法：`$(call variable,param,param,...)`
- 使用 `call` 调用用户创建的函数

```makefile
bar = p0=$(0), p1=$(1), p2=$(2)
all:
	@echo $(call bar,a,b)  # 输出 p0=bar, p1=a, p2=b
```

### value 函数

- 语法：`$(value var)`
- `value` 不会展开 `var` 中的参数，通常和 `eval` 函数搭配使用

```makefile
foo = hello,$USER

all:
	@echo $(foo)          # 扩展 $U
	@echo $(value foo)    # 保持 $USER
```

```bash-session
$ make
hello,SER
hello,king
```

### eval 函数

- 语法：`$(eval text)`
- 将 `text` 视为 makefile 语句执行

```makefile
text = foo = 123
all:
	$(eval $(text))
	@echo $(foo)    # 输出 123
```

### origin 函数

- 语法：`$(origin variable)`
- 打印变量来源

```makefile
b = 1
override d = 456
MY_VAR = 666

all:
	@echo '未定义              $(origin a)'
	@echo '文件内定义          $(origin b)'
	@echo '命令行定义          $(origin c)'
	@echo '文件内覆盖          $(origin d)'
	@echo '默认变量            $(origin CC)'
	@echo '环境变量            $(origin PATH)'
	@echo '环境变量覆盖        $(origin MY_VAR)'
	@echo '自动化变量          $(origin @)'
```

```bash-session
$ MY_VAR=123 make -e c=123 d=123
未定义              undefined
文件内定义          file
命令行定义          command line
文件内覆盖          override
默认变量            default
环境变量            environment
环境变量覆盖        environment override
自动化变量          automatic
```

> `-e` 参数允许环境变量覆盖文件中定义的变量

### error / warning / info 函数

- 语法：`$(error text ...)`

<div class="table-container no-thead w-100"> 

|||
|:--|:--|
|`error`   |生成一个致命错误并打印 text，**退出** make  |
|`warning` |生成一个警告并打印 text，**不退出** make    |
|`info`    |仅打印 text 信息                          |

</div>

### shell 函数

- 语法：`$(shell command)`
- 在 shell 中执行命令，返回命令的输出，输出内容中的换行符会被替换为空格

```makefile
str = $(shell echo -e "line1\nline2\nline3")
all:
	@echo $(str)   # 输出 line1 line2 line3
```





## 其他特性

### include 包含外部 makefile

```makefile
include filename1 filename2 ...
```

### vpath 指令

- 语法： `vpath <pattern> <directories>`
- `<pattern>` 会匹配 `<directories>` 中的文件名，多个目录使用 `空格` 或 `冒号` 分隔。

make 默认搜索当前目录来匹配依赖文件（不包含子目录），`vpath` 用于添加匹配文件的搜索路径


```makefile
# 添加 .c 文件搜索路径 dir1 dir2
vpath %.c dir1 dir2
vpath %.c dir1:dir2
```

### VPATH 变量

作用同 `vpath` 指令，用法如下：

```makefile
# 添加所有类型的文件的搜索路径 dir1 dir2
VPATH := dir1 dir2
VPATH := dir1:dir2

```

### .PRECIOUS 保留中间文件

Make 会在构建完成后删除它生成的中间文件（例如由 .c 文件编译出的 .o 文件），使用 `.PRECIOUS` 可以保留这些文件

```makefile
.PRECIOUS: %.o
```

### .PHONY 伪目标

伪目标只是一个标签，表示 make 不会生成该规则的目标文件，伪目标的取名不能和文件重名

```makefile
.PHONY: clean
clean:
	rm -f *.o
```

### .DELETE\_ON\_ERROR

当规则执行失败，`.DELETE_ON_ERROR` 会删除规则已生成的所有目标文件。

```makefile
.DELETE_ON_ERROR:
all: one two

one:
	touch one
	false

two:
	touch two
	false
```





## makefile 模板

```makefile
# 最终要生成的目标文件名
TARGET_EXEC := final_program

# 编译生成文件的目录
BUILD_DIR := ./build
# 源文件所在的目录
SRC_DIRS := ./src

# 找到所有需要编译的 C 和 C++ 文件
# 注意 * 表达式周围的单引号。否则 Make 会错误地扩展这些。
SRCS := $(shell find $(SRC_DIRS) -name '*.cpp' -or -name '*.c' -or -name '*.s')

# 给每个 C/C++ 文件名加 .o 结尾
# 如 hello.cpp 转换为 ./build/hello.cpp.o
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# .o 结尾替换为 .d
# 如 ./build/hello.cpp.o 转换为 ./build/hello.cpp.d
DEPS := $(OBJS:.o=.d)

# ./src 中的每个文件夹都需要传递给 GCC，以便它可以找到头文件
INC_DIRS := $(shell find $(SRC_DIRS) -type d)
# 给 INC_DIRS 添加前缀 -I ，GCC指定头文件路径需要 -I，如 moduleA 会变成 -ImoduleA
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# -MMD 和 -MP 参数会生成每个 .c 文件所依赖的头文件关系
# 保存到 .d 结尾的文件中
CPPFLAGS := $(INC_FLAGS) -MMD -MP

# 最终的编译步骤
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# 编译C源码
$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# 编译C++源码
$(BUILD_DIR)/%.cpp.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)

# 包含编译器生成的 .d 文件
-include $(DEPS)
```


## 参考链接

- [Makefile Tutorial](https://makefiletutorial.com/#getting-started)
- [GNU make](https://www.gnu.org/savannah-checkouts/gnu/make/manual/html_node/)

