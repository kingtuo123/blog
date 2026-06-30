---
title: "grep"
date: "2026-06-27"
description: "文本搜索工具"
build:
  list: never
---



## 语法


```bash{class="none-bg"}
grep [选项] '搜索模式' [文件...]
```



## 选项

### 匹配控制

{{< cmd-option >}} -e {{< /cmd-option >}}

显式指定一个搜索模式。

```bash-session
$ grep -e 'error' -e 'warning' -e 'fatal' app.log
```

-----
{{< cmd-option >}} -i {{< /cmd-option >}}

忽略大小写。

-----

{{< cmd-option >}} -v {{< /cmd-option >}}

反向匹配，显示不匹配的行。

-----

{{< cmd-option >}} -w {{< /cmd-option >}}

精确匹配整个单词。

-----

{{< cmd-option >}} -x {{< /cmd-option >}}

精确匹配整行。

-----

{{< cmd-option >}} -F {{< /cmd-option >}}

不解析正则表达式，视为固定字符串进行匹配，等同 `fgrep` 命令。

-----

{{< cmd-option >}} -E {{< /cmd-option >}}

使用扩展正则表达式（ERE），等同 `egrep` 命令（支持 `+, ?, (), {}` 等）。

-----

{{< cmd-option >}} -P {{< /cmd-option >}}

使用 Perl 兼容正则表达式（PCRE，支持 `\d, \w, \s` 等）。

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

只输出匹配到的部分，而非整行。

-----

{{< cmd-option >}} -n {{< /cmd-option >}}

显示行号。

-----

{{< cmd-option >}} -c {{< /cmd-option >}}

统计匹配的行数（不显示内容）。

-----

{{< cmd-option >}} -l {{< /cmd-option >}}

只列出包含匹配的文件名。

-----

{{< cmd-option >}} -L {{< /cmd-option >}}

只列出不包含匹配的文件名。

-----

{{< cmd-option >}} -q {{< /cmd-option >}}

静默模式，不输出，用于脚本判断。

-----

{{< cmd-option >}} -s {{< /cmd-option >}}

不显示错误信息（如文件不存在）。

-----


### 文件操作

{{< cmd-option >}} -r {{< /cmd-option >}}

递归搜索目录下的所有文件。

-----

{{< cmd-option >}} -R {{< /cmd-option >}}

递归搜索目录下的所有文件（进入符号链接）。

-----

{{< cmd-option >}} --include '*.txt' {{< /cmd-option >}}

只搜索匹配的文件。

-----

{{< cmd-option >}} --exclude '*.txt' {{< /cmd-option >}}

不搜索匹配的文件。

-----

{{< cmd-option >}} --exclude-dir '.cache' {{< /cmd-option >}}

不搜索匹配的目录。

-----
