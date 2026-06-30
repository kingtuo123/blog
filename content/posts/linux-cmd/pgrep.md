---
title: "pgrep"
date: "2026-06-30"
description: "基于名称或属性查找进程 ID"
build:
  list: never
---




## 语法

```bash{class="none-bg"}
pgrep [选项] '模式'
```




## 选项

{{< cmd-option >}} -i {{< /cmd-option >}}

忽略大小写。

-----

{{< cmd-option >}} -l {{< /cmd-option >}}

显示进程名。

-----

{{< cmd-option >}} -a {{< /cmd-option >}}

显示完整命令行。

-----

{{< cmd-option >}} -u, --euid {{< /cmd-option >}}

匹配有效用户 ID 或用户名（euid 进程当前拥有的权限身份）。

-----

{{< cmd-option >}} -U, --uid {{< /cmd-option >}}

匹配真实用户 ID 或用户名（uid 启动进程的真正用户）。

列出用户 king（UID=1000）启动的所有进程：

```bash-session
$ pgrep -l -U king
$ pgrep -l -U 1000
```

-----

{{< cmd-option >}} -v {{< /cmd-option >}}

反向选择，输出不匹配的进程。

列出所有不属于 root 的进程：
```bash-session
$ pgrep -v -u root
```

-----

{{< cmd-option >}} -c {{< /cmd-option >}}

只输出匹配进程的数量，不输出 PID。

-----

{{< cmd-option >}} -f {{< /cmd-option >}}

匹配完整的命令行，而不仅是进程名。

-----

{{< cmd-option >}} -x {{< /cmd-option >}}

精确匹配进程名，例如 nginx 不匹配 nginx-worker。

-----
