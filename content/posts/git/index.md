---
title: "Git"
date: "2026-07-04"
toc: true
draft: true
---



## Git 对象模型


**blob**

用于存储文件数据——它通常就是一个文件。

-----

**tree**

类似于一个目录，它会引用其它的 tree 或 blob。


-----

**commit**

一个 “commit” 指向单个 tree，将其标记为项目在某个特定时间点的样子。
它包含了关于该时间点的元信息，例如时间戳、自上次提交以来的变更作者、指向上一个提交的指针等。

-----

**tag**

是一种将特定提交标记为具有某种特殊意义的方式。它通常用于将某些提交标记为特定的发布版本或类似的用途。



## Git 目录结构


### objects - 对象数据库

```bash-session
$ git init test
$ cd test
$ tree .git/objects
.git/objects
├── info
└── pack
```

添加一个文件 `1.txt`：

```bash-session
$ echo 1 > 1.txt
$ git add 1.txt
$ tree .git/objects
.git/objects
├── {{< text fg="red" >}}d0{{< /text >}}
│   └── {{< text fg="red" >}}0491fd7e5bb6fa28c517a0bb32b8b506539d4d{{< /text >}}
├── info
└── pack
$ git cat-file -t d004 && git cat-file -p d004
blob
1
```

{{< img src="blob.svg" >}}

创建一个提交 `first commit`：

```bash-session
$ git commit -m "first commit"
$ tree .git/objects
.git/objects
├── {{< text fg="yellow" >}}38{{< /text >}}
│   └── {{< text fg="yellow" >}}fd29697b220f7e4ca15b044c3222eefe5afdc1{{< /text >}}
├── {{< text fg="green" >}}43{{< /text >}}
│   └── {{< text fg="green" >}}911c6c5a8aacd661e18417bc1602fe97463e2a{{< /text >}}
├── {{< text fg="red" >}}d0{{< /text >}}
│   └── {{< text fg="red" >}}0491fd7e5bb6fa28c517a0bb32b8b506539d4d{{< /text >}}
├── info
└── pack
$ git cat-file -t 38fd && git cat-file -p 38fd
tree
100644 blob {{< text fg="red" >}}d00491fd7e5bb6fa28c517a0bb32b8b506539d4d{{< /text >}}	1.txt
$ git cat-file -t {{< text >}}4391{{< /text >}} && git cat-file -p {{< text >}}4391{{< /text >}}
commit
tree {{< text fg="yellow" >}}38fd29697b220f7e4ca15b044c3222eefe5afdc1{{< /text >}}
author kingtuo123 <kingtuo123@foxmail.com> 1783325865 +0800
committer kingtuo123 <kingtuo123@foxmail.com> 1783325865 +0800

first commit
```

{{< img src="first-commit.svg" >}}

添加一个新文件 `2.txt`，并创建一个新提交 `second commit`：

```bash-session
$ echo 2 > 2.txt
$ git add 2.txt
$ git commit -m "second commit"
$ tree .git/objects
.git/objects
├── {{< text fg="red" >}}0c{{< /text >}}
│   └── {{< text fg="red" >}}fbf08886fca9a91cb753ec8734c84fcbe52c9f{{< /text >}}
├── 38
│   └── fd29697b220f7e4ca15b044c3222eefe5afdc1
├── {{< text fg="yellow" >}}43{{< /text >}}
│   ├── {{< text fg="yellow" >}}4943a8265129a744745e5d12fa2625a784b283{{< /text >}}
│   └── 911c6c5a8aacd661e18417bc1602fe97463e2a
├── {{< text fg="green" >}}4e{{< /text >}}
│   └── {{< text fg="green" >}}e2c410544a33f0bf171f7174c13283c7a80426{{< /text >}}
├── {{< text fg="red" >}}d0{{< /text >}}
│   └── {{< text fg="red" >}}0491fd7e5bb6fa28c517a0bb32b8b506539d4d{{< /text >}}
├── info
└── pack
$ git cat-file -t 0cfb && git cat-file -p 0cfb 
blob
2
$ git cat-file -t {{< text >}}4349{{< /text >}} && git cat-file -p {{< text >}}4349{{< /text >}}
tree
100644 blob {{< text fg="red" >}}d00491fd7e5bb6fa28c517a0bb32b8b506539d4d{{< /text >}}	1.txt
100644 blob {{< text fg="red" >}}0cfbf08886fca9a91cb753ec8734c84fcbe52c9f{{< /text >}}	2.txt
$ git cat-file -t 4ee2 && git cat-file -p 4ee2
commit
tree {{< text fg="yellow" >}}434943a8265129a744745e5d12fa2625a784b283{{< /text >}}
parent 43911c6c5a8aacd661e18417bc1602fe97463e2a
author kingtuo123 <kingtuo123@foxmail.com> 1783328632 +0800
committer kingtuo123 <kingtuo123@foxmail.com> 1783328632 +0800

second commit
```

