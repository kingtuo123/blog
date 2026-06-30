---
title: "pstree"
date: "2026-06-30"
description: "以树状结构显示进程关系"
build:
  list: never
---





## 语法

```bash{ class="none-bg" }
pstree [选项] [pid|用户名]
```




## 选项

### 进程选择

{{< cmd-option >}} PID {{< /cmd-option >}}

只显示以该 PID 为根的子树

```bash-session
$ pstree 1
```

-----

{{< cmd-option >}} 用户名 {{< /cmd-option >}}

只显示该用户拥有的进程树（默认 root ）。

```bash-session
$ pstree king
```

-----

### 信息显示

{{< cmd-option >}} -a {{< /cmd-option >}}

显示进程的完整命令行参数。

-----

{{< cmd-option >}} -p {{< /cmd-option >}}

显示进程 PID。

-----

{{< cmd-option >}} -g {{< /cmd-option >}}

显示进程组 PGID。

-----

{{< cmd-option >}} -u {{< /cmd-option >}}

当进程的 UID 与父进程不同时，显示用户名。

```bash-session
$ pstree -u root
init─┬─5*[agetty]
     ├─at-spi-bus-laun({{< text fg="red">}}king{{< /text >}})─┬─dbus-daemon
     │                       └─3*[{at-spi-bus-laun}]
     ├─at-spi2-registr({{< text fg="red">}}king{{< /text >}})───3*[{at-spi2-registr}]
     ├─chronyd({{< text fg="red">}}ntp{{< /text >}})
     ...
```

-----

### 输出控制

{{< cmd-option >}} -c {{< /cmd-option >}}

禁用同名子树的压缩显示（不出现 `N*[进程名]`）。

```bash-session
$ pstree
fcitx5───4*[{fcitx5}]
$ pstree -c
fcitx5─┬─{fcitx5}
       ├─{fcitx5}
       ├─{fcitx5}
       └─{fcitx5}
```

-----

{{< cmd-option >}} -n {{< /cmd-option >}}

按 PID 排序。

-----

{{< cmd-option >}} -A {{< /cmd-option >}}

使用 ASCII 字符绘制连接线。

-----

{{< cmd-option >}} -l {{< /cmd-option >}}

长格式，不截断超长行。

-----
