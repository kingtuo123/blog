---
title: "Git"
date: "2026-07-04"
toc: true
draft: true
---





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














































































































## 本地仓库

## 远程仓库
