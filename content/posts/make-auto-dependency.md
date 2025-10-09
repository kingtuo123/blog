---
title: "Make 自动化依赖"
date: "2022-06-10"
toc: false
---


## 文件

<div class="code-bar"><span>文件</span><span>hello.c</span></div>

```c
#include <stdio.h>
#include "hello.h"

int main(void){
	printf("%s", MESSAGE);
	return 0;
}
```

<div class="code-bar"><span>文件</span><span>hello.h</span></div>

```c
#define MESSAGE "hello world"
```


## -MMD 和 -MP 编译器选项

`-MMD` 编译时自动生成依赖文件 `.d`，忽略系统头文件


```bash-session
$ gcc -MMD -c hello.c -o hello.o
$ cat hello.d
hello.o: hello.c hello.h
```

`-MP` 为依赖文件中的每个头文件生成一个伪目标（Phony）规则，防止删除头文件后 make 报规则错误

```bash-session
$ gcc -MMD -MP -c hello.c -o hello.o
$ cat hello.d
hello.o: hello.c hello.h
hello.h:
```

> 若每次都 `make clean` 后重新编译生成 `.d` 文件就不需要 `-MP` 参数


## Makefile

实现自动化依赖：

```makefile
DEPS = $(OBJS:.o=.d)
-include $(DEPS)
```
