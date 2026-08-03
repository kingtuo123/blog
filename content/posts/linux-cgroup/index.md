---
title: "Linux cgroup2"
date: "2026-08-02"
draft: true
---





## 测试

确认内核支持 cgroup2：

```bash-session
$ grep cgroup /proc/filesystems
nodev	cgroup
nodev	cgroup2
```

查看已挂载的 cgroup2

```bash-session
$ mount -t cgroup2
cgroup2 on {{< text fg="red" >}}/sys/fs/cgroup{{< /text >}} type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate)
```

如果系统没有挂载，可以手动操作（通常现代发行版已自动挂载）：

```bash-session
$ mount -t cgroup2 none /sys/fs/cgroup
```

查看根层级有哪些可用控制器

```bash-session
$ cat /sys/fs/cgroup/cgroup.controllers
cpuset cpu io memory hugetlb pids rdma misc
```

查看已下发给子级的控制器

```bash-session
cat /sys/fs/cgroup/cgroup.subtree_control
cpu memory pids
```


## 层级架构

```
Unified Hierarchy（统一层级）
        │
        ├── cgroup.controllers (可用控制器)
        ├── cgroup.subtree_control (向子树启用的控制器)
        │
        ├── child-A/ (叶子节点，放进程)
        │     ├── cpu.max
        │     ├── memory.max
        │     └── cgroup.procs
        │
        └── child-B/ (中间节点，可再分子树)
              ├── cgroup.subtree_control (+cpu,+mem)
              └── grandchild/ (叶子节点)
                    └── cgroup.procs
```


## 控制器

cpu、cpuset、memory、io、pids、rdma、hugetlb、misc 八大控制器及其接口文件


## cpu

查看 cpu 使用率：

```bash-session
$ vmstat 1 2 | tail -1 | awk '{print 100 - $15 "%"}'
```

跑满 cpu0

```bash-session
$ taskset -c 0 stress -c 1
```



## 问题

1. 哪些程序会在 `/sys/fs/cgroup/` 有子层级，我这里 `elogind` 和 `docker` `openrc` 都有，但是有些进程又没有，所以...

2. cgroup v2 把进程组织成一棵统一的树,沿着树自顶向下分配和限制 CPU、内存、磁盘 I/O 等资源。用户态只需对 /sys/fs/cgroup 下的目录和文件做 mkdir / echo / cat,即可完成全部管理。

3. 为什么是 C1，是谁决定，谁分配的

```bash-session
$ cat /proc/self/cgroup
0::/c1
```
