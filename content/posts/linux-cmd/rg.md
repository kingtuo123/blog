---
title: "rg"
date: "2026-06-29"
description: "替代 grep 的高性能搜索工具"
build:
  list: never
---


## 语法

```bash{class="none-bg"}
rg [选项] '匹配模式' [路径...]
```


## 选项

### 匹配控制

{{< cmd-option >}} -e {{< /cmd-option >}}

显式指定一个模式。

-----

{{< cmd-option >}} -i {{< /cmd-option >}}

忽略大小写。

-----

{{< cmd-option >}} -s {{< /cmd-option >}}

强制区分大小写。

-----

{{< cmd-option >}} -F {{< /cmd-option >}}

将模式视为固定字符串，不解析为正则。

-----

{{< cmd-option >}} -w {{< /cmd-option >}}

精确匹配整个单词。

-----

{{< cmd-option >}} -x {{< /cmd-option >}}

精确匹配整行。

-----

{{< cmd-option >}} -v {{< /cmd-option >}}

反向匹配，仅显示不包含模式的行。

-----

{{< cmd-option >}} -P {{< /cmd-option >}}

使用 PCRE2 正则引擎（支持断言等高级特性）。

-----


### 上下文控制

{{< cmd-option >}} -A n {{< /cmd-option >}}

显示匹配行及后 n 行。

-----

{{< cmd-option >}} -B n {{< /cmd-option >}}

显示匹配行及前 n 行。

-----

{{< cmd-option >}} -C n {{< /cmd-option >}}

显示匹配行及前后各 n 行。

-----



### 输出控制


{{< cmd-option >}} -o {{< /cmd-option >}}

仅输出匹配的文本片段，而非整行。

-----

{{< cmd-option >}} -q {{< /cmd-option >}}

静默模式，不输出，用于脚本判断。

-----

{{< cmd-option >}} -n {{< /cmd-option >}}

显示行号（默认启用）。

-----

{{< cmd-option >}} -N {{< /cmd-option >}}

不显示行号。

-----

{{< cmd-option >}} -H {{< /cmd-option >}}

显示文件名（默认启用）。

-----

{{< cmd-option >}} -I {{< /cmd-option >}}

不显示文件名。

-----

{{< cmd-option >}} -l {{< /cmd-option >}}

仅列出包含匹配的文件名。

-----

{{< cmd-option >}} -c {{< /cmd-option >}}

显示每个文件的匹配行数。

-----

{{< cmd-option >}} -r '字符串' {{< /cmd-option >}}

将匹配内容替换为指定字符串后输出（不修改原文件）。

-----

{{< cmd-option >}} --heading {{< /cmd-option >}}

在匹配内容上方显示文件名（默认）。

-----

{{< cmd-option >}} --no-heading {{< /cmd-option >}}

在匹配内容左侧显示文件名（不在上方显示）。

-----

### 过滤控制

{{< cmd-option >}} --files {{< /cmd-option >}}

用于列出 `rg` 将要搜索的所有文件，而不实际执行搜索。

-----

{{< cmd-option >}} --type-list {{< /cmd-option >}}

列出所有可用的文件类型。

-----

{{< cmd-option >}} -t {{< /cmd-option >}}

按指定的文件类型搜索。

```bash-session
$ rg --files -t txt
hello.txt
```

-----

{{< cmd-option >}} -T {{< /cmd-option >}}

排除指定类型的文件。

-----

{{< cmd-option >}} -., --hidden {{< /cmd-option >}}

搜索隐藏文件和目录。

-----

{{< cmd-option >}} -g '*.txt' ,  --glob '*.txt'{{< /cmd-option >}}

按文件名 glob 匹配。

```bash-session
$ rg --files -g '*.txt'       # 列出所有匹配 *.txt 的文件
$ rg --files -g '!*.txt'      # 列出所有不匹配 *.txt 的文件
```
{{< notice class="red" >}}
使用单引号，避免 shell 展开！
{{< /notice >}}

glob 是一种使用通配符匹配文件名的模式语言，常用通配符如下：

{{< table thead=false border=false >}}
| 符号                 | 含义                                   |
|:---------------------|:---------------------------------------|
| `*`                  | 匹配除路径分隔符外的任意字符（包括空） |
| `?`                  | 匹配单个非分隔符字符                   |
| `[abc]`              | 匹配括号中的任意一个字符               |
| `[a-z]`              | 匹配字符范围                           |
| `[!abc]` 或 `[^abc]` | 匹配不在括号中的任意一个字符           |
| `{a,b}`              | 花括号扩展，匹配 `a` 或 `b`            |
{{< /table >}}

-----

{{< cmd-option >}} --iglob {{< /cmd-option >}}

同 `--glob` ，但不区分大小写。

-----

{{< cmd-option >}} -d N, --max-depth N {{< /cmd-option >}}

限制递归深度为 N 级目录。

-----

{{< cmd-option >}} -L {{< /cmd-option >}}

进入符号链接。

-----

{{< cmd-option >}} --max-filesize SIZE {{< /cmd-option >}}

跳过大于指定大小的文件，单位支持 `无后缀的数字（字节）`、`K`、`M`、`G`。

```bash-session
$ rg --files --max-filesize 10M     # 列出 <=10M 的文件
$ rg --files --max-filesize 0       # 列出空文件
```

-----


### 忽略规则

`rg` 默认会跳过几类文件：

- `.git` 目录。
- 隐藏文件 / 目录。
- 二进制文件。
- 符号链接。
- `.gitignore`、`.rgignore`、`.ignore` 中的文件。

-----

{{< cmd-option >}} --ignore-file 规则文件 {{< /cmd-option >}}

规则文件作用与 `.gitignore` 相同。

{{< bar title="my-ignore" >}}
```bash
*.log
temp/
```

```bash-session
$ rg --ignore-file my-ignore -e 'hello'
```

-----

{{< cmd-option >}} --no-ignore {{< /cmd-option >}}

忽略所有忽略规则，包括 `.gitignore`、`.rgignore`、`.ignore`。

-----