{{< img src="second-commit.svg" >}}


#### blob 对象复用

当两个文件内容完全一样时，其 blob 对象是复用的：

```bash-session
$ git init test && cd test
$ echo 123 | tee 1.txt 2.txt
$ git add -A
$ git commit -m "first commit"
$ tree .git/objects
.git/objects
├── 14
│   └── 8922302de3ea7c41efb9597f6d64f36a30eb37
├── {{< text fg="red" >}}19{{< /text >}}
│   └── {{< text fg="red" >}}0a18037c64c43e6b11489df4bf0b9eb6d2c9bf{{< /text >}}
├── 8e
│   └── c76af43da31ed0f5450c3a853a7fc95aecf139
├── info
└── pack
$ git cat-file -t {{< text >}}1489{{< /text >}} && git cat-file -p {{< text >}}1489{{< /text >}}
tree
100644 blob {{< text fg="red" >}}190a18037c64c43e6b11489df4bf0b9eb6d2c9bf{{< /text >}}	1.txt
100644 blob {{< text fg="red" >}}190a18037c64c43e6b11489df4bf0b9eb6d2c9bf{{< /text >}}	2.txt
$ git cat-file -t 190a && git cat-file -p 190a
blob
123
```














































































<!--

## 仓库初始化

{{< table thead=false min-width="150" border=true >}}
|                                        |                                            |
|:---------------------------------------|:-------------------------------------------|
|*`git init`*                            |在当前目录初始化。                          |
|*`git init 目录`*                       |以指定目录名初始化                          |
{{< /table >}}







## 仓库配置

### 配置文件

{{< table border=true thead=false min-width="150,250" >}}
|                 |               |                                         |
|:----------------|:--------------|:----------------------------------------|
|**本地级配置**   |对当前仓库生效 |`.git/config`                            |
|**全局级配置**   |对当前用户生效 |`~/.gitconfig` 或 `~/.config/git/config` |
|**系统级配置**   |对所有用户生效 |`/etc/gitconfig`                         |
{{< /table >}}

> 优先级从高到低为：本地（local）→ 全局（global）→ 系统（system）。





### 配置命令

{{< table thead=false min-width="400" border=false >}}
|                                           |                    |
|:------------------------------------------|:-------------------|
|**全局配置**                               |                    |
|*`git config --global user.name "用户名"`* |设置用户名。        |
|*`git config --global user.email "邮箱"`*  |设置邮箱。          |
|*`git config --global --edit`*             |直接编辑配置文件。  |
|**查看所有配置**                        |                                            |
|*`git config --list`*                   |列出所有配置。                              |
|*`git config --list --show-origin`*     |列出所有配置及其来源的配置文件。            |
|**查看单项配置**                        |                                            |
|*`git config user.name`*                |查看用户名。                                |
|*`git config --show-origin user.email`* |查看邮箱及其来源的配置文件。                |
|**只查看对应级别配置**                  |                                            |
|*`git config --list --local`*           | 查看本地仓库配置，必须在仓库中执行该命令。 |
{{< /table >}}

> 不写级别默认是 `--local`。






## 工作树


worktree：可以实际编辑和查看的文件目录树。


{{< table thead=false min-width="400" border=true >}}
|                                           |                    |
|:------------------------------------------|:-------------------|
|**查看状态**                         ||
|*`git status`*                             |显示工作区与暂存区的状态。|
|*`git status -s`*                          |以简短格式输出状态（用字母标记状态）。|
|*`git status -b`*                          |在简短格式中同时显示当前分支与上游分支的跟踪信息。|
|**添加更改**||
|*`git add 文件`*                           |添加指定文件。|
|*`git add 路径`*                           |添加指定路径下的所有 **新增、修改、删除**。|
|*`git add -A`*                             |添加整个仓库下的所有 **新增、修改、删除**。|
|*`git add -u`*                             |添加整个仓库下的所有 **修改、删除**。|
|**撤销更改**                               ||
{{< /table >}}






git restore --worktree 从 statge 恢复文件到工作树



## 暂存区（索引 / index）


-->

